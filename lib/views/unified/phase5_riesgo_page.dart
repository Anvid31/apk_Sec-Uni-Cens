import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/unified_survey_state.dart';
import '../../utils/draft_autosave.dart';
import '../../widgets/layout/enhanced_form_container.dart';
import '../../utils/form_navigator.dart';
import '../../config/theme.dart';
import '../../services/auto_sync_service.dart';
import '../../services/unified_submission_service.dart';

class Phase5RiesgoPage extends StatefulWidget {
  const Phase5RiesgoPage({super.key});

  @override
  State<Phase5RiesgoPage> createState() => _Phase5RiesgoPageState();
}

class _Phase5RiesgoPageState extends State<Phase5RiesgoPage>
    with DraftAutosave<Phase5RiesgoPage> {
  @override
  UnifiedSurveyState get draftState => _s;

  @override
  void syncDraftToState() => _saveToState();

  late UnifiedSurveyState _s;
  bool _isSaving = false;
  bool _showErrors = false;

  final _diasSinServicioCtrl = TextEditingController();
  final _otraCausaCtrl = TextEditingController();
  final _otraCondicionCtrl = TextEditingController();
  final _quienAvisaOtroCtrl = TextEditingController();
  final _medioAvisoOtroCtrl = TextEditingController();
  final _cargoResponsableCtrl = TextEditingController();
  final _observacionesGeneralesCtrl = TextEditingController();

  static const Color _green = Color(0xFF2E7D32);

  // ── opciones estáticas ─────────────────────────────────────────────────────

  static const _causaSuspensionOpts = [
    'Situaciones de seguridad que afectaron la continuidad educativa',
    'Evento natural (inundación, deslizamiento, vendaval)',
    'Falla de la infraestructura de la sede',
    'Falta de agua o de energía eléctrica',
    'Vía de acceso intransitable',
    'Paro o movilización',
    'Otra causa, ¿cuál? (indique solo el tipo de causa)',
    'No sabe',
    'Prefiere no responder',
  ];

  static const _amenazasOpts = [
    'Inundación',
    'Deslizamiento o remoción en masa',
    'Vendaval o vientos fuertes',
    'Incendio forestal',
    'Sismo',
    'Sequía o desabastecimiento de agua',
    'Deterioro estructural de la edificación',
    'Incendio en la edificación',
    'Accidentes en el trayecto de estudiantes o docentes',
    'Vía de acceso intransitable',
    'Riesgo asociado a posible presencia de artefactos explosivos',
    'Eventos de violencia armada o condiciones de seguridad',
    'Situaciones del entorno social que puedan afectar la sede',
    'Ninguna',
    'No sabe',
    'Prefiere no responder',
  ];

  static const _formasLlegadaOpts = [
    'A pie',
    'En ruta escolar o transporte contratado',
    'En transporte particular o de la familia',
    'En transporte fluvial',
    'En bicicleta o a lomo de animal',
  ];

  static const _duracionTrayectoOpts = [
    'Menos de 30 minutos',
    'Entre 30 minutos y 1 hora',
    'Entre 1 y 2 horas',
    'Más de 2 horas',
    'No sabe',
  ];

  // Opciones con separadores de categoría (prefijo '—' = no seleccionable)
  static const _riesgosTrayectoOpts = [
    '— Condiciones físicas y de acceso —',
    'Vía o camino en mal estado',
    'Paso de ríos o quebradas sin puente',
    'Crecientes, inundaciones o deslizamientos en temporada',
    'Terreno de ladera o pendientes pronunciadas',
    'Ausencia o insuficiencia de transporte escolar',
    'Tramos sin señal de comunicación',
    '— Condiciones del entorno —',
    'Riesgo asociado a posible presencia de artefactos explosivos en el trayecto',
    'Eventos de violencia armada o condiciones de seguridad en el trayecto',
    'Condiciones del entorno asociadas a riesgo de reclutamiento',
    'Restricciones a la movilidad en la zona del recorrido',
    'Situaciones del entorno social que puedan afectar el trayecto',
    '— Cierre —',
    'Ninguna de las anteriores',
    'Otra condición, ¿cuál? (indique solo el tipo de condición)',
    'No sabe',
    'Prefiere no responder',
  ];

  static const _quienAvisaOpts = [
    'Rector(a) de la institución principal',
    'Secretaría de Educación Departamental',
    'Alcaldía o Consejo Municipal de Gestión del Riesgo',
    'Organismo de socorro',
    'Presidente de la Junta de Acción Comunal',
    'Organización humanitaria o de acompañamiento',
    'Otro ¿cuál? (campo libre)',
    'No sabe',
  ];

  static const _medioAvisoOpts = [
    'Llamada telefónica',
    'WhatsApp',
    'Radio o emisora comunitaria',
    'Oficio escrito',
    'Visita presencial',
    'Otro ¿cuál? (campo libre)',
  ];

  static const _respuestaOpts = [
    'Sí, el mismo día',
    'Sí, en menos de una semana',
    'Sí, pero tardó más de una semana',
    'No obtuvo respuesta',
    'No ha tenido que avisar',
    'Prefiere no responder',
  ];

  static const _frecuenciaActualizacionOpts = [
    'Cada vez que ocurra algo',
    'Mensual',
    'Trimestral',
    'Semestral',
    'Anual',
    'No podría hacerlo',
  ];

  // ── ciclo de vida ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _s = Provider.of<UnifiedSurveyState>(context, listen: false);
    startDraftAutosave();
    _diasSinServicioCtrl.text = _s.r11DiassinServicio ?? '';
    _otraCausaCtrl.text = _s.r12OtraCausa ?? '';
    _otraCondicionCtrl.text = _s.r32OtraCondicion ?? '';
    _quienAvisaOtroCtrl.text = _s.r4QuienAvisaOtro ?? '';
    _medioAvisoOtroCtrl.text = _s.r41MedioAvisoOtro ?? '';
    _cargoResponsableCtrl.text = _s.r5CargoResponsable ?? '';
    _observacionesGeneralesCtrl.text = _s.observacionesGenerales ?? '';
  }

  @override
  void dispose() {
    for (final c in [
      _diasSinServicioCtrl, _otraCausaCtrl, _otraCondicionCtrl,
      _quienAvisaOtroCtrl, _medioAvisoOtroCtrl, _cargoResponsableCtrl, _observacionesGeneralesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── lógica ────────────────────────────────────────────────────────────────

  void _saveToState() {
    _s.r11DiassinServicio = _diasSinServicioCtrl.text.trim().isNotEmpty
        ? _diasSinServicioCtrl.text.trim() : null;
    _s.r12OtraCausa = _otraCausaCtrl.text.trim().isNotEmpty
        ? _otraCausaCtrl.text.trim() : null;
    _s.r32OtraCondicion = _otraCondicionCtrl.text.trim().isNotEmpty
        ? _otraCondicionCtrl.text.trim() : null;
    _s.r4QuienAvisaOtro = _quienAvisaOtroCtrl.text.trim().isNotEmpty
        ? _quienAvisaOtroCtrl.text.trim() : null;
    _s.r41MedioAvisoOtro = _medioAvisoOtroCtrl.text.trim().isNotEmpty
        ? _medioAvisoOtroCtrl.text.trim() : null;
    _s.r5CargoResponsable = _cargoResponsableCtrl.text.trim().isNotEmpty
        ? _cargoResponsableCtrl.text.trim() : null;
    _s.observacionesGenerales = _observacionesGeneralesCtrl.text.trim().isNotEmpty
        ? _observacionesGeneralesCtrl.text.trim() : null;
  }

  Future<void> _onFinish() async {
    _saveToState();

    final List<String> missing = [];
    if (_s.r1SuspendioClases == null) missing.add('¿Suspendió clases?');
    if (_s.r2Amenazas.isEmpty) missing.add('Amenazas reconocidas');
    if (_s.r3FormasLlegada.isEmpty) missing.add('Formas de llegada');

    if (missing.isNotEmpty) {
      setState(() => _showErrors = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complete los campos requeridos: ${missing.join(', ')}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _s.notify();
    setState(() => _isSaving = true);
    try {
      final result = await UnifiedSubmissionService.submit(_s);
      _s.reset();
      if (!mounted) return;
      await _showSubmissionDialog(result);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on DuplicateSurveyException {
      // Borrador viejo de una encuesta ya enviada: descartarlo, no reenviar.
      _s.reset();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Esta encuesta ya había sido enviada. Se descartó la copia local.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 6),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showSubmissionDialog(UnifiedSubmissionResult result) async {
    final synced = result.syncedToDatabase;
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              synced ? Icons.cloud_done : Icons.cloud_upload,
              color: synced ? AppTheme.primaryColor : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                synced ? 'Formulario enviado' : 'Formulario guardado',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          synced
              ? 'La información se guardó en la base de datos correctamente.'
              : 'La información quedó guardada en este dispositivo. '
                  'Se enviará automáticamente a la base de datos cuando haya conexión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return EnhancedFormContainer(
      title: 'Riesgo',
      subtitle: 'Preguntas sensibles — marque solo lo que la persona indique',
      currentStep: 5,
      totalSteps: 5,
      isLastStep: true,
      showPrevious: true,
      isLoading: _isSaving,
      onPrevious: () => FormNavigator.popForm(context),
      onNext: _onFinish,
      nextLabel: 'Enviar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════
          //  CONTINUIDAD DEL SERVICIO EDUCATIVO
          // ═══════════════════════════════════════════════════
          const _SectionHeader('CONTINUIDAD DEL SERVICIO EDUCATIVO'),
          const SizedBox(height: 12),

          _buildTriState(
            '¿En los últimos 12 meses esta sede suspendió clases o dejó de operar algún día? *',
            opts: const ['Sí', 'No', 'No sabe'],
            values: const ['si', 'no', 'no_sabe'],
            value: _s.r1SuspendioClases,
            onChanged: (v) => setState(() => _s.r1SuspendioClases = v),
          ),
          if (_showErrors && _s.r1SuspendioClases == null) _fieldError(),

          if (_s.r1SuspendioClases == 'si') ...[
            const SizedBox(height: 14),
            _numField(
              'Indique el número total de días completos sin servicio',
              _diasSinServicioCtrl,
            ),
            const SizedBox(height: 14),
            _buildSensitiveBanner(),
            _buildMultiCheck(
              '¿Por cuál causa? (Selección con varias opciones)',
              _causaSuspensionOpts, _s.r12CausaSuspension,
              onChanged: (v) => setState(() => _s.r12CausaSuspension = v),
            ),
            if (_s.r12CausaSuspension.contains(
                'Otra causa, ¿cuál? (indique solo el tipo de causa)')) ...[
              const SizedBox(height: 8),
              _textField(
                'Especifique el tipo de causa (sin nombres, lugares ni detalles)',
                _otraCausaCtrl,
              ),
            ],
          ],

          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════
          //  AMENAZAS RECONOCIDAS POR LA SEDE
          // ═══════════════════════════════════════════════════
          const _SectionHeader('AMENAZAS RECONOCIDAS POR LA SEDE'),
          const SizedBox(height: 12),

          _buildSensitiveBanner(),
          _buildMultiCheck(
            '¿Cuáles de las siguientes situaciones podrían afectar a esta sede? (Selección múltiple) *',
            _amenazasOpts, _s.r2Amenazas,
            onChanged: (v) {
              setState(() {
                _s.r2Amenazas = v;
                // Depurar prioridades que ya no están seleccionadas
                _s.r21AmenazasPrioritarias = _s.r21AmenazasPrioritarias
                    .where((p) =>
                        v.contains(p) ||
                        p == 'No sabría priorizar' ||
                        p == 'Prefiere no responder')
                    .toList();
              });
            },
          ),
          if (_showErrors && _s.r2Amenazas.isEmpty) _fieldError('Seleccione al menos una opción'),

          if (_s.r2Amenazas.isNotEmpty &&
              !_s.r2Amenazas.every((a) =>
                  a == 'Ninguna' ||
                  a == 'No sabe' ||
                  a == 'Prefiere no responder')) ...[
            const SizedBox(height: 14),
            _buildR21Priorities(),
          ],

          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════
          //  TRAYECTOS Y TRANSPORTE ESCOLAR
          // ═══════════════════════════════════════════════════
          const _SectionHeader('TRAYECTOS Y TRANSPORTE ESCOLAR'),
          const SizedBox(height: 12),

          _buildMultiCheck(
            '¿Cómo llegan los estudiantes a esta sede? (Selección múltiple) *',
            _formasLlegadaOpts, _s.r3FormasLlegada,
            onChanged: (v) => setState(() => _s.r3FormasLlegada = v),
          ),
          if (_showErrors && _s.r3FormasLlegada.isEmpty) _fieldError('Seleccione al menos una opción'),

          const SizedBox(height: 14),
          _buildSingleSelect(
            'En promedio, ¿cuánto dura el trayecto más largo que hace un estudiante para llegar a esta sede?',
            _duracionTrayectoOpts, _s.r31DuracionTrayecto,
            (v) => setState(() => _s.r31DuracionTrayecto = v),
          ),

          const SizedBox(height: 14),
          _buildSensitiveBanner(),
          _buildSectionedMultiCheck(
            '¿Cuáles de las siguientes condiciones hacen riesgoso el trayecto de los estudiantes hacia esta sede? (Selección múltiple)',
            _riesgosTrayectoOpts, _s.r32RiesgosTrayecto,
            onChanged: (v) => setState(() => _s.r32RiesgosTrayecto = v),
          ),
          if (_s.r32RiesgosTrayecto.contains(
              'Otra condición, ¿cuál? (indique solo el tipo de condición)')) ...[
            const SizedBox(height: 8),
            _textField(
              'Especifique el tipo de condición (sin nombres, lugares ni detalles)',
              _otraCondicionCtrl,
            ),
          ],

          const SizedBox(height: 14),
          _buildTriState(
            '¿En el último año alguno de los trayectos se suspendió o se tuvo que modificar?',
            opts: const ['Sí', 'No', 'No sabe', 'Prefiere no responder'],
            values: const ['si', 'no', 'no_sabe', 'prefiere_no_responder'],
            value: _s.r33TrayectoSuspendido,
            onChanged: (v) => setState(() => _s.r33TrayectoSuspendido = v),
          ),

          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════
          //  EFECTIVIDAD DE LA RUTA DE AVISO
          // ═══════════════════════════════════════════════════
          const _SectionHeader('EFECTIVIDAD DE LA RUTA DE AVISO'),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'No registre nombres propios de organizaciones ni personas.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),

          _buildSingleSelect(
            'Ante una emergencia en esta sede, ¿a quién avisa primero?',
            _quienAvisaOpts, _s.r4QuienAvisa,
            (v) => setState(() => _s.r4QuienAvisa = v),
          ),
          if (_s.r4QuienAvisa == 'Otro ¿cuál? (campo libre)') ...[
            const SizedBox(height: 8),
            _textField('Especifique (cargo u organización, no nombre propio)', _quienAvisaOtroCtrl),
          ],

          const SizedBox(height: 14),
          _buildMultiCheck(
            '¿Por cuál medio avisa? (Selección múltiple)',
            _medioAvisoOpts, _s.r41MedioAviso,
            onChanged: (v) => setState(() => _s.r41MedioAviso = v),
          ),
          if (_s.r41MedioAviso.contains('Otro ¿cuál? (campo libre)')) ...[
            const SizedBox(height: 8),
            _textField('Especifique el medio de aviso', _medioAvisoOtroCtrl),
          ],

          const SizedBox(height: 14),
          _buildSingleSelect(
            'La última vez que avisó, ¿obtuvo respuesta?',
            _respuestaOpts, _s.r42ObtuvoRespuesta,
            (v) => setState(() => _s.r42ObtuvoRespuesta = v),
          ),

          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════
          //  ACTUALIZACIÓN DE LA INFORMACIÓN
          // ═══════════════════════════════════════════════════
          const _SectionHeader('ACTUALIZACIÓN DE LA INFORMACIÓN'),
          const SizedBox(height: 12),

          _textField(
            '¿Cuál es el cargo de la persona responsable de mantener actualizada la información de los PGIR e información relacionada con los riesgos de la sede?\n(Registre el cargo o rol, no el nombre de la persona)',
            _cargoResponsableCtrl,
          ),

          const SizedBox(height: 14),
          _buildSingleSelect(
            '¿Con qué frecuencia actualiza esta información?',
            _frecuenciaActualizacionOpts, _s.r51FrecuenciaActualizacion,
            (v) => setState(() => _s.r51FrecuenciaActualizacion = v),
          ),

          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════
          //  OBSERVACIONES
          // ═══════════════════════════════════════════════════
          const _SectionHeader('OBSERVACIONES'),
          const SizedBox(height: 12),

          _textField(
            'Observaciones generales sobre la sede o la visita',
            _observacionesGeneralesCtrl,
            maxLines: 4,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  Widget _fieldError([String msg = 'Campo requerido']) => Padding(
    padding: const EdgeInsets.only(left: 12, top: 2, bottom: 4),
    child: Text(msg, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
  );

  Widget _buildSensitiveBanner() => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFFFCC02)),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFE65100), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pregunta sensible — lea las opciones y marque solo lo que la persona indique. '
                  'No solicite nombres, lugares ni detalles de incidentes.',
                  style: TextStyle(fontSize: 12, color: Color(0xFFBF360C)),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _numField(String label, TextEditingController ctrl) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Numérico',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      );

  Widget _textField(String label, TextEditingController ctrl, {int maxLines = 2}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: 'Campo libre',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      );

  Widget _buildTriState(
    String label, {
    required List<String> opts,
    required List<String> values,
    required String? value,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 16,
          runSpacing: 0,
          children: List.generate(
            opts.length,
            (i) => GestureDetector(
              onTap: () => onChanged(values[i]),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: values[i],
                    groupValue: value,
                    onChanged: (v) { if (v != null) onChanged(v); },
                    activeColor: _green,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text(opts[i], style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleSelect(
    String label,
    List<String> opts,
    String? value,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 4),
        ...opts.map(
          (opt) => RadioListTile<String>(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: opt,
            groupValue: value,
            title: Text(opt, style: const TextStyle(fontSize: 14)),
            activeColor: _green,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMultiCheck(
    String label,
    List<String> opts,
    List<String> selected, {
    required void Function(List<String>) onChanged,
    int? maxSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        if (maxSelect != null)
          Text('(máximo $maxSelect opciones)',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        ...opts.map((opt) {
          final checked = selected.contains(opt);
          return CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: checked,
            title: Text(opt, style: const TextStyle(fontSize: 14)),
            activeColor: _green,
            onChanged: (v) {
              final next = List<String>.from(selected);
              if (v == true) {
                if (maxSelect == null || next.length < maxSelect) next.add(opt);
              } else {
                next.remove(opt);
              }
              onChanged(next);
            },
          );
        }),
      ],
    );
  }

  // Checkboxes con separadores de categoría (items con prefijo '—' no son seleccionables)
  Widget _buildSectionedMultiCheck(
    String label,
    List<String> opts,
    List<String> selected, {
    required void Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 4),
        ...opts.map((opt) {
          if (opt.startsWith('—')) {
            return Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 2),
              child: Text(
                opt,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            );
          }
          final checked = selected.contains(opt);
          return CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: checked,
            title: Text(opt, style: const TextStyle(fontSize: 14)),
            activeColor: _green,
            onChanged: (v) {
              final next = List<String>.from(selected);
              if (v == true) {
                next.add(opt);
              } else {
                next.remove(opt);
              }
              onChanged(next);
            },
          );
        }),
      ],
    );
  }

  // R2.1: muestra solo las opciones seleccionadas en R2 + las especiales
  Widget _buildR21Priorities() {
    final selectables = _s.r2Amenazas
        .where((a) =>
            a != 'Ninguna' && a != 'No sabe' && a != 'Prefiere no responder')
        .toList();
    final allOpts = [...selectables, 'No sabría priorizar', 'Prefiere no responder'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'R2.1 De las anteriores, ¿cuáles considera las tres más importantes para esta sede?',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const Text('(máximo 3 opciones)',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        ...allOpts.map((opt) {
          final checked = _s.r21AmenazasPrioritarias.contains(opt);
          return CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: checked,
            title: Text(opt, style: const TextStyle(fontSize: 14)),
            activeColor: _green,
            onChanged: (v) {
              final next = List<String>.from(_s.r21AmenazasPrioritarias);
              if (v == true) {
                if (next.length < 3) next.add(opt);
              } else {
                next.remove(opt);
              }
              setState(() => _s.r21AmenazasPrioritarias = next);
            },
          );
        }),
      ],
    );
  }
}

// ── Widgets locales ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}
