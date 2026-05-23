// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:postgres/postgres.dart';
import '../utils/image_helper.dart';

/// Servicio de persistencia remota con PostgreSQL.
///
/// Requiere en `.env`:
///   PG_HOST=192.168.x.x
///   PG_PORT=5432
///   PG_DB=caracterizacion_cens
///   PG_USER=usuario
///   PG_PASSWORD=contraseña
///
/// Esquema esperado (ejecutar una sola vez en el servidor):
/// ```sql
/// CREATE TABLE IF NOT EXISTS surveys (
///   id            TEXT PRIMARY KEY,
///   created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
///   form_type     TEXT NOT NULL,
///   institution   TEXT,
///   dane_code     TEXT,
///   municipality  TEXT,
///   department    TEXT,
///   latitude      DOUBLE PRECISION,
///   longitude     DOUBLE PRECISION,
///   data          JSONB NOT NULL
/// );
/// CREATE TABLE IF NOT EXISTS inventario_mobiliario (
///   id            TEXT PRIMARY KEY,
///   created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
///   form_type     TEXT NOT NULL,
///   institution   TEXT,
///   municipality  TEXT,
///   department    TEXT,
///   data          JSONB NOT NULL
/// );
/// ```
class PostgresService {
  static Connection? _connection;

  // ─── Configuración ─────────────────────────────────────────────────────────

  static String get _host => dotenv.env['PG_HOST'] ?? 'localhost';
  static int get _port => int.tryParse(dotenv.env['PG_PORT'] ?? '5432') ?? 5432;
  static String get _dbName => dotenv.env['PG_DB'] ?? 'caracterizacion_cens';
  static String get _user => dotenv.env['PG_USER'] ?? '';
  static String get _password => dotenv.env['PG_PASSWORD'] ?? '';

  // ─── Conexión ──────────────────────────────────────────────────────────────

  static Future<Connection> _getConnection() async {
    if (_connection != null) {
      try {
        // Verificar que la conexión siga activa con un ping ligero
        await _connection!.execute('SELECT 1');
        return _connection!;
      } catch (_) {
        _connection = null;
      }
    }
    return connect();
  }

  /// Abre (o reabre) la conexión a PostgreSQL.
  static Future<Connection> connect() async {
    if (_user.isEmpty || _password.isEmpty) {
      throw Exception(
          'PostgreSQL: PG_USER y PG_PASSWORD deben estar configurados en .env');
    }

    try {
      _connection = await Connection.open(
        Endpoint(
          host: _host,
          port: _port,
          database: _dbName,
          username: _user,
          password: _password,
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.disable, // cambiar a SslMode.require en producción
          connectTimeout: Duration(seconds: 10),
        ),
      );
      print('✅ PostgresService: conexión establecida con $_host:$_port/$_dbName');
      return _connection!;
    } catch (e) {
      print('❌ PostgresService: error conectando: $e');
      rethrow;
    }
  }

