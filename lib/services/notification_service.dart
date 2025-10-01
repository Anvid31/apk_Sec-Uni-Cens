import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

/// Servicio para gestionar notificaciones push locales
/// 
/// Funcionalidades:
/// - Configuración inicial de notificaciones
/// - Envío de notificaciones inmediatas
/// - Notificaciones programadas
/// - Gestión de permisos
class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;

  /// Inicializa el servicio de notificaciones
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configuración para Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      // Configuración para iOS
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Configuración general
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Inicializar
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Solicitar permisos en Android 13+
      await _requestPermissions();

      _isInitialized = true;
      print('✅ NotificationService inicializado correctamente');
    } catch (e) {
      print('❌ Error inicializando NotificationService: $e');
      rethrow;
    }
  }

  /// Solicita permisos para notificaciones
  static Future<bool> _requestPermissions() async {
    try {
      // Permisos para Android 13+
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }

      // Permisos para iOS
      final iosPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return true; // Para plataformas que no requieren permisos explícitos
    } catch (e) {
      print('❌ Error solicitando permisos: $e');
      return false;
    }
  }

  /// Maneja cuando el usuario toca una notificación
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notificación tocada: ${response.payload}');
    
    // Al tocar la notificación, solo se elimina automáticamente
    // No se realiza ninguna acción adicional
    // La notificación desaparece de la bandeja de notificaciones
    
    // Opcional: Cancelar notificaciones relacionadas si es necesario
    try {
      // Parsear el payload para identificar el tipo de notificación
      final payload = response.payload ?? '';
      
      if (payload.startsWith('form_submitted')) {
        // Notificación de formulario enviado - solo se elimina
        debugPrint('Notificación de envío exitoso eliminada');
      } else if (payload.startsWith('form_scheduled')) {
        // Notificación de formulario programado - solo se elimina
        debugPrint('Notificación de programación eliminada');
      } else if (payload.startsWith('form_error')) {
        // Notificación de error - solo se elimina
        debugPrint('Notificación de error eliminada');
      }
    } catch (e) {
      debugPrint('Error procesando notificación tocada: $e');
    }
  }

  /// Envía una notificación inmediata de formulario enviado
  static Future<void> showFormSubmittedNotification({
    required String institutionName,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const notificationId = 1;
      
      // Configuración de la notificación para Android
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'form_submission_channel',
        'Envío de Formularios',
        channelDescription: 'Notificaciones para confirmación de envío de formularios',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
        color: Color(0xFF4CAF50),
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(''),
      );

      // Configuración de la notificación para iOS
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        sound: 'default',
        badgeNumber: 1,
      );

      // Configuración general
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Mostrar la notificación
      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        '📧 Formulario Enviado Exitosamente',
        'La caracterización de $institutionName ha sido enviada',
        platformChannelSpecifics,
        payload: 'form_submitted|$institutionName',
      );

      print('✅ Notificación de envío mostrada');
    } catch (e) {
      print('❌ Error mostrando notificación de envío: $e');
    }
  }

  /// Envía una notificación de formulario programado para envío
  static Future<void> showFormScheduledNotification({
    required String institutionName,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const notificationId = 2;
      
      // Configuración de la notificación para Android
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'form_scheduled_channel',
        'Formularios Programados',
        channelDescription: 'Notificaciones para formularios programados para envío',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/launcher_icon',
        color: Color(0xFF2196F3),
        playSound: true,
        enableVibration: true,
      );

      // Configuración de la notificación para iOS
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        sound: 'default',
      );

      // Configuración general
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Mostrar la notificación
      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        '⏰ Formulario Programado',
        'La caracterización de $institutionName se enviará automáticamente cuando haya conexión',
        platformChannelSpecifics,
        payload: 'form_scheduled|$institutionName',
      );

      print('✅ Notificación de programación mostrada');
    } catch (e) {
      print('❌ Error mostrando notificación de programación: $e');
    }
  }

  /// Envía una notificación de error en el envío
  static Future<void> showFormErrorNotification({
    required String institutionName,
    required String error,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const notificationId = 3;
      
      // Configuración de la notificación para Android
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'form_error_channel',
        'Errores de Envío',
        channelDescription: 'Notificaciones para errores en el envío de formularios',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
        color: Color(0xFFF44336),
        playSound: true,
        enableVibration: true,
      );

      // Configuración de la notificación para iOS
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        sound: 'default',
        badgeNumber: 1,
      );

      // Configuración general
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Mostrar la notificación
      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        '❌ Error en Envío',
        'No se pudo enviar la caracterización de $institutionName. Toque para reintentar.',
        platformChannelSpecifics,
        payload: 'form_error|$institutionName|$error',
      );

      print('✅ Notificación de error mostrada');
    } catch (e) {
      print('❌ Error mostrando notificación de error: $e');
    }
  }

  /// Cancela todas las notificaciones pendientes
  static Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('✅ Todas las notificaciones canceladas');
    } catch (e) {
      print('❌ Error cancelando notificaciones: $e');
    }
  }

  /// Cancela una notificación específica por ID
  static Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      print('✅ Notificación $id cancelada');
    } catch (e) {
      print('❌ Error cancelando notificación $id: $e');
    }
  }

  /// Verifica si las notificaciones están habilitadas
  static Future<bool> areNotificationsEnabled() async {
    try {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final enabled = await androidPlugin.areNotificationsEnabled();
        return enabled ?? false;
      }

      return true; // Asumir habilitadas en otras plataformas
    } catch (e) {
      print('❌ Error verificando estado de notificaciones: $e');
      return false;
    }
  }

  /// Abre la configuración de notificaciones de la app
  static Future<void> openNotificationSettings() async {
    try {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
    } catch (e) {
      print('❌ Error abriendo configuración de notificaciones: $e');
    }
  }
}
