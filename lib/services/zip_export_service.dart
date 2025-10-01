import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/survey_state.dart';
import 'csv_export_service.dart';

/// Servicio para crear archivos ZIP con datos CSV y fotografías
class ZipExportService {
  
  /// Crea un archivo ZIP con CSV y todas las fotos de la encuesta
  static Future<File?> createZipFile(SurveyState surveyState) async {
    try {
      print('📦 Iniciando creación de archivo ZIP...');
      
      // Crear el archivo CSV primero
      final csvFile = await CsvExportService.createCsvFile(surveyState);
      if (csvFile == null) {
        throw Exception('Error generando archivo CSV');
      }
      
      // Crear el archivo ZIP
      final archive = Archive();
      
      // 1. Agregar CSV al ZIP
      final csvBytes = await csvFile.readAsBytes();
      final csvFileName = 'encuesta_${DateTime.now().millisecondsSinceEpoch}.csv';
      archive.addFile(ArchiveFile(csvFileName, csvBytes.length, csvBytes));
      print('✅ CSV agregado al ZIP: $csvFileName');
      
      // 2. Obtener todas las fotos de la encuesta
      final allPhotos = _getAllPhotosFromSurvey(surveyState);
      print('📸 Fotos encontradas: ${allPhotos.length}');
      
      // 3. Agregar fotos al ZIP en una sola carpeta "fotos"
      int photosAdded = 0;
      if (allPhotos.isNotEmpty) {
        for (int i = 0; i < allPhotos.length; i++) {
          final photoPath = allPhotos[i];
          
          if (photoPath.isEmpty) continue;
          
          final photoFile = File(photoPath);
          if (await photoFile.exists()) {
            try {
              final photoBytes = await photoFile.readAsBytes();
              final extension = path.extension(photoPath).toLowerCase();
              final fileName = 'fotos/foto_${i + 1}${extension}';
              
              archive.addFile(ArchiveFile(fileName, photoBytes.length, photoBytes));
              photosAdded++;
              print('📸 Foto agregada: $fileName');
            } catch (e) {
              print('⚠️ Error agregando foto $photoPath: $e');
            }
          } else {
            print('⚠️ Foto no encontrada: $photoPath');
          }
        }
      }
      
      // 5. Crear el archivo ZIP final
      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes == null) {
        throw Exception('Error creando archivo ZIP');
      }
      
      // 6. Guardar archivo ZIP en directorio temporal
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final institutionName = _sanitizeFileName(
        surveyState.institutionalInfo.institutionName ?? 'Institucion'
      );
      final zipFileName = 'encuesta_${institutionName}_$timestamp.zip';
      final zipFile = File('${tempDir.path}/$zipFileName');
      
      await zipFile.writeAsBytes(zipBytes);
      
      // 7. Limpiar archivo CSV temporal
      try {
        await csvFile.delete();
      } catch (e) {
        print('⚠️ Error eliminando CSV temporal: $e');
      }
      
      final zipSizeKB = (zipBytes.length / 1024).round();
      print('✅ ZIP creado exitosamente: $zipFileName (${zipSizeKB}KB, $photosAdded fotos)');
      
      return zipFile;
    } catch (e) {
      print('❌ Error creando archivo ZIP: $e');
      return null;
    }
  }
  
  /// Obtiene todas las fotos como una lista simple
  static List<String> _getAllPhotosFromSurvey(SurveyState surveyState) {
    final List<String> allPhotos = [];
    
    // Fotos del registro fotográfico
    final photoRecord = surveyState.photographicRecordInfo;
    
    // Recopilar todas las fotos no nulas
    if (photoRecord.generalPhoto != null && photoRecord.generalPhoto!.isNotEmpty) {
      allPhotos.add(photoRecord.generalPhoto!);
    }
    if (photoRecord.infrastructurePhoto != null && photoRecord.infrastructurePhoto!.isNotEmpty) {
      allPhotos.add(photoRecord.infrastructurePhoto!);
    }
    if (photoRecord.electricityPhoto != null && photoRecord.electricityPhoto!.isNotEmpty) {
      allPhotos.add(photoRecord.electricityPhoto!);
    }
    if (photoRecord.environmentPhoto != null && photoRecord.environmentPhoto!.isNotEmpty) {
      allPhotos.add(photoRecord.environmentPhoto!);
    }
    if (photoRecord.frontSchoolPhoto != null && photoRecord.frontSchoolPhoto!.isNotEmpty) {
      allPhotos.add(photoRecord.frontSchoolPhoto!);
    }
    if (photoRecord.classroomsPhoto != null && photoRecord.classroomsPhoto!.isNotEmpty) {
      allPhotos.add(photoRecord.classroomsPhoto!);
    }
    if (photoRecord.kitchenPhoto != null && photoRecord.kitchenPhoto!.isNotEmpty) {
      allPhotos.add(photoRecord.kitchenPhoto!);
    }
    if (photoRecord.diningRoomPhoto != null && photoRecord.diningRoomPhoto!.isNotEmpty) {
      allPhotos.add(photoRecord.diningRoomPhoto!);
    }
    
    return allPhotos;
  }
  
  /// Limpia nombres de archivo para evitar caracteres problemáticos
  static String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }
  
  /// Obtiene el tamaño estimado del ZIP antes de crearlo
  static Future<int> getEstimatedZipSize(SurveyState surveyState) async {
    try {
      int totalSize = 0;
      
      // Estimar tamaño del CSV (aproximado)
      totalSize += 50 * 1024; // ~50KB para el CSV
      
      // Sumar tamaños de fotos
      final allPhotos = _getAllPhotosFromSurvey(surveyState);
      for (var photoPath in allPhotos) {
        if (photoPath.isNotEmpty) {
          final photoFile = File(photoPath);
          if (await photoFile.exists()) {
            final fileSize = await photoFile.length();
            totalSize += fileSize;
          }
        }
      }
      
      // Agregar overhead del ZIP (aproximadamente 10%)
      totalSize = (totalSize * 1.1).round();
      
      return totalSize;
    } catch (e) {
      print('⚠️ Error estimando tamaño: $e');
      return 1024 * 1024; // 1MB por defecto
    }
  }
  
  /// Valida que se puedan crear archivos ZIP
  static Future<bool> canCreateZip() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final testFile = File('${tempDir.path}/test_zip_capability.tmp');
      
      // Crear archivo de prueba
      await testFile.writeAsString('test');
      
      // Intentar crear un ZIP simple
      final archive = Archive();
      final testBytes = await testFile.readAsBytes();
      archive.addFile(ArchiveFile('test.txt', testBytes.length, testBytes));
      
      final zipBytes = ZipEncoder().encode(archive);
      
      // Limpiar archivos de prueba
      await testFile.delete();
      
      return zipBytes != null;
    } catch (e) {
      print('⚠️ Error verificando capacidad ZIP: $e');
      return false;
    }
  }
}