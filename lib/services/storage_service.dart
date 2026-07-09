import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Inicialización de Hive para almacenamiento local embebido.
class StorageService {
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);
      _isInitialized = true;
      print('Hive inicializado correctamente en: ${appDocumentDir.path}');
    } catch (e) {
      print('Error al inicializar Hive: $e');
      rethrow;
    }
  }
}