  /// Cierra la conexión activa.
  static Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
      print('🔌 PostgresService: conexión cerrada');
    }
  }

  // ─── Guardar encuesta ──────────────────────────────────────────────────────

  /// Guarda [surveyData] en la tabla correcta según el tipo de formulario.
  ///
  /// Detecta si es "mobiliario" o "caracterización" igual que `MongoService`.
  /// Procesa imágenes a Base64 antes de insertar.
  static Future<void> saveSurvey(Map<String, dynamic> surveyData) async {
    try {
      final conn = await _getConnection();

      // Copia profunda para no mutar el objeto en memoria
      final Map<String, dynamic> data =
          json.decode(json.encode(surveyData)) as Map<String, dynamic>;

      // Procesar imágenes a Base64
      await _processImages(data);

      // Determinar tabla destino
      final bool isMobiliario = _isMobiliarioForm(data);
      final String table = isMobiliario ? 'inventario_mobiliario' : 'surveys';

      // Extraer campos planos para columnas indexables
      final meta = _extractMeta(data, isMobiliario: isMobiliario);

      // Agregar timestamp si no existe
      data['fechaSubida'] ??= DateTime.now().toIso8601String();

      if (isMobiliario) {
        await conn.execute(
          Sql.named('''
            INSERT INTO $table (id, form_type, institution, municipality, department, data)
            VALUES (@id, @formType, @institution, @municipality, @department, @data)
            ON CONFLICT (id) DO UPDATE SET
              data        = EXCLUDED.data,
              institution = EXCLUDED.institution
          '''),
          parameters: {
            'id': meta['id'],
            'formType': 'mobiliario',
            'institution': meta['institution'],
            'municipality': meta['municipality'],
            'department': meta['department'],
            'data': TypedValue(Type.jsonb, json.encode(data)),
          },
        );
      } else {
        await conn.execute(
          Sql.named('''
            INSERT INTO $table (id, form_type, institution, dane_code, municipality, department, latitude, longitude, data)
            VALUES (@id, @formType, @institution, @daneCode, @municipality, @department, @latitude, @longitude, @data)
            ON CONFLICT (id) DO UPDATE SET
              data        = EXCLUDED.data,
              institution = EXCLUDED.institution
          '''),
          parameters: {
            'id': meta['id'],
            'formType': 'caracterizacion',
            'institution': meta['institution'],
            'daneCode': meta['daneCode'],
            'municipality': meta['municipality'],
            'department': meta['department'],
            'latitude': meta['latitude'],
            'longitude': meta['longitude'],
            'data': TypedValue(Type.jsonb, json.encode(data)),
          },
        );
      }

      print(
          '✅ PostgresService: encuesta ${meta['id']} guardada en tabla $table');
    } catch (e) {
      print('❌ PostgresService: error guardando encuesta: $e');
      rethrow;
    }
  }

  // ─── Helpers internos ──────────────────────────────────────────────────────

  static bool _isMobiliarioForm(Map<String, dynamic> data) {
    final tipo = data['tipoFormulario'] as String? ?? '';
    final type = data['formType'] as String? ?? '';
    return tipo == 'mobiliario' || type == 'furniture';
  }

  /// Extrae campos de metadatos para las columnas indexadas de la tabla.
  static Map<String, dynamic> _extractMeta(
    Map<String, dynamic> data, {
    required bool isMobiliario,
  }) {
    final id = data['id'] as String? ??
        DateTime.now().millisecondsSinceEpoch.toString();

    // Soporte para la estructura anidada tanto en español como en inglés
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

    final daneCode = instInfo?['dane'] as String? ??
        data['daneCode'] as String? ??
        '';

    final municipality = genInfo?['municipality'] as String? ??
        genInfo?['municipio'] as String? ??
        instInfo?['municipality'] as String? ??
        data['municipality'] as String? ??
        '';

    final department = genInfo?['department'] as String? ??
        genInfo?['departamento'] as String? ??
        data['department'] as String? ??
        '';

    // Coordenadas GPS: "lat,lon" o campos separados
    double? lat;
    double? lon;
    if (!isMobiliario) {
      final coords =
          instInfo?['locationCoordinates'] as String? ??
          instInfo?['coordenadasUbicacion'] as String?;
      if (coords != null && coords.contains(',')) {
        final parts = coords.split(',');
        lat = double.tryParse(parts[0].trim());
        lon = double.tryParse(parts[1].trim());
      }
      // Soporte para coordenadas como campos numéricos directos (formulario unificado)
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

  // ─── Procesamiento de imágenes ─────────────────────────────────────────────

  /// Convierte rutas de imagen a Base64 en todas las secciones conocidas.
  static Future<void> _processImages(Map<String, dynamic> data) async {
    final inner = (data['datos'] ?? data['data']) as Map<String, dynamic>?;

    if (inner != null) {
      await _processPhotoSection(inner, 'infoRegistroFotografico');
      await _processPhotoSection(inner, 'photographicRecordInfo');
      await _processPhotoSection(inner, 'fotos');
      await _processPhotoSection(inner, 'photos');
    } else {
      // Estructura plana
      await _processPhotoSection(data, 'infoRegistroFotografico');
      await _processPhotoSection(data, 'photographicRecordInfo');
      await _processPhotoSection(data, 'fotos');
      await _processPhotoSection(data, 'photos');
    }
  }

  static Future<void> _processPhotoSection(
    Map<String, dynamic> parent,
    String key,
  ) async {
    final section = parent[key];
    if (section is! Map) return;

    final processed = <String, dynamic>{};

    for (final entry in (section as Map<String, dynamic>).entries) {
      final path = entry.value;
      if (path == null) {
        processed[entry.key] = null;
        continue;
      }
      if (path is String && path.isNotEmpty) {
        try {
          final base64 = await ImageHelper.processImageForDb(path);
          processed[entry.key] = base64 != null
              ? {
                  'fileName': path.split('/').last,
                  'imagedata': base64,
                  'contentType': 'image/jpeg',
                }
              : {'error': 'Imagen no encontrada', 'originalPath': path};
        } catch (e) {
          processed[entry.key] = {
            'error': 'Error procesando: $e',
            'originalPath': path,
          };
        }
      } else {
        processed[entry.key] = path;
      }
    }

    parent[key] = processed;
  }

  // ─── Consulta para exportación ─────────────────────────────────────────────

  /// Retorna todos los registros de la tabla `surveys` con los campos
  /// necesarios para la exportación a Shapefile (sin imágenes Base64).
  ///
  /// Cada mapa contiene las claves:
  ///   institution, dane_code, municipality, department,
  ///   latitude, longitude, principal_name, survey_date,
  ///   total_students, teachers_count, has_electricity, access_route
  static Future<List<Map<String, dynamic>>> querySurveysForExport() async {
    try {
      final conn = await _getConnection();

      final result = await conn.execute(
        r'''
        SELECT
          institution,
          dane_code,
          municipality,
          department,
          latitude,
          longitude,
          data->'institutionalInfo'->>'principalName' AS principal_name,
          data->'generalInfo'->>'date'               AS survey_date,
          data->'coverageInfo'->>'totalStudents'      AS total_students,
          data->'coverageInfo'->>'teachersCount'      AS teachers_count,
          data->'electricityInfo'->>'hasElectricService' AS has_electricity,
          data->'accessRouteInfo'->>'principalRoute'  AS access_route
        FROM surveys
        WHERE latitude IS NOT NULL AND longitude IS NOT NULL
        ORDER BY institution
        ''',
      );

      final rows = <Map<String, dynamic>>[];
      for (final row in result) {
        final cols = row.toColumnMap();
        rows.add({
          'institution': cols['institution'] ?? '',
          'dane_code': cols['dane_code'] ?? '',
          'municipality': cols['municipality'] ?? '',
          'department': cols['department'] ?? '',
          'latitude': (cols['latitude'] as num?)?.toDouble() ?? 0.0,
          'longitude': (cols['longitude'] as num?)?.toDouble() ?? 0.0,
          'principal_name': cols['principal_name'] ?? '',
          'survey_date': cols['survey_date'] ?? '',
          'total_students': int.tryParse(cols['total_students']?.toString() ?? '0') ?? 0,
          'teachers_count': int.tryParse(cols['teachers_count']?.toString() ?? '0') ?? 0,
          'has_electricity': cols['has_electricity']?.toString() == 'true',
          'access_route': cols['access_route'] ?? '',
        });
      }

      print('✅ PostgresService: ${rows.length} registros consultados para exportación');
      return rows;
    } catch (e) {
      print('❌ PostgresService: error consultando para exportación: $e');
      rethrow;
    }
  }
}
