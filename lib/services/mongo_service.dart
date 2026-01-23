import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../utils/image_helper.dart';

class MongoService {
  static const String _collectionName = 'surveys';
  static Db? _db;

  /// Conecta a la base de datos MongoDB
  static Future<void> connect() async {
    if (_db != null && _db!.isConnected) return;

    try {
      final connectionString = dotenv.env['MONGO_CONN_URL'];
      if (connectionString == null) {
        throw Exception('MONGO_CONN_URL no encontrada en el archivo .env');
      }
      
      _db = await Db.create(connectionString);
      await _db!.open();
      print('✅ Conexión a MongoDB establecida');
    } catch (e) {
      print('❌ Error conectando a MongoDB: $e');
      rethrow;
    }
  }

  /// Guarda una encuesta en MongoDB
  /// Incluye la conversión de imágenes locales a Base64 para almacenamiento
  static Future<void> saveSurvey(Map<String, dynamic> surveyData) async {
    try {
      if (_db == null || !_db!.isConnected) {
        await connect();
      }

      final collection = _db!.collection(_collectionName);

      // Copia profunda para no modificar el objeto original en memoria
      final Map<String, dynamic> dataToSave = json.decode(json.encode(surveyData));
      
      // Procesar imágenes: Convertir rutas locales a datos Base64
      // Se asume que los datos de la encuesta están en 'data' (estructura de FormSubmissionService)
      if (dataToSave.containsKey('data') && dataToSave['data'] is Map) {
          var innerData = dataToSave['data'];
          await _processImages(innerData);
      } else {
        // Estructura directa (si aplica)
        await _processImages(dataToSave);
      }

      // Agregar timestamp de subida si no existe
      if (!dataToSave.containsKey('uploadedAt')) {
        dataToSave['uploadedAt'] = DateTime.now().toIso8601String();
      }

      await collection.insert(dataToSave);
      print('✅ Encuesta guardada en MongoDB con ID: ${dataToSave['id'] ?? 'unknown'}');

    } catch (e) {
      print('❌ Error guardando encuesta en MongoDB: $e');
      rethrow;
    }
  }

  /// Procesa la sección de photographicRecordInfo para incrustar las imágenes
  static Future<void> _processImages(Map<String, dynamic> data) async {
    if (!data.containsKey('photographicRecordInfo')) return;

    final photos = data['photographicRecordInfo'];
    if (photos is! Map) return;

    final processedPhotos = <String, dynamic>{};

    for (var key in photos.keys) {
      final path = photos[key];
      // Si el path es null o no es string, guardar como está (null)
      if (path == null) {
        processedPhotos[key] = null;
        continue;
      }
      
      if (path is String && path.isNotEmpty) {
        try {
          // Usar ImageHelper para redimensionar, comprimir y convertir a Base64
          final base64Image = await ImageHelper.processImageForDb(path);
          
          if (base64Image != null) {
             processedPhotos[key] = {
               'fileName': path.split('/').last,
               'imagedata': base64Image,
               'originalPath': path,
               'contentType': 'image/jpeg' 
             };
          } else {
             processedPhotos[key] = {
               'error': 'Error procesando imagen o archivo no encontrado', 
               'originalPath': path
             };
          }
        } catch (e) {
          processedPhotos[key] = {
            'error': 'Error procesando archivo: $e', 
            'originalPath': path
          };
        }
      }
    }
    
    // Reemplazar la información original con la procesada (data es referencia al mapa dentro de dataToSave)
    data['photographicRecordInfo'] = processedPhotos;
  }
  
  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
