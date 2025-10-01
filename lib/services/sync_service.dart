import 'package:connectivity_plus/connectivity_plus.dart';
import 'storage_service.dart';
import 'zip_export_service.dart';
import 'email_service.dart';
import '../models/survey_state.dart';

class SyncService {
  static final Connectivity _connectivity = Connectivity();
  
  static Future<bool> hasInternetConnection() async {
    final result = await _connectivity.checkConnectivity();
    // Verificar si hay alguna conexión disponible en la lista
    return result.any((connectivity) => connectivity != ConnectivityResult.none);
  }

  static Future<void> syncPendingSurveys() async {
    if (!await hasInternetConnection()) {
      return;
    }

    final pendingSurveys = await StorageService.getPendingSurveys();
    
    for (var survey in pendingSurveys) {
      try {
        // Convertir datos JSON a SurveyState
        final surveyState = SurveyState.fromJson(survey);
        
        // Crear archivo ZIP con CSV y fotos
        final zipFile = await ZipExportService.createZipFile(surveyState);
        
        if (zipFile != null) {
          // Enviar ZIP por email
          final success = await EmailService.sendSurveyQuick(zipFile, surveyState);
          
          if (success) {
            // Marcar como sincronizada
            await StorageService.markSurveyAsSynced(survey['id']);
            
            // Limpiar archivo ZIP temporal
            try {
              await zipFile.delete();
            } catch (e) {
              print('⚠️ Error eliminando archivo temporal: $e');
            }
            
            print('✅ Encuesta ${survey['id']} sincronizada exitosamente con ZIP');
          } else {
            print('❌ Error enviando ZIP para encuesta ${survey['id']}');
          }
        } else {
          print('❌ Error creando ZIP para encuesta ${survey['id']}');
        }
      } catch (e) {
        print('Error syncing survey ${survey['id']}: $e');
      }
    }
  }

  static Stream<List<ConnectivityResult>> get connectivityStream {
    return _connectivity.onConnectivityChanged;
  }
}
