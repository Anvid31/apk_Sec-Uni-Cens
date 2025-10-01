import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/survey_state.dart';
import '../config/email_config.dart';

class EmailService {
  // Prevención de envíos duplicados
  static final Set<String> _sendingInProgress = <String>{};
  
  /// Envía el archivo ZIP al correo predefinido usando configuración centralizada
  static Future<bool> sendSurveyByEmail({
    required File zipFile,
    String? institutionName,
    String? municipio,
  }) async {
    // Crear identificador único para esta encuesta
    final surveyId = _createSurveyId(institutionName, municipio);
    
    // Verificar si ya se está enviando esta encuesta
    if (_sendingInProgress.contains(surveyId)) {
      print('⚠️ Ya se está enviando esta encuesta: $surveyId');
      return false;
    }
    
    // Verificar si ya fue enviada recientemente
    if (await _wasRecentlySent(surveyId)) {
      print('⚠️ Esta encuesta ya fue enviada recientemente: $surveyId');
      return false;
    }
    
    // Marcar como en proceso
    _sendingInProgress.add(surveyId);
    
    try {
      // Verificar que la configuración esté lista
      if (!EmailConfig.isConfigured) {
        print('❌ Error: Configuración de correo incompleta. Verifique las variables de entorno.');
        return false;
      }
      
      print('� Iniciando envío de correo para: $institutionName');
      print('   📍 ID único: $surveyId');
      
      // Detectar automáticamente el proveedor de email y configurar SMTP
      final emailProvider = _getEmailProvider(EmailConfig.senderEmail);
      
      // Intentar primero con STARTTLS (puerto 587)
      bool success = await _attemptSend(
        zipFile: zipFile,
        institutionName: institutionName,
        municipio: municipio,
        emailProvider: emailProvider,
        useSSL: false,
      );
      
      // Si falla, intentar con SSL directo (puerto 465)
      if (!success) {
        print('🔄 Primer intento falló, probando con SSL...');
        success = await _attemptSend(
          zipFile: zipFile,
          institutionName: institutionName,
          municipio: municipio,
          emailProvider: emailProvider,
          useSSL: true,
        );
      }
      
      if (success) {
        // Marcar como enviado exitosamente
        await _markAsSent(surveyId);
        print('✅ Correo enviado exitosamente a ${EmailConfig.destinationEmail}');
      }
      
      return success;
      
    } catch (e) {
      print('❌ Error general en envío de correo: $e');
      return false;
    } finally {
      // Liberar el lock independientemente del resultado
      _sendingInProgress.remove(surveyId);
    }
  }
  
  /// Intenta enviar con una configuración específica
  static Future<bool> _attemptSend({
    required File zipFile,
    String? institutionName,
    String? municipio,
    required Map<String, dynamic> emailProvider,
    required bool useSSL,
  }) async {
    try {
      final smtpServer = SmtpServer(
        emailProvider['smtp'],
        port: useSSL ? (emailProvider['sslPort'] ?? 465) : emailProvider['port'],
        username: EmailConfig.senderEmail,
        password: EmailConfig.senderPassword,
        ignoreBadCertificate: useSSL,
        ssl: useSSL,
        allowInsecure: useSSL,
      );

      print('📧 Configurando SMTP para envío...');
      print('   - Proveedor: ${emailProvider['name']}');
      print('   - Servidor: ${emailProvider['smtp']}:${useSSL ? emailProvider['sslPort'] ?? 465 : emailProvider['port']}');
      print('   - SSL: $useSSL');
      print('   - Usuario: ${EmailConfig.senderEmail}');
      print('   - Destino: ${EmailConfig.destinationEmail}');
      
      final message = Message()
        ..from = Address(EmailConfig.senderEmail, EmailConfig.senderName)
        ..recipients.add(EmailConfig.destinationEmail)
        ..subject = 'Caracterización de Sede Educativa - ${institutionName ?? 'Sede'} - ${municipio ?? ''}'
        ..text = _generateEmailBody(institutionName, municipio)
        ..html = _generateEmailHtml(institutionName, municipio)
        ..attachments.add(FileAttachment(zipFile));

      print('📤 Enviando correo...');
      await send(message, smtpServer);
      print('✅ Correo enviado exitosamente');
      return true;
      
    } catch (e) {
      print('❌ Error en intento de envío (SSL: $useSSL): $e');
      if (e.toString().contains('SocketException')) {
        print('🔍 Error de conexión - verificar conectividad');
      } else if (e.toString().contains('authentication')) {
        print('🔍 Error de autenticación - verificar credenciales');
      }
      return false;
    }
  }
  
