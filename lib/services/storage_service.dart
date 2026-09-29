import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static bool _isInitialized = false;
  static Box<String>? _box;

  static const _draftKey = 'survey_draft';
  static const _hiveKeyAlias = 'hive_aes_key';

  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(dir.path);

      final cipher = await _buildCipher();
      try {
        _box = await Hive.openBox<String>('app_data', encryptionCipher: cipher);
      } catch (_) {
        // Caja sin cifrar de versión anterior — borrar y recrear cifrada.
        await Hive.deleteBoxFromDisk('app_data');
        _box = await Hive.openBox<String>('app_data', encryptionCipher: cipher);
      }

      _isInitialized = true;
      if (kDebugMode) print('Hive cifrado inicializado en: ${dir.path}');
    } catch (e) {
      if (kDebugMode) print('Error inicializando Hive: $e');
      rethrow;
    }
  }

  static Future<HiveAesCipher> _buildCipher() async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    var keyStr = await storage.read(key: _hiveKeyAlias);
    if (keyStr == null) {
      final key = Hive.generateSecureKey();
      keyStr = base64UrlEncode(key);
      await storage.write(key: _hiveKeyAlias, value: keyStr);
    }
    return HiveAesCipher(base64Url.decode(keyStr));
  }

  static Future<void> saveDraft(Map<String, dynamic> data) async {
    try {
      await _box?.put(_draftKey, jsonEncode(data));
    } catch (e) {
      if (kDebugMode) print('Error guardando borrador: $e');
    }
  }

  static Map<String, dynamic>? loadDraft() {
    try {
      final raw = _box?.get(_draftKey);
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('Error cargando borrador: $e');
      return null;
    }
  }

  static Future<void> clearDraft() async {
    await _box?.delete(_draftKey);
  }
}
