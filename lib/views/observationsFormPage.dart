import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/observationsInfo.dart';
import '../models/survey_state.dart';
import '../services/auto_sync_service.dart';
import '../services/notification_service.dart';
import '../widgets/form/custom_text_field.dart';
import '../widgets/layout/enhanced_form_container.dart';
import '../utils/form_navigator.dart';

class ObservationsFormPage extends StatefulWidget {
  const ObservationsFormPage({super.key});

  @override
  State<ObservationsFormPage> createState() => _ObservationsFormPageState();
}

class _ObservationsFormPageState extends State<ObservationsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  late ObservationsInfo _observationsInfo;

  @override
  void initState() {
    super.initState();
    final surveyState = Provider.of<SurveyState>(context, listen: false);
    _observationsInfo = surveyState.observationsInfo;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSubmissionStatusCard(SurveyState surveyState) {
    MaterialColor statusColor;
    IconData statusIcon;
    String statusTitle;
    String statusMessage;

    switch (surveyState.submissionStatus) {
      case 'sent':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusTitle = 'Formulario Enviado Exitosamente';
        statusMessage = 'El formulario ha sido enviado por correo electrónico${surveyState.submissionEmail != null ? ' a ${surveyState.submissionEmail}' : ''}. Fecha de envío: ${_formatDate(surveyState.submissionDate)}';
        break;
      case 'error':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusTitle = 'Error en el Envío';
        statusMessage = 'Hubo un problema enviando el formulario: ${surveyState.errorMessage ?? "Error desconocido"}. Puede intentar enviarlo nuevamente.';
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusTitle = 'Envío Programado';
        statusMessage = 'El formulario está en cola para ser enviado automáticamente cuando haya conexión a internet. Fecha de programación: ${_formatDate(surveyState.submissionDate)}';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.1),
            statusColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusIcon,
                  size: 28,
                  color: statusColor.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: statusColor.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (surveyState.submissionStatus == 'error') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      surveyState.resetSubmissionStatus();
                      _submitForm();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar Envío'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Fecha no disponible';
    return '${date.day}/${date.month}/${date.year} a las ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SurveyState>(
      builder: (context, surveyState, child) {
        return EnhancedFormContainer(
          title: 'Observaciones Finales',
          subtitle: 'Último paso - Complete la caracterización',
          currentStep: 9,
          onPrevious: () => FormNavigator.popForm(context),
          onNext: surveyState.isSubmitted ? null : _submitForm,
          nextLabel: surveyState.isSubmitted ? 'Formulario Enviado' : 'Finalizar y Enviar',
          showPrevious: true,
          transitionType: FormTransitionType.slideScale,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Estado del envío si ya fue enviado
                    if (surveyState.isSubmitted) ...[
                      _buildSubmissionStatusCard(surveyState),
                      const SizedBox(height: 24),
                    ],
                    
                    // Caja informativa con descripción
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF607D8B).withValues(alpha: 0.1),
                            const Color(0xFF607D8B).withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF607D8B).withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.comment_outlined,
                            size: 32,
                            color: Color(0xFF607D8B),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Observaciones Finales',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E2E2E),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Comparta comentarios adicionales o información relevante sobre la sede educativa',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    CustomTextField(
                      label: 'Observaciones adicionales',
                      hintText: 'Agregue cualquier información adicional relevante',
                      initialValue: _observationsInfo.additionalObservations,
                      onChanged: (value) => _observationsInfo.additionalObservations = value,
                      maxLines: 5,
                      enabled: !surveyState.isSubmitted, // Deshabilitar si ya se envió
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Mensaje informativo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surveyState.isSubmitted 
                            ? Colors.green.withValues(alpha: 0.05)
                            : Colors.blue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: surveyState.isSubmitted 
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.blue.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            surveyState.isSubmitted ? Icons.check_circle_outline : Icons.info_outline,
                            color: surveyState.isSubmitted ? Colors.green.shade600 : Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              surveyState.isSubmitted
                                  ? 'El formulario ha sido enviado exitosamente. Recibirá una confirmación por correo cuando se complete el proceso.'
                                  : 'Al enviar completará la caracterización de la sede educativa. Podrá compartir, enviar por email o guardar los resultados.',
                              style: TextStyle(
                                fontSize: 13,
                                color: surveyState.isSubmitted ? Colors.green.shade700 : Colors.blue.shade700,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 80), // Espacio para los botones fijos
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Obtener el estado completo de la encuesta
      final surveyState = Provider.of<SurveyState>(context, listen: false);
      
      // Actualizar las observaciones
      surveyState.updateObservationsInfo(_observationsInfo);
      
      // Verificar si ya fue enviado para evitar duplicados
      if (surveyState.isSubmitted && surveyState.submissionStatus != 'error') {
        _showAlreadySubmittedDialog();
        return;
      }
      
      // DEBUG: Verificar el estado fotográfico antes del envío
      final photoInfo = surveyState.photographicRecordInfo;
      print('🔍 ANTES DEL ENVÍO - Estado del registro fotográfico:');
      print('   - generalPhoto: ${photoInfo.generalPhoto}');
      print('   - infrastructurePhoto: ${photoInfo.infrastructurePhoto}');
      print('   - electricityPhoto: ${photoInfo.electricityPhoto}');
      print('   - environmentPhoto: ${photoInfo.environmentPhoto}');
      print('   - frontSchoolPhoto: ${photoInfo.frontSchoolPhoto}');
      print('   - classroomsPhoto: ${photoInfo.classroomsPhoto}');
      print('   - kitchenPhoto: ${photoInfo.kitchenPhoto}');
      print('   - diningRoomPhoto: ${photoInfo.diningRoomPhoto}');
      print('   - additionalPhotos: ${photoInfo.additionalPhotos}');
      
      // Mostrar diálogo simple de confirmación y activar sincronización
      _showFinalSubmissionDialog(surveyState);
    } else {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _showAlreadySubmittedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Formulario Ya Enviado'),
          ],
        ),
        content: const Text(
          'Este formulario ya ha sido enviado anteriormente. Si necesita hacer cambios, puede editar las observaciones y reintentar el envío.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
  
  void _showFinalSubmissionDialog(SurveyState surveyState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Enviar Formulario'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Cómo desea enviar la información recopilada?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Icon(Icons.cloud_upload, color: Colors.blue, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'Envío Automático',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Se detectará automáticamente la conexión y se enviará por correo electrónico',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _scheduleAutomaticSync(surveyState);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Envío Automático'),
          ),
        ],
      ),
    );
  }

  /// Programa el envío automático en segundo plano
  void _scheduleAutomaticSync(SurveyState surveyState) async {
    _showLoadingDialog('Programando envío automático...');
    
    try {
      // Marcar como enviado antes de programar
      final email = surveyState.generalInfo.contact ?? 'contacto@institution.edu.co';
      final institutionName = surveyState.institutionalInfo.institutionName ?? 'Institución';
      
      surveyState.markAsSubmitted(email: email);
      
      // Convertir surveyState a Map para almacenamiento
      final surveyData = surveyState.toJson();
      
      // Programar para sincronización automática con el nuevo servicio
      await AutoSyncService.scheduleImmediateSync(surveyData);
      
      // Mostrar notificación push de formulario programado
      await NotificationService.showFormScheduledNotification(
        institutionName: institutionName,
      );
      
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        
        // Mostrar confirmación con información sobre el envío automático
        _showAutomaticSyncConfirmation(email);
        
        // Programar verificación del estado de envío
        _scheduleStatusCheck(surveyState);
      }
      
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        
        // Marcar como error en el estado
        surveyState.markAsError(e.toString());
        
        // Mostrar notificación push de error
        final institutionName = surveyState.institutionalInfo.institutionName ?? 'Institución';
        await NotificationService.showFormErrorNotification(
          institutionName: institutionName,
          error: e.toString(),
        );
        
        _showErrorDialog('Error programando envío automático: $e');
      }
    }
  }

  /// Programa verificaciones periódicas del estado de envío
  void _scheduleStatusCheck(SurveyState surveyState) {
    // Verificar el estado cada 30 segundos durante los primeros 5 minutos
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (timer.tick > 10) { // 10 * 30 segundos = 5 minutos
        timer.cancel();
        return;
      }

      try {
        final syncStatus = await AutoSyncService.getSyncStatus();
        
        if (syncStatus['pendingCount'] == 0 && 
            syncStatus['lastSuccessfulSync'] != null) {
          
          // Marcar como enviado exitosamente
          surveyState.markAsSent();
          
          // Mostrar notificación push de envío exitoso
          final institutionName = surveyState.institutionalInfo.institutionName ?? 'Institución';
          final email = surveyState.submissionEmail ?? 'su correo';
          
          await NotificationService.showFormSubmittedNotification(
            institutionName: institutionName
          );
          
          // Mostrar notificación de diálogo también (opcional, para cuando la app esté abierta)
          if (mounted) {
            _showSuccessNotification(email);
          }
          
          timer.cancel();
        }
      } catch (e) {
        print('Error verificando estado: $e');
      }
    });
  }

  /// Muestra notificación de envío exitoso
  void _showSuccessNotification(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_read,
                color: Colors.green.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '¡Enviado por Correo!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.green.shade600, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Correo Enviado Exitosamente',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '✅ El formulario completo ha sido enviado a: $email\n'
                    '✅ Incluye todos los datos recopilados\n'
                    '✅ Fotografías adjuntas en formato ZIP\n'
                    '✅ Archivo CSVcon la información estructurada',
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.blue.shade600, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tiempo de envío: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.of(context).popUntil((route) => route.isFirst); // Volver al inicio
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Perfecto'),
          ),
        ],
      ),
    );
  }
  
  /// Muestra confirmación del envío automático programado
  void _showAutomaticSyncConfirmation(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_done,
                color: Colors.green.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Envío Programado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ Su formulario ha sido guardado exitosamente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wifi_find, color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Monitoreo Automático Activado',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• La app buscará conexión automáticamente\n'
                    '• Se enviará cuando detecte WiFi o datos móviles\n'
                    '• Funciona incluso si cierra la aplicación\n'
                    '• Recibirá confirmación por correo electrónico a: $email',
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade600, size: 18),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Puede cerrar la app de forma segura',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.of(context).popUntil((route) => route.isFirst); // Volver al inicio
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
  
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
