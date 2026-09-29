import '../models/unified_survey_state.dart';
import 'auto_sync_service.dart';
import 'storage_service.dart';

/// Resultado del envío de un formulario unificado (4 fases).
class UnifiedSubmissionResult {
  final String surveyId;
  /// `true` si ya está en PostgreSQL (no en cola local).
  final bool syncedToDatabase;
  /// `true` si quedó en cola local (sin red o fallo temporal de envío).
  final bool queuedLocally;

  const UnifiedSubmissionResult({
    required this.surveyId,
    required this.syncedToDatabase,
    required this.queuedLocally,
  });
}

/// Envío del formulario unificado con persistencia offline-first.
class UnifiedSubmissionService {
  /// Guarda localmente y sincroniza con PostgreSQL cuando hay conexión.
  static Future<UnifiedSubmissionResult> submit(UnifiedSurveyState state) async {
    final payload = state.toJson();
    final surveyId =
        state.submissionId ?? DateTime.now().millisecondsSinceEpoch.toString();
    payload['id'] = surveyId;

    final enqueueResult = await AutoSyncService.scheduleImmediateSync(payload);

    state.submissionId = surveyId;
    state.isSubmitted = true;
    state.submissionDate = DateTime.now();
    state.submissionStatus =
        enqueueResult.synced ? 'sent' : 'pending';
    state.notify();

    // Borrar el borrador local — el formulario ya está en la cola de envío.
    // Va DESPUÉS de notify(): notify() guarda el borrador y lo revivía.
    await StorageService.clearDraft();

    return UnifiedSubmissionResult(
      surveyId: surveyId,
      syncedToDatabase: enqueueResult.synced,
      queuedLocally: !enqueueResult.synced,
    );
  }
}
