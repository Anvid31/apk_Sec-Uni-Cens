// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/image_helper.dart';

/// Servicio de persistencia remota y autenticación con Supabase.
///
/// Requiere en `.env`:
///   SUPABASE_URL=https://tu-proyecto.supabase.co
///   SUPABASE_ANON_KEY=tu-anon-key
///
/// Esquema: ver `scripts/supabase_schema.sql`
class SupabaseService {
  static SupabaseClient? get _clientOrNull {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static const _queryTimeout = Duration(seconds: 20);
  // Las encuestas incluyen fotos: con señal rural el envío tarda más.
  static const _uploadTimeout = Duration(seconds: 90);

  static SupabaseClient get _client =>
      _clientOrNull ??
      (throw StateError(
          'Servidor no disponible: Supabase no se inicializó (revise .env).'));

  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static bool get isConfigured =>
      url.isNotEmpty && url != 'https://tu-proyecto.supabase.co';

  // ─── Autenticación ─────────────────────────────────────────────────────────

  static User? get currentUser => _clientOrNull?.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    ).timeout(_queryTimeout);
    if (response.user == null) {
      throw const AuthException('Credenciales inválidas');
    }
    print('✅ SupabaseService: sesión iniciada — ${response.user!.email}');
    return response;
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
    print('🔌 SupabaseService: sesión cerrada');
  }

  // ─── Guardar encuesta ──────────────────────────────────────────────────────

  static Future<void> saveSurvey(Map<String, dynamic> surveyData) async {
    try {
      final Map<String, dynamic> data =
          json.decode(json.encode(surveyData)) as Map<String, dynamic>;

      final bool isMobiliario = _isMobiliarioForm(data);
      final String table =
          isMobiliario ? 'inventario_mobiliario' : 'surveys';

      data['fechaSubida'] ??= DateTime.now().toIso8601String();

      final meta = _extractMeta(data, isMobiliario: isMobiliario);

      // Fotos primero: si falla la subida, la fila no se guarda y la
      // encuesta sigue en la cola local para reintentar.
      await _processImages(data, meta['id'] as String);

      final row = <String, dynamic>{
        'id': meta['id'],
        'form_type': isMobiliario ? 'mobiliario' : 'caracterizacion',
        'institution': meta['institution'],
        'municipality': meta['municipality'],
        'department': meta['department'],
        'data': data,
        'user_id': currentUser?.id,
      };

      if (!isMobiliario) {
        row['dane_code'] = meta['daneCode'];
        row['latitude'] = meta['latitude'];
        row['longitude'] = meta['longitude'];
      }

      // insert (no upsert): anon no tiene SELECT/UPDATE por RLS y
      // ON CONFLICT exige ambos. Un reintento choca con la PK (23505):
      // la encuesta ya está guardada, se trata como éxito.
      try {
        await _client.from(table).insert(row).timeout(_uploadTimeout);
      } on PostgrestException catch (e) {
        if (e.code != '23505') rethrow;
        print('ℹ️ SupabaseService: encuesta ${meta['id']} ya existía en $table');
      }

      print('✅ SupabaseService: encuesta ${meta['id']} guardada en $table');
    } catch (e) {
      print('❌ SupabaseService: error guardando encuesta: $e');
      rethrow;
    }
  }

  // ─── Historial de encuestas ────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> querySurveysForHistory() async {
    try {
      final response = await _client
          .from('surveys')
          .select('id, created_at, institution, municipality, form_type')
          .order('created_at', ascending: false)
          .limit(100)
          .timeout(_queryTimeout);
      return (response as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ SupabaseService: error consultando historial: $e');
      return [];
    }
  }

  // ─── Consulta para exportación ─────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> querySurveysForExport() async {
    try {
      final response = await _client
          .from('surveys')
          .select(
            'id, created_at, form_type, institution, dane_code, '
            'municipality, department, latitude, longitude, data',
          )
          .not('latitude', 'is', null)
          .not('longitude', 'is', null)
          .order('institution')
          .timeout(_queryTimeout);

      final rows = <Map<String, dynamic>>[];
      for (final row in response as List<dynamic>) {
        final map = row as Map<String, dynamic>;
        final rawData = map['data'];
        Map<String, dynamic> data;
        if (rawData is Map<String, dynamic>) {
          data = rawData;
        } else if (rawData is String) {
          data = json.decode(rawData) as Map<String, dynamic>;
        } else {
          data = {};
        }

        final createdAt = map['created_at'];
        rows.add({
          'id': map['id']?.toString() ?? '',
          'created_at': createdAt?.toString() ?? '',
          'form_type': map['form_type']?.toString() ?? '',
          'institution': map['institution']?.toString() ?? '',
          'dane_code': map['dane_code']?.toString() ?? '',
          'municipality': map['municipality']?.toString() ?? '',
          'department': map['department']?.toString() ?? '',
          'latitude': (map['latitude'] as num?)?.toDouble() ?? 0.0,
          'longitude': (map['longitude'] as num?)?.toDouble() ?? 0.0,
          'data': data,
        });
      }

      print(
        '✅ SupabaseService: ${rows.length} registros para exportación',
      );
      return rows;
    } catch (e) {
      print('❌ SupabaseService: error consultando para exportación: $e');
      rethrow;
    }
  }

  // ─── Helpers internos ──────────────────────────────────────────────────────

  static bool _isMobiliarioForm(Map<String, dynamic> data) {
    final tipo = data['tipoFormulario'] as String? ?? '';
    final type = data['formType'] as String? ?? '';
    return tipo == 'mobiliario' || type == 'furniture';
  }

  static Map<String, dynamic> _extractMeta(
    Map<String, dynamic> data, {
    required bool isMobiliario,
  }) {
    final id = data['id'] as String? ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final inner = (data['datos'] ?? data['data']) as Map<String, dynamic>?;
    final instInfo = (inner?['informacionInstitucional'] ??
        inner?['institutionalInfo'] ??
        data['informacionInstitucional'] ??
        data['institutionalInfo']) as Map<String, dynamic>?;
    final genInfo = (inner?['informacionGeneral'] ??
        inner?['generalInfo'] ??
        data['informacionGeneral'] ??
        data['generalInfo']) as Map<String, dynamic>?;

    final institution = instInfo?['institutionName'] as String? ??
        instInfo?['nombreInstitucion'] as String? ??
        data['institutionName'] as String? ??
        data['schoolName'] as String? ??
        '';
    final daneCode =
        instInfo?['dane'] as String? ?? data['daneCode'] as String? ?? '';
    final municipality = genInfo?['municipality'] as String? ??
        genInfo?['municipio'] as String? ??
        instInfo?['municipality'] as String? ??
        data['municipality'] as String? ??
        '';
    final department = genInfo?['department'] as String? ??
        genInfo?['departamento'] as String? ??
        data['department'] as String? ??
        '';

    double? lat;
    double? lon;
    if (!isMobiliario) {
      final coords = instInfo?['locationCoordinates'] as String? ??
          instInfo?['coordenadasUbicacion'] as String?;
      if (coords != null && coords.contains(',')) {
        final parts = coords.split(',');
        lat = double.tryParse(parts[0].trim());
        lon = double.tryParse(parts[1].trim());
      }
      lat ??= (data['latitude'] as num?)?.toDouble();
      lon ??= (data['longitude'] as num?)?.toDouble();
    }

    return {
      'id': id,
      'institution': institution,
      'daneCode': daneCode,
      'municipality': municipality,
      'department': department,
      'latitude': lat,
      'longitude': lon,
    };
  }

  // ─── Fotos → Supabase Storage ──────────────────────────────────────────────
  //
  // Cada foto se sube a `fotos-encuestas/<survey_id>/<campo>.jpg` y en la
  // fila queda `{path, contentType}`. Así la base de datos no crece con
  // base64 y las fotos de una sede quedan juntas en su carpeta.

  static const photoBucket = 'fotos-encuestas';

  static const _photoKeys = [
    'photoFront',
    'photoClassroom1',
    'photoClassroom2',
    'photoKitchen',
    'photoDiningRoom',
    'photoBathroom',
    'photoInstalacionesElectricas',
  ];

  static Future<void> _processImages(
    Map<String, dynamic> data,
    String surveyId,
  ) async {
    final inner = (data['datos'] ?? data['data']) as Map<String, dynamic>?;
    if (inner != null) {
      await _processPhotoSection(inner, surveyId, 'infoRegistroFotografico');
      await _processPhotoSection(inner, surveyId, 'photographicRecordInfo');
      await _processPhotoSection(inner, surveyId, 'fotos');
      await _processPhotoSection(inner, surveyId, 'photos');
      await _processFlatPhotoFields(inner, surveyId);
    } else {
      await _processPhotoSection(data, surveyId, 'infoRegistroFotografico');
      await _processPhotoSection(data, surveyId, 'photographicRecordInfo');
    }
    await _processFlatPhotoFields(data, surveyId);
  }

  static Future<void> _processFlatPhotoFields(
    Map<String, dynamic> parent,
    String surveyId,
  ) async {
    for (final key in _photoKeys) {
      final path = parent[key];
      if (path is String && path.isNotEmpty) {
        parent[key] = await _uploadPhoto(surveyId, key, path);
      }
    }
  }

  /// Sube una foto local. Errores de red/servidor se propagan para que la
  /// encuesta quede en cola; solo un archivo local inexistente se registra
  /// como error en la fila (no hay forma de recuperarlo).
  static Future<Map<String, dynamic>> _uploadPhoto(
    String surveyId,
    String field,
    String localPath,
  ) async {
    final bytes = await ImageHelper.compressForUpload(localPath);
    if (bytes == null) {
      return {'error': 'Imagen no encontrada', 'originalPath': localPath};
    }
    final storagePath = '$surveyId/$field.jpg';
    try {
      await _client.storage.from(photoBucket).uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          ).timeout(_uploadTimeout);
    } on StorageException catch (e) {
      // Reintento de un envío previo cortado: la foto ya está arriba.
      final duplicate = e.statusCode == '409' ||
          e.error == 'Duplicate' ||
          e.message.contains('already exists');
      if (!duplicate) rethrow;
    }
    return {'path': storagePath, 'contentType': 'image/jpeg'};
  }

  static Future<void> _processPhotoSection(
    Map<String, dynamic> parent,
    String surveyId,
    String key,
  ) async {
    final section = parent[key];
    if (section is! Map) return;
    final processed = <String, dynamic>{};
    for (final entry in (section as Map<String, dynamic>).entries) {
      final path = entry.value;
      if (path == null) {
        processed[entry.key] = null;
      } else if (path is String && path.isNotEmpty) {
        processed[entry.key] =
            await _uploadPhoto(surveyId, '${key}_${entry.key}', path);
      } else {
        processed[entry.key] = path;
      }
    }
    parent[key] = processed;
  }
}