  /// Crea un ID único para la encuesta basado en institución y timestamp
  static String _createSurveyId(String? institutionName, String? municipio) {
    final now = DateTime.now();
    final dayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final institutionKey = (institutionName ?? 'unknown').replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
    final municipioKey = (municipio ?? 'unknown').replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
    
    return '$dayKey-$institutionKey-$municipioKey';
  }
  
  /// Verifica si la encuesta fue enviada recientemente (últimas 2 horas)
  static Future<bool> _wasRecentlySent(String surveyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sentTimestamp = prefs.getInt('sent_$surveyId');
      
      if (sentTimestamp != null) {
        final sentTime = DateTime.fromMillisecondsSinceEpoch(sentTimestamp);
        final timeDifference = DateTime.now().difference(sentTime);
        
        // Considerar como duplicado si fue enviado en las últimas 2 horas
        return timeDifference.inHours < 2;
      }
      
      return false;
    } catch (e) {
      print('❌ Error verificando envío reciente: $e');
      return false;
    }
  }
  
  /// Marca la encuesta como enviada
  static Future<void> _markAsSent(String surveyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('sent_$surveyId', DateTime.now().millisecondsSinceEpoch);
      
      // Limpiar registros antiguos (más de 7 días)
      await _cleanupOldRecords();
    } catch (e) {
      print('❌ Error marcando como enviado: $e');
    }
  }
  
  /// Limpia registros de envíos antiguos
  static Future<void> _cleanupOldRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('sent_')).toList();
      final now = DateTime.now();
      
      for (final key in keys) {
        final timestamp = prefs.getInt(key);
        if (timestamp != null) {
          final recordTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          if (now.difference(recordTime).inDays > 7) {
            await prefs.remove(key);
            print('🧹 Eliminado registro antiguo: $key');
          }
        }
      }
    } catch (e) {
      print('❌ Error limpiando registros antiguos: $e');
    }
  }
    /// Método simplificado para envío rápido (solo requiere el archivo ZIP)
  static Future<bool> sendSurveyQuick(File zipFile, SurveyState surveyState) async {
    return await sendSurveyByEmail(
      zipFile: zipFile,
      institutionName: surveyState.institutionalInfo.institutionName,
      municipio: surveyState.generalInfo.municipality,
    );
  }
  
  /// Verifica si la configuración de correo está lista para usar
  static bool isEmailConfigured() {
    return EmailConfig.isConfigured;
  }
  
  /// Obtiene el mensaje de ayuda para configurar el correo
  static String getConfigurationHelp() {
    return '''
🔧 Para configurar el envío de correos, asegúrese de tener un archivo .env con:

DESTINATION_EMAIL=correo_destino@ejemplo.com
SENDER_EMAIL=correo_envio@gmail.com
SENDER_PASSWORD=contraseña_aplicacion
SENDER_NAME=Equipo CaracT

📧 Notas importantes:
- Para Gmail: Use una "Contraseña de aplicación" (no su contraseña normal)
- Para Outlook: Puede usar su contraseña normal
- Para otros proveedores: Consulte la documentación específica

🔐 Generar contraseña de aplicación en Gmail:
1. Vaya a su cuenta de Google
2. Seguridad → Verificación en 2 pasos
3. Contraseñas de aplicaciones → Generar
4. Use esa contraseña en SENDER_PASSWORD
''';
  }
  
  /// Comparte el archivo usando el sistema nativo de compartir
  static Future<void> shareZipFile(File zipFile, {String? institutionName}) async {
    try {
      final xFile = XFile(zipFile.path);
      await Share.shareXFiles(
        [xFile],
        text: 'Caracterización de sede educativa: ${institutionName ?? 'Sede'}\n\nGenerado con la aplicación CaracT Móvil',
        subject: 'Caracterización de Sede Educativa - ${institutionName ?? 'Sede'}',
      );
    } catch (e) {
      print('Error compartiendo archivo: $e');
    }
  }

  /// Genera el cuerpo del correo en texto plano
  static String _generateEmailBody(String? institutionName, String? municipio) {
    return '''
Estimado/a usuario/a,

Adjunto encontrará la caracterización completa de la sede educativa realizada mediante la aplicación CaracT Móvil.

Detalles de la caracterización:
- Institución: ${institutionName ?? 'No especificado'}
- Municipio: ${municipio ?? 'No especificado'}
- Fecha de generación: ${DateTime.now().toLocal().toString().split('.')[0]}

El archivo ZIP contiene:
- Archivo CSV con toda la información recopilada
- Fotografías de la sede educativa organizadas por categorías

Esta información ha sido recopilada siguiendo los protocolos establecidos para la caracterización de sedes educativas rurales.

Para cualquier consulta o aclaración, no dude en contactarnos.

Atentamente,
Equipo CaracT Móvil
''';
  }
  
  /// Genera el cuerpo del correo en HTML
  static String _generateEmailHtml(String? institutionName, String? municipio) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; border-radius: 5px; margin-bottom: 20px; }
        .content { line-height: 1.6; color: #333; }
        .details { background-color: #f9f9f9; padding: 15px; border-left: 4px solid #4CAF50; margin: 20px 0; }
        .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; color: #666; font-size: 14px; }
        .highlight { color: #4CAF50; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 CaracT Móvil</h1>
            <p>Caracterización de Sede Educativa</p>
        </div>
        
        <div class="content">
            <p>Estimado/a usuario/a,</p>
            
            <p>Adjunto encontrará la caracterización completa de la sede educativa realizada mediante la aplicación <span class="highlight">CaracT Móvil</span>.</p>
            
            <div class="details">
                <h3>📋 Detalles de la caracterización:</h3>
                <ul>
                    <li><strong>Institución:</strong> ${institutionName ?? 'No especificado'}</li>
                    <li><strong>Municipio:</strong> ${municipio ?? 'No especificado'}</li>
                    <li><strong>Fecha de generación:</strong> ${DateTime.now().toLocal().toString().split('.')[0]}</li>
                </ul>
            </div>
            
            <h3>📁 Contenido del archivo ZIP:</h3>
            <ul>
                <li>📄 <strong>Archivo CSV</strong> con toda la información recopilada</li>
                <li>📸 <strong>Fotografías</strong> de la sede educativa organizadas por categorías</li>
            </ul>
            
            <p>Esta información ha sido recopilada siguiendo los protocolos establecidos para la caracterización de sedes educativas rurales.</p>
            
            <p>Para cualquier consulta o aclaración, no dude en contactarnos.</p>
        </div>
        
        <div class="footer">
            <p><strong>Atentamente,</strong><br>
            Equipo CaracT Móvil</p>
            <p><em>Sistema de Caracterización de Sedes Educativas</em></p>
        </div>
    </div>
</body>
</html>
''';
  }
  
  /// Valida una dirección de correo electrónico
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Configuración rápida para diferentes proveedores de correo
  static Map<String, Map<String, dynamic>> getEmailProviders() {
    return {
      'Gmail': {
        'smtp': 'smtp.gmail.com',
        'port': 587,
        'help': 'Usa tu email de Gmail y una contraseña de aplicación'
      },
      'Outlook/Hotmail': {
        'smtp': 'smtp-mail.outlook.com',
        'port': 587,
        'help': 'Usa tu email de Outlook/Hotmail y contraseña normal'
      },
      'Yahoo': {
        'smtp': 'smtp.mail.yahoo.com',
        'port': 587,
        'help': 'Usa tu email de Yahoo y una contraseña de aplicación'
      },
    };
  }

  /// Detecta automáticamente el proveedor de email basado en la dirección
  static Map<String, dynamic> _getEmailProvider(String email) {
    final domain = email.toLowerCase().split('@').last;
    
    switch (domain) {
      case 'gmail.com':
        return {
          'name': 'Gmail',
          'smtp': 'smtp.gmail.com',
          'port': 587,
          'sslPort': 465,
        };
      case 'outlook.com':
      case 'hotmail.com':
      case 'live.com':
        return {
          'name': 'Outlook',
          'smtp': 'smtp-mail.outlook.com',
          'port': 587,
          'sslPort': 465,
        };
      case 'yahoo.com':
        return {
          'name': 'Yahoo',
          'smtp': 'smtp.mail.yahoo.com',
          'port': 587,
          'sslPort': 465,
        };
      default:
        // Configuración genérica para otros proveedores
        return {
          'name': 'Genérico',
          'smtp': 'smtp.gmail.com', // Fallback a Gmail
          'port': 587,
          'sslPort': 465,
        };
    }
  }
}
