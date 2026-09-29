import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../models/unified_survey_state.dart';
import '../services/storage_service.dart';

/// Autoguardado del borrador para las páginas del formulario.
///
/// Los campos de texto solo pasan al estado con `_saveToState()` (al tocar
/// "Continuar"). Si Android cierra la app antes, lo escrito se perdía.
/// Cada [_interval] copia controllers → estado y guarda el borrador si cambió.
mixin DraftAutosave<T extends StatefulWidget> on State<T> {
  static const _interval = Duration(seconds: 3);

  Timer? _autosaveTimer;
  late int _epoch;
  String? _lastSaved;

  /// Estado compartido del formulario.
  UnifiedSurveyState get draftState;

  /// Copia los controllers de la página al estado (sin navegar).
  void syncDraftToState();

  /// Llamar al final de `initState`, después de asignar el estado.
  void startDraftAutosave() {
    _epoch = draftState.draftEpoch;
    _autosaveTimer = Timer.periodic(_interval, (_) => _flushDraft());
  }

  void _flushDraft() {
    // Encuesta enviada y reiniciada: esta página tiene datos viejos.
    if (draftState.draftEpoch != _epoch) {
      _autosaveTimer?.cancel();
      return;
    }
    syncDraftToState();
    final json = draftState.toJson();
    final encoded = jsonEncode(json);
    if (encoded == _lastSaved) return;
    _lastSaved = encoded;
    StorageService.saveDraft(json);
  }

  // Guardar lo último al salir de la página (p. ej. botón atrás). Va en
  // deactivate: en dispose la página ya liberó sus controllers.
  @override
  void deactivate() {
    if (_autosaveTimer?.isActive ?? false) _flushDraft();
    super.deactivate();
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    super.dispose();
  }
}
