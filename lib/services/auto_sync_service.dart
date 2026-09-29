import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'notification_service.dart';
import 'supabase_service.dart';

/// Resultado al encolar / enviar una encuesta.

/// La misma encuesta (misma sede y misma fecha de creación) ya se envió o
/// está en cola. El borrador local es una copia y puede descartarse.
class DuplicateSurveyException implements Exception {
  const DuplicateSurveyException();

  @override
  String toString() =>
      'Esta encuesta ya ha sido enviada o está en proceso de envío';
}

class SyncEnqueueResult {
  final String surveyId;
  /// Encuesta confirmada en Supabase y retirada de la cola local.
  final bool synced;

  const SyncEnqueueResult({required this.surveyId, required this.synced});
}

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

  /// Encola la encuesta localmente e intenta enviarla de inmediato si hay red.
  ///
  /// La encuesta solo se elimina de la cola local tras confirmación en Supabase.
  static Future<SyncEnqueueResult> scheduleImmediateSync(
    Map<String, dynamic> surveyData,
  ) async {
    try {
      final surveyId =
          surveyData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

      if (await _isDuplicateSurvey(surveyData)) {
        if (kDebugMode) {
          print('⚠️ Encuesta duplicada detectada, evitando envío múltiple');
        }
        throw const DuplicateSurveyException();
      }

      surveyData['id'] = surveyId;
      surveyData['timestamp'] = DateTime.now().toIso8601String();
      surveyData['syncStatus'] = 'pending';
      surveyData['attempts'] = 0;
      surveyData['priority'] = 'high';

      await _savePendingSurvey(surveyData);

      var synced = false;
      if (await _hasInternetConnection()) {
        try {
          await _sendSurvey(surveyData);
          await _markSurveyAsSynced(surveyId);
          synced = true;
        } catch (e) {
          print('⚠️ Envío inmediato falló, encuesta permanece en cola: $e');
          await _persistPendingSurveys(await _getPendingSurveys());
        }
      }

      print(synced
          ? '✅ Encuesta $surveyId enviada a Supabase'
          : '📤 Encuesta $surveyId guardada en cola local');

      return SyncEnqueueResult(surveyId: surveyId, synced: synced);
    } catch (e) {
      print('❌ Error programando sincronización: $e');
      rethrow;
    }
  }

  /// Indica si hay conectividad a internet (ping real).
  static Future<bool> hasInternetConnection() => _hasInternetConnection();

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
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 8);
      try {
        final request = await client.getUrl(Uri.parse('https://www.google.com'))
          ..followRedirects = false;
        final response =
            await request.close().timeout(const Duration(seconds: 8));
        await response.drain<void>();
        // Cualquier respuesta HTTP (incluida redirección 30x) prueba que hay red.
        return response.statusCode < 500;
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
      final stillPending = <Map<String, dynamic>>[];

      for (var surveyData in pendingSurveys) {
        try {
          await _sendSurvey(surveyData);
          await _markSurveyAsSent(surveyData);
          successCount++;
          print('✅ Encuesta ${surveyData['id']} enviada exitosamente');
        } catch (e) {
          failureCount++;
          print('❌ Error enviando encuesta ${surveyData['id']}: $e');

          surveyData['attempts'] = (surveyData['attempts'] ?? 0) + 1;

          if (surveyData['attempts'] >= 3) {
            surveyData['syncStatus'] = 'error';
            surveyData['lastError'] = e.toString();
          }
          stillPending.add(surveyData);
        }
      }

      await _persistPendingSurveys(stillPending);

      if (successCount > 0) {
        await _updateSyncStatus({
          'lastSuccessfulSync': DateTime.now().toIso8601String(),
        });
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

      final payload = _payloadForSync(surveyData);
      await SupabaseService.saveSurvey(payload);

      try {
        await NotificationService.showFormSubmittedNotification(
          institutionName: _institutionName(surveyData),
        );
      } catch (notificationError) {
        print('⚠️ Error enviando notificación push: $notificationError');
      }

      print('✅ Encuesta enviada exitosamente a Supabase');
    } catch (e) {
      print('❌ Error enviando encuesta: $e');
      rethrow;
    }
  }

  static Future<void> _persistPendingSurveys(
    List<Map<String, dynamic>> pendingSurveys,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingSurveysKey, jsonEncode(pendingSurveys));
      await _updateSyncStatus({
        'pendingCount': pendingSurveys.length,
        'lastUpdate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error persistiendo cola de encuestas: $e');
    }
  }

  /// Elimina metadatos de sincronización antes de enviar a Supabase.
  static Map<String, dynamic> _payloadForSync(
    Map<String, dynamic> surveyData,
  ) {
    final copy = Map<String, dynamic>.from(surveyData);
    for (final key in ['syncStatus', 'attempts', 'priority', 'lastError']) {
      copy.remove(key);
    }
    return copy;
  }

  /// Nombre de institución/sede para notificaciones (unificado y legacy).
  static String _institutionName(Map<String, dynamic> surveyData) {
    final payload = _surveyPayload(surveyData);
    if (payload == null) return 'Institución';

    final institutionalInfo = payload['institutionalInfo'] as Map<String, dynamic>?;
    final informacionInstitucional =
        payload['informacionInstitucional'] as Map<String, dynamic>?;

    return payload['schoolName'] as String? ??
        payload['principalInstitution'] as String? ??
        institutionalInfo?['institutionName'] as String? ??
        informacionInstitucional?['nombreInstitucion'] as String? ??
        surveyData['institutionName'] as String? ??
        'Institución';
  }

  /// Extrae el cuerpo de la encuesta (sin envoltorio legacy `data`/`datos`).
  static Map<String, dynamic>? _surveyPayload(Map<String, dynamic> surveyData) {
    final nested = surveyData['data'] ?? surveyData['datos'];
    if (nested is Map<String, dynamic>) return nested;
    if (surveyData['formType'] == 'unified') return surveyData;
    if (surveyData.containsKey('schoolName') ||
        surveyData.containsKey('institutionalInfo')) {
      return surveyData;
    }
    return null;
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

  /// Retorna todas las encuestas pendientes en cola local.
  static Future<List<Map<String, dynamic>>> getPendingSurveys() =>
      _getPendingSurveys();

  /// Fuerza el procesamiento de encuestas pendientes (para pruebas)
  static Future<void> forceSyncNow() async {
    print('🔄 Forzando sincronización manual...');
    await _processPendingSurveys();
  }

  /// Verifica si una encuesta es duplicada basándose en datos clave
  static Future<bool> _isDuplicateSurvey(Map<String, dynamic> newSurveyData) async {
    try {
      final newPayload = _surveyPayload(newSurveyData);
      if (newPayload == null) return false;

      final newSignature = _createSurveySignature(newPayload);
      final pendingSurveys = await _getPendingSurveys();

      for (var survey in pendingSurveys) {
        final existingPayload = _surveyPayload(survey);
        if (existingPayload == null) continue;

        if (_createSurveySignature(existingPayload) != newSignature) continue;

        final existingTimestamp = DateTime.tryParse(survey['timestamp'] ?? '');
        if (existingTimestamp != null) {
          final timeDifference = DateTime.now().difference(existingTimestamp);
          if (timeDifference.inHours < 2) {
            print(
              '🔍 Encuesta duplicada detectada - misma sede en las últimas 2 horas',
            );
            return true;
          }
        }
      }

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

  /// Crea una firma única para identificar encuestas (unificado y legacy).
  static String _createSurveySignature(Map<String, dynamic> surveyData) {
    try {
      final generalInfo = surveyData['generalInfo'] as Map<String, dynamic>?;
      final institutionalInfo =
          surveyData['institutionalInfo'] as Map<String, dynamic>?;

      final schoolName = surveyData['schoolName'] as String? ??
          institutionalInfo?['institutionName'] as String? ??
          '';
      final municipality = surveyData['municipality'] as String? ??
          generalInfo?['municipality'] as String? ??
          '';
      final daneCode = surveyData['daneCode'] as String? ??
          institutionalInfo?['dane'] as String? ??
          '';
      final surveyDate = surveyData['date']?.toString() ??
          generalInfo?['date']?.toString() ??
          '';

      final signature =
          '$schoolName|$municipality|$daneCode|$surveyDate'.toLowerCase();
      return signature.replaceAll(RegExp(r'\s+'), '');
    } catch (e) {
      print('❌ Error creando firma: $e');
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  /// Marca una encuesta como enviada exitosamente
  static Future<void> _markSurveyAsSent(Map<String, dynamic> surveyData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sentSurveys = prefs.getStringList('sent_surveys_signatures') ?? [];

      final payload = _surveyPayload(surveyData);
      if (payload == null) return;

      final signature = _createSurveySignature(payload);

      if (!sentSurveys.contains(signature)) {
        sentSurveys.add(signature);

        if (sentSurveys.length > 50) {
          sentSurveys.removeAt(0);
        }

        await prefs.setStringList('sent_surveys_signatures', sentSurveys);
        print('✅ Encuesta marcada como enviada exitosamente');
      }
    } catch (e) {
      print('❌ Error marcando encuesta como enviada: $e');
    }
  }
}
