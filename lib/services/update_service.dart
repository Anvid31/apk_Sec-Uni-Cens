// ignore_for_file: avoid_print

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Información de una actualización disponible.
class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String releaseName;
  final String releaseNotes;
  final String? downloadUrl;

  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseName,
    required this.releaseNotes,
    this.downloadUrl,
  });

  bool get hasDownload => downloadUrl != null && downloadUrl!.isNotEmpty;
}

/// Servicio de actualización automática vía GitHub Releases.
///
/// Requiere en `.env`:
///   GITHUB_OWNER=tu-organizacion
///   GITHUB_REPO=nombre-repositorio
///
/// Flujo:
///   1. [checkForUpdate] → consulta GitHub API, compara versiones.
///   2. Si hay actualización → retorna [UpdateInfo].
///   3. [downloadUpdate] → descarga el APK con progreso.
///   4. [installUpdate] → abre el APK instalador del sistema.
class UpdateService {
  static const String _lastCheckKey = 'last_update_check_ms';
  static const Duration _checkInterval = Duration(hours: 12);

  static String get _owner =>
      dotenv.env['GITHUB_OWNER'] ?? '';
  static String get _repo =>
      dotenv.env['GITHUB_REPO'] ?? '';

  static String get _apiUrl =>
      'https://api.github.com/repos/$_owner/$_repo/releases/latest';

  /// Verifica si hay una nueva versión disponible.
  ///
  /// [force] omite el intervalo de caché de 12 h.
  /// Retorna [UpdateInfo] si hay actualización, o `null` si está al día.
  static Future<UpdateInfo?> checkForUpdate({bool force = false}) async {
    if (_owner.isEmpty || _repo.isEmpty) {
      print('⚠️ UpdateService: GITHUB_OWNER o GITHUB_REPO no configurados en .env');
      return null;
    }

    // Respetar el intervalo de verificación
    if (!force) {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
      final elapsed = DateTime.now().millisecondsSinceEpoch - lastCheck;
      if (elapsed < _checkInterval.inMilliseconds) {
        print('⏭️ UpdateService: verificación reciente, omitiendo (${elapsed ~/ 3600000}h < 12h)');
        return null;
      }
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'CaracT-Movil-App',
        },
      ));

      final response = await dio.get(_apiUrl);

      // Guardar timestamp de verificación
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          _lastCheckKey, DateTime.now().millisecondsSinceEpoch);

      final data = response.data as Map<String, dynamic>;

      // Limpiar tag: "v1.2.3" → "1.2.3"
      final rawTag = data['tag_name'] as String? ?? '';
      final latestVersion = rawTag.replaceFirst(RegExp(r'^v'), '');

      if (latestVersion.isEmpty) return null;

      if (!_isNewerVersion(latestVersion, currentVersion)) {
        print('✅ UpdateService: versión actual ($currentVersion) está al día');
        return null;
      }

      // Buscar asset .apk en el release
      final assets = (data['assets'] as List?) ?? [];
      final apkAsset = assets.cast<Map<String, dynamic>>().firstWhere(
            (a) => (a['name'] as String).toLowerCase().endsWith('.apk'),
            orElse: () => {},
          );

      final downloadUrl = apkAsset['browser_download_url'] as String?;

      print('🆕 UpdateService: nueva versión disponible: $latestVersion (actual: $currentVersion)');

      return UpdateInfo(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        releaseName: data['name'] as String? ?? latestVersion,
        releaseNotes: data['body'] as String? ?? '',
        downloadUrl: downloadUrl,
      );
    } on DioException catch (e) {
      print('⚠️ UpdateService: error consultando GitHub API: ${e.message}');
      return null;
    } catch (e) {
      print('⚠️ UpdateService: error inesperado: $e');
      return null;
    }
  }

  /// Descarga el APK en el directorio temporal del dispositivo.
  ///
  /// [onProgress] recibe (bytesRecibidos, totalBytes).
  /// [cancelToken] permite cancelar la descarga.
  /// Retorna la ruta del archivo descargado.
  static Future<String> downloadUpdate(
    String url, {
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final dir = await getTemporaryDirectory();
    final savePath = '${dir.path}/caract_movil_update.apk';

    // Eliminar descarga previa si existe
    final file = File(savePath);
    if (await file.exists()) await file.delete();

    final dio = Dio(BaseOptions(
      receiveTimeout: const Duration(minutes: 10),
    ));

    await dio.download(
      url,
      savePath,
      onReceiveProgress: onProgress,
      cancelToken: cancelToken,
      options: Options(
        headers: {'User-Agent': 'CaracT-Movil-App'},
      ),
    );

    print('✅ UpdateService: APK descargado en $savePath');
    return savePath;
  }

  /// Abre el instalador nativo del sistema para el APK descargado.
  static Future<void> installUpdate(String apkPath) async {
    // open_file abre el APK con el instalador del sistema.
    // La actividad requiere el permiso REQUEST_INSTALL_PACKAGES.
    // El resultado se ignora porque la app puede cerrarse durante la instalación.
    try {
      // Importamos dinámicamente para que no falle en iOS
      if (Platform.isAndroid) {
        await _openApkFile(apkPath);
      }
    } catch (e) {
      print('❌ UpdateService: error abriendo APK: $e');
      rethrow;
    }
  }

  static Future<void> _openApkFile(String path) async {
    // open_file se importa a nivel de módulo para que tree-shaking funcione.
    // El import concreto está en update_dialog.dart donde se llama install.
    // Este método existe como punto de extensión.
    throw UnsupportedError(
        'Llama a OpenFile.open(path) desde update_dialog.dart directamente');
  }

  /// Compara dos versiones semánticas. Retorna `true` si [latest] > [current].
  static bool _isNewerVersion(String latest, String current) {
    try {
      final l = _parseParts(latest);
      final c = _parseParts(current);
      for (int i = 0; i < 3; i++) {
        if (l[i] > c[i]) return true;
        if (l[i] < c[i]) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static List<int> _parseParts(String version) {
    // Solo tomar la parte antes de '+' (build number)
    final clean = version.split('+').first;
    final parts = clean.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    while (parts.length < 3) parts.add(0);
    return parts;
  }
}
