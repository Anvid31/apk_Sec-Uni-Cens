import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import '../models/survey_state.dart';
import 'notification_service.dart';
import 'postgres_service.dart';

/// Servicio de sincronización automática simplificado y compatible
/// 
/// Funcionalidades:
/// - Sincronización automática al enviar formularios
/// - Monitoreo de conectividad
/// - Persistencia de datos pendientes
/// - Reintentos automáticos
/// - Funciona sin WorkManager para mayor compatibilidad
class AutoSyncService {
  static const String _pendingSurveysKey = 'pending_surveys';
  static const String _syncStatusKey = 'sync_status';
  static bool _isInitialized = false;
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  static Timer? _periodicTimer;
  
  /// Inicializa el servicio de sincronización automática
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Inicializar monitoreo de conectividad
      await _startConnectivityMonitoring();
      
      // Inicializar verificación periódica cada 5 minutos
      _startPeriodicCheck();
      
      _isInitialized = true;
      if (kDebugMode) print('🚀 AutoSyncService inicializado exitosamente (versión compatible)');
    } catch (e) {
      if (kDebugMode) print('❌ Error inicializando AutoSyncService: $e');
      rethrow;
    }
  }

  /// Programa una encuesta para envío inmediato
  static Future<void> scheduleImmediateSync(Map<String, dynamic> surveyData) async {
    try {
      // Asignar ID único y timestamp
      final surveyId = surveyData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      // VALIDACIÓN ANTI-DUPLICADOS: Verificar si ya existe una encuesta con los mismos datos
      if (await _isDuplicateSurvey(surveyData)) {
        if (kDebugMode) print('⚠️ Encuesta duplicada detectada, evitando envío múltiple');
        throw Exception('Esta encuesta ya ha sido enviada o está en proceso de envío');
      }
      
      surveyData['id'] = surveyId;
      surveyData['timestamp'] = DateTime.now().toIso8601String();
      surveyData['syncStatus'] = 'pending';
      surveyData['attempts'] = 0;
      surveyData['priority'] = 'high';
      
      // Guardar en almacenamiento persistente
      await _savePendingSurvey(surveyData);
      
      // Intentar envío inmediato si hay conectividad
      if (await _hasInternetConnection()) {
        // Usar Future.microtask para no bloquear la UI
        Future.microtask(() => _processPendingSurveys());
      }
      
      print('📤 Encuesta programada para envío automático');
    } catch (e) {
      print('❌ Error programando sincronización: $e');
      rethrow;
    }
  }

  /// Inicia el monitoreo de conectividad mejorado
  static Future<void> _startConnectivityMonitoring() async {
    try {
      // Cancelar suscripción anterior si existe
      await _connectivitySubscription?.cancel();
      
      final connectivity = Connectivity();
      
      // Suscribirse a cambios de conectividad
      _connectivitySubscription = connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) async {
          print('� Cambio de conectividad detectado: $results');
          
          // Verificar si hay alguna conexión disponible
          final hasConnection = results.any((result) => result != ConnectivityResult.none);
          
          if (hasConnection) {
            print('✅ Conexión detectada, procesando encuestas pendientes...');
            
            // Esperar un momento para que la conexión se estabilice
            await Future.delayed(const Duration(seconds: 3));
            
            // Verificar nuevamente la conectividad real
            if (await _hasInternetConnection()) {
              // Procesar encuestas pendientes de forma asíncrona
              Future.microtask(() => _processPendingSurveys());
            }
          } else {
            print('❌ Sin conexión detectada');
            await _updateSyncStatus({'hasConnectivity': false});
          }
        },
        onError: (error) {
          print('❌ Error en monitoreo de conectividad: $error');
        },
      );
      
      // Verificación inicial
      final initialResult = await connectivity.checkConnectivity();
      print('🔍 Estado inicial de conectividad: $initialResult');
      
    } catch (e) {
      print('❌ Error iniciando monitoreo de conectividad: $e');
    }
  }

  /// Mejora en la verificación periódica
  static void _startPeriodicCheck() {
    // Cancelar timer anterior si existe
    _periodicTimer?.cancel();
    
    // Timer cada 10 minutos (más frecuente)
    _periodicTimer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      try {
        print('⏰ Verificación periódica: ${DateTime.now()}');
        
        if (await _hasInternetConnection()) {
          final pendingSurveys = await _getPendingSurveys();
          if (pendingSurveys.isNotEmpty) {
            print('⏰ Verificación periódica: procesando ${pendingSurveys.length} encuestas pendientes');
            await _processPendingSurveys();
          }
        }
      } catch (e) {
        print('❌ Error en verificación periódica: $e');
      }
    });
  }

  /// Guarda una encuesta como pendiente
  static Future<void> _savePendingSurvey(Map<String, dynamic> surveyData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingSurveys = await _getPendingSurveys();
      
      // Agregar nueva encuesta
      pendingSurveys.add(surveyData);
      
      // Guardar en SharedPreferences
      await prefs.setString(_pendingSurveysKey, jsonEncode(pendingSurveys));
      
      // Actualizar estado de sincronización
      await _updateSyncStatus({
        'pendingCount': pendingSurveys.length,
        'lastUpdate': DateTime.now().toIso8601String(),
      });
      
      print('💾 Encuesta guardada como pendiente (Total: ${pendingSurveys.length})');
    } catch (e) {
      print('❌ Error guardando encuesta pendiente: $e');
      rethrow;
    }
  }

  /// Obtiene todas las encuestas pendientes
  static Future<List<Map<String, dynamic>>> _getPendingSurveys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_pendingSurveysKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Error obteniendo encuestas pendientes: $e');
      return [];
    }
  }

  /// Marca una encuesta como sincronizada
  static Future<void> _markSurveyAsSynced(String surveyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingSurveys = await _getPendingSurveys();
      
      // Encontrar la encuesta a remover y obtener su firma antes de eliminarla
      Map<String, dynamic>? surveyToRemove;
      for (var survey in pendingSurveys) {
        if (survey['id'] == surveyId) {
          surveyToRemove = survey;
          break;
        }
      }
      
      // Marcar encuesta como enviada exitosamente antes de removerla
      if (surveyToRemove != null) {
        await _markSurveyAsSent(surveyToRemove);
      }
      
      // Remover encuesta sincronizada
      pendingSurveys.removeWhere((survey) => survey['id'] == surveyId);
      
      // Actualizar almacenamiento
      await prefs.setString(_pendingSurveysKey, jsonEncode(pendingSurveys));
      
      // Actualizar estado
      await _updateSyncStatus({
        'pendingCount': pendingSurveys.length,
        'lastSuccessfulSync': DateTime.now().toIso8601String(),
      });
      
      print('✅ Encuesta $surveyId marcada como sincronizada');
    } catch (e) {
      print('❌ Error marcando encuesta como sincronizada: $e');
    }
  }

  /// Actualiza el estado de sincronización
  static Future<void> _updateSyncStatus(Map<String, dynamic> statusUpdate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentStatus = await getSyncStatus();
      
      // Combinar estado actual con actualización
      final newStatus = {...currentStatus, ...statusUpdate};
      
      await prefs.setString(_syncStatusKey, jsonEncode(newStatus));
    } catch (e) {
      print('❌ Error actualizando estado de sincronización: $e');
    }
  }

  /// Obtiene el estado actual de sincronización
  static Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_syncStatusKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return {
          'pendingCount': 0,
          'lastUpdate': null,
          'lastSuccessfulSync': null,
          'isRunning': false,
          'hasConnectivity': await _hasInternetConnection(),
        };
      }
      
      final status = jsonDecode(jsonString) as Map<String, dynamic>;
      status['hasConnectivity'] = await _hasInternetConnection();
      
      return status;
    } catch (e) {
      print('❌ Error obteniendo estado de sincronización: $e');
      return {
        'pendingCount': 0,
        'lastUpdate': null,
        'lastSuccessfulSync': null,
        'isRunning': false,
        'hasConnectivity': false,
        'error': e.toString(),
      };
    }
  }

  /// Verifica conectividad real con ping a servidor
  static Future<bool> _hasInternetConnection() async {
    try {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      
      // Verificar si hay alguna conexión disponible
      if (!result.any((connectivity) => connectivity != ConnectivityResult.none)) {
        return false;
      }
      
      // Verificar conectividad real con HTTP request
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse('https://www.google.com'))
          ..followRedirects = false;
        final response = await request.close();
        await response.drain();
        return response.statusCode == 200;
      } catch (e) {
        return false;
      } finally {
        client.close();
      }
    } catch (e) {
      print('❌ Error verificando conectividad real: $e');
      return false;
    }
  }

  /// Procesa todas las encuestas pendientes
  static Future<void> _processPendingSurveys() async {
    try {
      final pendingSurveys = await _getPendingSurveys();
      
      if (pendingSurveys.isEmpty) {
        print('📭 No hay encuestas pendientes para procesar');
        return;
      }

      print('📦 Procesando ${pendingSurveys.length} encuestas pendientes...');

      // Actualizar estado como "ejecutándose"
      await _updateSyncStatus({'isRunning': true});

      int successCount = 0;
      int failureCount = 0;

      for (var surveyData in pendingSurveys) {
        try {
          await _sendSurvey(surveyData);
          await _markSurveyAsSynced(surveyData['id']);
          successCount++;
          print('✅ Encuesta ${surveyData['id']} enviada exitosamente');
        } catch (e) {
          failureCount++;
          print('❌ Error enviando encuesta ${surveyData['id']}: $e');
          
          // Incrementar contador de intentos
          surveyData['attempts'] = (surveyData['attempts'] ?? 0) + 1;
          
          // Si ha fallado muchas veces, marcar como error
          if (surveyData['attempts'] >= 3) {
            surveyData['syncStatus'] = 'error';
            surveyData['lastError'] = e.toString();
          }
        }
      }

      // Actualizar estado final
      await _updateSyncStatus({
        'isRunning': false,
        'lastProcessingResult': {
          'success': successCount,
          'failures': failureCount,
          'timestamp': DateTime.now().toIso8601String(),
        }
      });

      print('📊 Procesamiento completado: $successCount éxitos, $failureCount fallos');
    } catch (e) {
      print('❌ Error procesando encuestas pendientes: $e');
      await _updateSyncStatus({'isRunning': false});
    }
  }

  /// Envía una encuesta específica
  static Future<void> _sendSurvey(Map<String, dynamic> surveyData) async {
    try {
      print('📤 Enviando encuesta: ${surveyData['id']}');
      
      // Guardar en PostgreSQL
      await PostgresService.saveSurvey(surveyData);

      /* Lógica de Email Anterior (Comentada)
      // Verificar configuración de email
      if (!EmailService.isEmailConfigured()) {
        throw Exception('Configuración de correo incompleta. Configure el correo en el archivo .env');
      }
      
      // Convertir datos JSON a SurveyState
      final surveyState = _createSurveyStateFromJson(surveyData);
      
      // Crear archivo ZIP con CSV y fotos
      final zipFile = await ZipExportService.createZipFile(surveyState);
      
      if (zipFile == null) {
        throw Exception('Error creando archivo ZIP con fotos');
      }
      
      // Enviar ZIP por email
      final success = await EmailService.sendSurveyQuick(zipFile, surveyState);
      
      if (!success) {
        throw Exception('Error enviando email con ZIP');
      }
      
      // Limpiar archivo ZIP temporal
      try {
        await zipFile.delete();
      } catch (e) {
        print('⚠️ Error eliminando archivo ZIP temporal: $e');
      }
      */
      
      // Enviar notificación push de éxito
      try {
        // Obtenemos el nombre de la institución del mapa directamente
        Map<String, dynamic>? institutionalInfo;
        
        if (surveyData['datos'] != null && surveyData['datos']['informacionInstitucional'] != null) {
           institutionalInfo = surveyData['datos']['informacionInstitucional'] as Map<String, dynamic>;
        } else if (surveyData['data'] != null && surveyData['data']['institutionalInfo'] != null) {
           institutionalInfo = surveyData['data']['institutionalInfo'] as Map<String, dynamic>;
        } else {
           institutionalInfo = (surveyData['institutionalInfo'] as Map<String, dynamic>?);
        }

        final institutionName = institutionalInfo?['institutionName'] 
                             ?? institutionalInfo?['nombreInstitucion'] 
                             ?? surveyData['nombreInstitucion']
                             ?? surveyData['institutionName'] 
                             ?? 'Institución';
        
        await NotificationService.showFormSubmittedNotification(
          institutionName: institutionName
        );
      } catch (notificationError) {
        print('⚠️ Error enviando notificación push: $notificationError');
        // No detener el proceso por errores de notificación
      }
      
      print('✅ Encuesta enviada exitosamente a PostgreSQL');
    } catch (e) {
      print('❌ Error enviando encuesta: $e');
      rethrow;
    }
  }
  
  /// Crea un SurveyState a partir de datos JSON
  static SurveyState _createSurveyStateFromJson(Map<String, dynamic> jsonData) {
    return SurveyState.fromJson(jsonData);
  }

  /// Limpia todas las encuestas pendientes (para pruebas)
  static Future<void> clearPendingSurveys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingSurveysKey);
      await _updateSyncStatus({
        'pendingCount': 0,
        'lastUpdate': DateTime.now().toIso8601String(),
      });
      print('🧹 Encuestas pendientes limpiadas');
    } catch (e) {
      print('❌ Error limpiando encuestas pendientes: $e');
    }
  }

  /// Detiene el servicio
  static Future<void> dispose() async {
    try {
      _connectivitySubscription?.cancel();
      _periodicTimer?.cancel();
      _isInitialized = false;
      print('🔄 AutoSyncService detenido');
    } catch (e) {
      print('❌ Error deteniendo AutoSyncService: $e');
    }
  }

  /// Fuerza el procesamiento de encuestas pendientes (para pruebas)
  static Future<void> forceSyncNow() async {
    print('🔄 Forzando sincronización manual...');
    await _processPendingSurveys();
  }

  /// Verifica si una encuesta es duplicada basándose en datos clave
  static Future<bool> _isDuplicateSurvey(Map<String, dynamic> newSurveyData) async {
    try {
      final pendingSurveys = await _getPendingSurveys();
      final newData = newSurveyData['data'] as Map<String, dynamic>?;
      
      if (newData == null) return false;
      
      // Crear firma única más robusta
      final newSignature = _createSurveySignature(newData);
      
      // Verificar contra encuestas pendientes con ventana de tiempo más amplia
      for (var survey in pendingSurveys) {
        final existingData = survey['data'] as Map<String, dynamic>?;
        if (existingData != null) {
          final existingSignature = _createSurveySignature(existingData);
          
          if (newSignature == existingSignature) {
            final existingTimestamp = DateTime.tryParse(survey['timestamp'] ?? '');
            if (existingTimestamp != null) {
              final timeDifference = DateTime.now().difference(existingTimestamp);
              
              // Aumentar ventana de detección a 2 horas
              if (timeDifference.inHours < 2) {
                print('🔍 Encuesta duplicada detectada - misma institución en las últimas 2 horas');
                return true;
              }
            }
          }
        }
      }

      // Verificar contra encuestas ya enviadas
      final prefs = await SharedPreferences.getInstance();
      final sentSurveys = prefs.getStringList('sent_surveys_signatures') ?? [];
      
      if (sentSurveys.contains(newSignature)) {
        print('🔍 Encuesta duplicada detectada - ya fue enviada anteriormente');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error verificando duplicados: $e');
      return false;
    }
  }

  /// Crea una firma única para identificar encuestas
  static String _createSurveySignature(Map<String, dynamic> surveyData) {
    try {
      final generalInfo = surveyData['generalInfo'] as Map<String, dynamic>?;
      final institutionalInfo = surveyData['institutionalInfo'] as Map<String, dynamic>?;
      
      // Combinar datos únicos de la institución
      final institutionName = institutionalInfo?['institutionName'] ?? '';
      final municipality = generalInfo?['municipality'] ?? '';
      final village = generalInfo?['village'] ?? '';
      final contact = generalInfo?['contact'] ?? '';
      
      // Crear hash simple pero efectivo
      final signature = '$institutionName|$municipality|$village|$contact'.toLowerCase();
      return signature.replaceAll(RegExp(r'\s+'), ''); // Remover espacios
    } catch (e) {
      print('❌ Error creando firma: $e');
      return DateTime.now().millisecondsSinceEpoch.toString(); // Fallback único
    }
  }

  /// Marca una encuesta como enviada exitosamente
  static Future<void> _markSurveyAsSent(Map<String, dynamic> surveyData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sentSurveys = prefs.getStringList('sent_surveys_signatures') ?? [];
      
      final data = surveyData['data'] as Map<String, dynamic>?;
      if (data != null) {
        final signature = _createSurveySignature(data);
        
        // Agregar a la lista de enviadas
        if (!sentSurveys.contains(signature)) {
          sentSurveys.add(signature);
          
          // Mantener solo las últimas 50 firmas para evitar crecimiento excesivo
          if (sentSurveys.length > 50) {
            sentSurveys.removeAt(0);
          }
          
          await prefs.setStringList('sent_surveys_signatures', sentSurveys);
          print('✅ Encuesta marcada como enviada exitosamente');
        }
      }
    } catch (e) {
      print('❌ Error marcando encuesta como enviada: $e');
    }
  }
}
