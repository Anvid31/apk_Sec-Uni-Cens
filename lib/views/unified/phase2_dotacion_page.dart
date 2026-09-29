import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/unified_survey_state.dart';
import '../../utils/draft_autosave.dart';
import '../../config/tokens.dart';
import '../../utils/form_navigator.dart';
import '../../widgets/form/int_stepper_field.dart';
import '../../widgets/form/survey_detail_fields.dart';
import '../../widgets/form/yes_no_buttons.dart';
import '../../widgets/layout/enhanced_form_container.dart';
import 'phase3_energia_page.dart';

class Phase2DotacionPage extends StatefulWidget {
  const Phase2DotacionPage({super.key});

  @override
  State<Phase2DotacionPage> createState() => _Phase2DotacionPageState();
}

class _Phase2DotacionPageState extends State<Phase2DotacionPage>
    with DraftAutosave<Phase2DotacionPage> {
  @override
  UnifiedSurveyState get draftState => _state;

  @override
  void syncDraftToState() => _saveToState();

  late UnifiedSurveyState _state;
  bool _showErrors = false;

  // Servicios Públicos
  final _empresaInternetCtrl = TextEditingController();
  final _obsInternetCtrl     = TextEditingController();

  // Infraestructura — Espacios
  final _cantSalonesCtrl      = TextEditingController();
  final _estadoSalonesCtrl    = TextEditingController();
  final _cantComedorCtrl      = TextEditingController();
  final _estadoComedorCtrl    = TextEditingController();
  final _cantCocinaCtrl       = TextEditingController();
  final _estadoCocinaCtrl     = TextEditingController();
  final _cantSalonReuCtrl     = TextEditingController();
  final _estadoSalonReuCtrl   = TextEditingController();
  final _cantHabitCtrl        = TextEditingController();
  final _estadoHabitCtrl      = TextEditingController();

  // Otros espacios — lista dinámica
  final List<_OtroEspacioEntry> _otrosEspacios = [];

  // Mobiliario general (117-174): code → {bueno, regular, malo}
  final Map<String, Map<String, TextEditingController>> _mobCtrl = {};
  // Dotación Especial — Cocina (206-473)
  final Map<String, Map<String, TextEditingController>> _cocinaCtrl = {};
  // Dotación Especial — Emergencias (724-731)
  final Map<String, Map<String, TextEditingController>> _emergCtrl = {};

  @override
  void initState() {
    super.initState();
    _state = Provider.of<UnifiedSurveyState>(context, listen: false);
    startDraftAutosave();

    _empresaInternetCtrl.text   = _state.empresaInternet ?? '';
    _obsInternetCtrl.text       = _state.observacionesInternet ?? '';
    _cantSalonesCtrl.text       = _state.cantidadSalones ?? '';
    _estadoSalonesCtrl.text     = _state.estadoSalones ?? '';
    _cantComedorCtrl.text       = _state.cantidadComedor ?? '';
    _estadoComedorCtrl.text     = _state.estadoComedor ?? '';
    _cantCocinaCtrl.text        = _state.cantidadCocina ?? '';
    _estadoCocinaCtrl.text      = _state.estadoCocina ?? '';
    _cantSalonReuCtrl.text      = _state.cantidadSalonReuniones ?? '';
    _estadoSalonReuCtrl.text    = _state.estadoSalonReuniones ?? '';
    _cantHabitCtrl.text         = _state.cantidadHabitaciones ?? '';
    _estadoHabitCtrl.text       = _state.estadoHabitaciones ?? '';
    for (final item in _state.otrosEspaciosList) {
      _otrosEspacios.add(_OtroEspacioEntry.fromItem(item));
    }

    _initItemMap(_mobCtrl, UnifiedSurveyState.mobiliarioItemsList, _state.mobiliarioItems);
    _initItemMap(_cocinaCtrl, UnifiedSurveyState.dotacionCocinaItemsList, _state.dotCocinaItems);
    _initItemMap(_emergCtrl, UnifiedSurveyState.dotacionEmergenciaItemsList, _state.dotEmergenciaItems);
    _addBRMListeners(_mobCtrl);
    _addBRMListeners(_cocinaCtrl);
    _addBRMListeners(_emergCtrl);
  }

  void _initItemMap(
    Map<String, Map<String, TextEditingController>> ctrl,
    List<Map<String, String>> list,
    Map<String, MobiliarioItem> state,
  ) {
    for (final item in list) {
      final code = item['code']!;
      final mob  = state[code]!;
      ctrl[code] = {
        'total':   TextEditingController(text: mob.cantTotal?.toString() ?? ''),
        'bueno':   TextEditingController(text: mob.cantBueno?.toString() ?? ''),
        'regular': TextEditingController(text: mob.cantRegular?.toString() ?? ''),
        'malo':    TextEditingController(text: mob.cantMalo?.toString() ?? ''),
      };
    }
  }

  @override
  void dispose() {
    _empresaInternetCtrl.dispose();
    _obsInternetCtrl.dispose();
    _cantSalonesCtrl.dispose(); _estadoSalonesCtrl.dispose();
    _cantComedorCtrl.dispose(); _estadoComedorCtrl.dispose();
    _cantCocinaCtrl.dispose();  _estadoCocinaCtrl.dispose();
    _cantSalonReuCtrl.dispose(); _estadoSalonReuCtrl.dispose();
    _cantHabitCtrl.dispose();   _estadoHabitCtrl.dispose();
    for (final e in _otrosEspacios) { e.dispose(); }
    for (final m in [_mobCtrl, _cocinaCtrl, _emergCtrl]) {
      for (final ctrls in m.values) {
        for (final c in ctrls.values) { c.dispose(); }
      }
    }
    super.dispose();
  }

  String? _val(TextEditingController c) {
    final t = c.text.trim();
    return t.isNotEmpty ? t : null;
  }

  void _saveToState() {
    final conInternet = _state.tieneInternet == true;
    _state.empresaInternet         = conInternet ? _val(_empresaInternetCtrl) : null;
    _state.observacionesInternet   = conInternet ? _val(_obsInternetCtrl) : null;
    _state.cantidadSalones         = _val(_cantSalonesCtrl);
    _state.estadoSalones           = _val(_estadoSalonesCtrl);
    _state.cantidadComedor         = _val(_cantComedorCtrl);
    _state.estadoComedor           = _val(_estadoComedorCtrl);
    _state.cantidadCocina          = _val(_cantCocinaCtrl);
    _state.estadoCocina            = _val(_estadoCocinaCtrl);
    _state.cantidadSalonReuniones  = _val(_cantSalonReuCtrl);
    _state.estadoSalonReuniones    = _val(_estadoSalonReuCtrl);
    _state.cantidadHabitaciones    = _val(_cantHabitCtrl);
    _state.estadoHabitaciones      = _val(_estadoHabitCtrl);
    _state.otrosEspaciosList       = _otrosEspacios.map((e) => e.toItem()).toList();

    _saveItemMap(_mobCtrl, UnifiedSurveyState.mobiliarioItemsList, _state.mobiliarioItems);
    _saveItemMap(_cocinaCtrl, UnifiedSurveyState.dotacionCocinaItemsList, _state.dotCocinaItems);
    _saveItemMap(_emergCtrl, UnifiedSurveyState.dotacionEmergenciaItemsList, _state.dotEmergenciaItems);
  }

  void _saveItemMap(
    Map<String, Map<String, TextEditingController>> ctrl,
    List<Map<String, String>> list,
    Map<String, MobiliarioItem> state,
  ) {
    for (final item in list) {
      final code = item['code']!;
      final mob  = state[code]!;
      mob.cantTotal   = int.tryParse(ctrl[code]!['total']!.text.trim());
      mob.cantBueno   = int.tryParse(ctrl[code]!['bueno']!.text.trim());
      mob.cantRegular = int.tryParse(ctrl[code]!['regular']!.text.trim());
      mob.cantMalo    = int.tryParse(ctrl[code]!['malo']!.text.trim());
    }
  }

  void _addBRMListeners(Map<String, Map<String, TextEditingController>> ctrl) {
    for (final ctrls in ctrl.values) {
      for (final c in ctrls.values) {
        c.addListener(_onItemChanged);
      }
    }
  }

  void _onItemChanged() { if (mounted) setState(() {}); }

  void _onNext() {
    _saveToState();

    final List<String> missing = [];
    if (_state.tieneGas == null) missing.add('¿Tiene gas?');
    if (_state.tieneInternet == null) missing.add('¿Tiene Internet?');
    void space(String name, bool? tiene, TextEditingController cant, TextEditingController estado) {
      if (tiene == null) {
        missing.add('¿Tiene $name?');
      } else if (tiene && (_val(cant) == null || _val(estado) == null)) {
        missing.add('Cantidad y estado de $name');
      }
    }
    space('salones', _state.tieneSalones, _cantSalonesCtrl, _estadoSalonesCtrl);
    space('comedor', _state.tieneComedor, _cantComedorCtrl, _estadoComedorCtrl);
    space('cocina', _state.tieneCocinaEspacio, _cantCocinaCtrl, _estadoCocinaCtrl);
    space('salón de reuniones', _state.tieneSalonReuniones, _cantSalonReuCtrl, _estadoSalonReuCtrl);
    space('habitaciones', _state.tieneHabitaciones, _cantHabitCtrl, _estadoHabitCtrl);
    if (_state.tieneOtrosEspacios == null) {
      missing.add('¿Tiene otros espacios?');
    } else if (_state.tieneOtrosEspacios! && !_otrosEspaciosValidos) {
      missing.add('Descripción, cantidad y estado de otros espacios');
    }
    if (_state.dotTieneCocina == null) missing.add('Dotación: ¿Tiene cocina?');
    if (_state.dotTieneCocina == true && _state.dotEstadoCocina == null) {
      missing.add('Estado de la cocina');
    }
    if (_state.dotTieneComedor == null) missing.add('Dotación: ¿Tiene comedor?');
    if (_state.dotTieneComedor == true && _state.dotEstadoComedor == null) {
      missing.add('Estado del comedor');
    }
    if (_state.dotTieneEmergencia == null) missing.add('¿Tiene mobiliario de emergencias?');

    if (missing.isNotEmpty) {
      setState(() => _showErrors = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Complete los campos requeridos: ${missing.take(4).join(', ')}'
            '${missing.length > 4 ? ' y ${missing.length - 4} más' : ''}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _state.notify();
    FormNavigator.pushForm(context, const Phase3EnergiaPage(), stepNumber: 3);
  }

  bool get _otrosEspaciosValidos =>
      _otrosEspacios.isNotEmpty &&
      _otrosEspacios.every((e) =>
          e.descripcion.text.trim().isNotEmpty &&
          e.cantidad.text.trim().isNotEmpty &&
          e.estado != null);

  Widget _fieldError([String msg = 'Campo requerido']) => Padding(
    padding: const EdgeInsets.only(left: 12, top: 2, bottom: 4),
    child: Text(msg, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
  );

  @override
  Widget build(BuildContext context) {
    return EnhancedFormContainer(
      title: 'Dotación',
      subtitle: 'Servicios, infraestructura y mobiliario',
      currentStep: 2,
      totalSteps: 5,
      showPrevious: true,
      onPrevious: () => FormNavigator.popForm(context),
      onNext: _onNext,
      nextLabel: 'Continuar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Servicios Públicos ─────────────────────────────────
          const _SectionHeader('Servicios Públicos'),
          const SizedBox(height: 12),
          _buildYesNo(
            label: '¿Tiene gas? *',
            value: _state.tieneGas,
            onChanged: (v) => setState(() => _state.tieneGas = v),
          ),
          if (_showErrors && _state.tieneGas == null) _fieldError(),
          if (_state.tieneGas == true) ...[
            const SizedBox(height: 10),
            _buildMultiSelect(
              label: 'Fuente de gas',
              options: const ['Gas Domiciliario (Red)', 'Bombonas (Cilindro)'],
              selected: _state.fuenteGas,
              onChanged: (v) => setState(() => _state.fuenteGas = v),
            ),
          ],
          const SizedBox(height: 14),
          _buildYesNo(
            label: '¿Cuenta con Conectividad/Internet? *',
            value: _state.tieneInternet,
            onChanged: (v) => setState(() => _state.tieneInternet = v),
          ),
          if (_showErrors && _state.tieneInternet == null) _fieldError(),
          if (_state.tieneInternet == true) ...[
            const SizedBox(height: 10),
            _buildTextField(
              controller: _empresaInternetCtrl,
              label: '¿Qué empresa presta este servicio de internet?',
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _obsInternetCtrl,
              label: 'Observaciones sobre el servicio de internet',
              hint: 'Calidad de la señal, cobertura, intermitencias…',
              maxLines: 3,
            ),
          ],
          const SizedBox(height: 20),

          // ─── Infraestructura — Espacios ─────────────────────────
          const _SectionHeader('Infraestructura — Espacios'),
          const SizedBox(height: 12),
          _buildSpaceSection(
            label: '¿Tiene salones?',
            spaceName: 'salones',
            value: _state.tieneSalones,
            onChanged: (v) => setState(() => _state.tieneSalones = v),
            cantCtrl: _cantSalonesCtrl,
            estadoCtrl: _estadoSalonesCtrl,
          ),
          _buildSpaceSection(
            label: '¿Tiene comedor?',
            spaceName: 'comedor',
            value: _state.tieneComedor,
            onChanged: (v) => setState(() => _state.tieneComedor = v),
            cantCtrl: _cantComedorCtrl,
            estadoCtrl: _estadoComedorCtrl,
          ),
          _buildSpaceSection(
            label: '¿Tiene cocina?',
            spaceName: 'cocina',
            value: _state.tieneCocinaEspacio,
            onChanged: (v) => setState(() => _state.tieneCocinaEspacio = v),
            cantCtrl: _cantCocinaCtrl,
            estadoCtrl: _estadoCocinaCtrl,
          ),
          _buildSpaceSection(
            label: '¿Tiene salón de reuniones?',
            spaceName: 'salón de reuniones',
            value: _state.tieneSalonReuniones,
            onChanged: (v) => setState(() => _state.tieneSalonReuniones = v),
            cantCtrl: _cantSalonReuCtrl,
            estadoCtrl: _estadoSalonReuCtrl,
          ),
          _buildSpaceSection(
            label: '¿Tiene habitaciones?',
            spaceName: 'habitaciones',
            value: _state.tieneHabitaciones,
            onChanged: (v) => setState(() => _state.tieneHabitaciones = v),
            cantCtrl: _cantHabitCtrl,
            estadoCtrl: _estadoHabitCtrl,
          ),
          _buildYesNo(
            label: '¿Tiene otros espacios? *',
            value: _state.tieneOtrosEspacios,
            onChanged: (v) => setState(() => _state.tieneOtrosEspacios = v),
          ),
          if (_showErrors && _state.tieneOtrosEspacios == null) _fieldError(),
          if (_showErrors && _state.tieneOtrosEspacios == true && !_otrosEspaciosValidos)
            _fieldError('Agregue al menos un espacio con descripción, cantidad y estado'),
          if (_state.tieneOtrosEspacios == true) ...[
            const SizedBox(height: 8),
            ..._otrosEspacios.asMap().entries.map(
              (entry) => _buildOtroEspacioCard(entry.key, entry.value),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _otrosEspacios.add(_OtroEspacioEntry())),
                icon: const Icon(Icons.add),
                label: const Text('Agregar espacio'),
              ),
            ),
          ],
          const SizedBox(height: 20),

          // ─── Ítems de Mobiliario ────────────────────────────────
          const _SectionHeader('Ítems de Mobiliario'),
          const SizedBox(height: 10),
          _ManualBanner(),
          const SizedBox(height: 10),
          ...UnifiedSurveyState.mobiliarioItemsList
              .map((item) => _buildInventoryCard(
                    code: item['code']!,
                    name: item['name']!,
                    ctrl: _mobCtrl,
                    items: _state.mobiliarioItems,
                  )),
          const SizedBox(height: 20),

          // ─── Dotación Especial ──────────────────────────────────
          const _SectionHeader('Dotación Especial'),
          const SizedBox(height: 12),

          // Cocina
          _buildYesNo(
            label: '¿Tiene cocina? *',
            value: _state.dotTieneCocina,
            onChanged: (v) => setState(() => _state.dotTieneCocina = v),
          ),
          if (_showErrors && _state.dotTieneCocina == null) _fieldError(),
          if (_state.dotTieneCocina == true) ...[
            const SizedBox(height: 10),
            EstadoSelector(
              label: 'Estado de la cocina *',
              value: _state.dotEstadoCocina,
              onChanged: (v) => setState(() => _state.dotEstadoCocina = v),
            ),
            if (_showErrors && _state.dotEstadoCocina == null) _fieldError(),
          ],
          const SizedBox(height: 14),

          // Comedor
          _buildYesNo(
            label: '¿Tiene comedor? *',
            value: _state.dotTieneComedor,
            onChanged: (v) => setState(() => _state.dotTieneComedor = v),
          ),
          if (_showErrors && _state.dotTieneComedor == null) _fieldError(),
          if (_state.dotTieneComedor == true) ...[
            const SizedBox(height: 10),
            EstadoSelector(
              label: 'Estado del comedor *',
              value: _state.dotEstadoComedor,
              onChanged: (v) => setState(() => _state.dotEstadoComedor = v),
            ),
            if (_showErrors && _state.dotEstadoComedor == null) _fieldError(),
          ],
          const SizedBox(height: 14),

          // Ítems cocina/comedor — visible si al menos uno aplica
          if (_state.dotTieneCocina == true || _state.dotTieneComedor == true) ...[
            ...UnifiedSurveyState.dotacionCocinaItemsList
                .map((item) => _buildInventoryCard(
                      code: item['code']!,
                      name: item['name']!,
                      ctrl: _cocinaCtrl,
                      items: _state.dotCocinaItems,
                    )),
            const SizedBox(height: 14),
          ],

          // Emergencias
          _buildYesNo(
            label: '¿Tiene mobiliario para atención de emergencias? *',
            value: _state.dotTieneEmergencia,
            onChanged: (v) => setState(() => _state.dotTieneEmergencia = v),
          ),
          if (_showErrors && _state.dotTieneEmergencia == null) _fieldError(),
          if (_state.dotTieneEmergencia == true) ...[
            const SizedBox(height: 12),
            ...UnifiedSurveyState.dotacionEmergenciaItemsList
                .map((item) => _buildInventoryCard(
                      code: item['code']!,
                      name: item['name']!,
                      ctrl: _emergCtrl,
                      items: _state.dotEmergenciaItems,
                    )),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─────────────────────── helpers ──────────────────────────────────────────

  Widget _buildYesNo({
    required String label,
    required bool? value,
    required void Function(bool) onChanged,
  }) =>
      YesNoButtons(label: label, value: value, onChanged: onChanged);

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
  }) =>
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      );

  Widget _buildMultiSelect({
    required String label,
    required List<String> options,
    required List<String> selected,
    required void Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 4),
        ...options.map((opt) => CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: selected.contains(opt),
              title: Text(opt, style: const TextStyle(fontSize: 14)),
              activeColor: const Color(0xFF2E7D32),
              onChanged: (checked) {
                final list = List<String>.from(selected);
                if (checked == true) { list.add(opt); } else { list.remove(opt); }
                onChanged(list);
              },
            )),
      ],
    );
  }

  Widget _buildSpaceSection({
    required String label,
    required String spaceName,
    required bool? value,
    required void Function(bool) onChanged,
    required TextEditingController cantCtrl,
    required TextEditingController estadoCtrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildYesNo(label: '$label *', value: value, onChanged: onChanged),
        if (_showErrors && value == null) _fieldError(),
        if (value == true)
          QuantityStatusRow(
            quantityController: cantCtrl,
            statusController: estadoCtrl,
            quantityLabel: 'Cantidad de $spaceName *',
            statusLabel: 'Estado de $spaceName *',
          ),
        if (_showErrors && value == true &&
            (_val(cantCtrl) == null || _val(estadoCtrl) == null))
          _fieldError('Indique cantidad y estado'),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildInventoryCard({
    required String code,
    required String name,
    required Map<String, Map<String, TextEditingController>> ctrl,
    required Map<String, MobiliarioItem> items,
  }) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;
    final ctrls  = ctrl[code]!;

    final bueno      = int.tryParse(ctrls['bueno']!.text) ?? 0;
    final regular    = int.tryParse(ctrls['regular']!.text) ?? 0;
    final malo       = int.tryParse(ctrls['malo']!.text) ?? 0;
    final total      = int.tryParse(ctrls['total']!.text) ?? 0;
    final necesidades = regular + malo;
    final brm        = bueno + regular + malo;
    final hasTotal   = ctrls['total']!.text.trim().isNotEmpty;
    final brmExceedsTotal = hasTotal && total > 0 && brm > total;
    final hasData    = ctrls.values.any((c) => c.text.trim().isNotEmpty);

    return Card(
      margin: const EdgeInsets.only(bottom: Insets.sm),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, Insets.lg),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Insets.sm, vertical: 2),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: const BorderRadius.all(Radii.sm),
              ),
              child: Text(
                code,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: Insets.sm),
            Expanded(
              child: Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ),
            if (hasData) ...[
              const SizedBox(width: 4),
              Icon(
                necesidades > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                size: 16,
                color: necesidades > 0 ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
              ),
            ],
          ],
        ),
        children: [
          // ── Total ─────────────────────────────────────────────
          const Text('¿Cuántos tienen en total?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          IntStepperField(controller: ctrls['total']!),
          const SizedBox(height: Insets.md),
          // ── Bueno / Regular / Malo ─────────────────────────────
          Row(
            children: [
              Expanded(child: _BrmCell(label: 'Bueno',   controller: ctrls['bueno']!,   color: const Color(0xFF2E7D32))),
              const SizedBox(width: 8),
              Expanded(child: _BrmCell(label: 'Regular', controller: ctrls['regular']!, color: const Color(0xFFE65100))),
              const SizedBox(width: 8),
              Expanded(child: _BrmCell(label: 'Malo',    controller: ctrls['malo']!,    color: const Color(0xFFC62828))),
            ],
          ),
          const SizedBox(height: Insets.md),
          _NecesidadesChip(value: necesidades),
          if (brmExceedsTotal)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'La suma B+R+M ($brm) supera el total registrado ($total)',
                      style: TextStyle(color: Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOtroEspacioCard(int idx, _OtroEspacioEntry e) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(Insets.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: Radii.card,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Espacio ${idx + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  e.dispose();
                  _otrosEspacios.removeAt(idx);
                }),
                icon: const Icon(Icons.delete_outline, color: Color(0xFFC62828), size: 20),
                tooltip: 'Eliminar',
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: Insets.md),
          TextFormField(
            controller: e.descripcion,
            decoration: const InputDecoration(
              labelText: 'Descripción (ej: Biblioteca, laboratorio…)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: Insets.md),
          const Text('Cantidad', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54)),
          const SizedBox(height: 6),
          IntStepperField(controller: e.cantidad),
          const SizedBox(height: Insets.md),
          EstadoSelector(
            label: 'Estado',
            value: e.estado,
            onChanged: (v) => setState(() => e.estado = v),
          ),
        ],
      ),
    );
  }
}

// ── Gestión de un ítem de "otro espacio" ──────────────────────────────────────
class _OtroEspacioEntry {
  final TextEditingController descripcion = TextEditingController();
  final TextEditingController cantidad    = TextEditingController();
  String? estado;

  _OtroEspacioEntry();

  factory _OtroEspacioEntry.fromItem(OtroEspacioItem item) {
    final e = _OtroEspacioEntry();
    e.descripcion.text = item.descripcion;
    e.cantidad.text    = item.cantidad?.toString() ?? '';
    e.estado           = item.estado;
    return e;
  }

  OtroEspacioItem toItem() => OtroEspacioItem(
        descripcion: descripcion.text.trim(),
        cantidad:    int.tryParse(cantidad.text.trim()),
        estado:      estado,
      );

  void dispose() {
    descripcion.dispose();
    cantidad.dispose();
  }
}

// ── Campo Bueno / Regular / Malo ──────────────────────────────────────────────
class _BrmCell extends StatelessWidget {
  const _BrmCell({
    required this.label,
    required this.controller,
    required this.color,
  });

  final String label;
  final TextEditingController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
        ),
        const SizedBox(height: 4),
        IntStepperField(
          controller: controller,
          accentColor: color,
        ),
      ],
    );
  }
}

// ── Chip de necesidades (solo lectura) ────────────────────────────────────────
class _NecesidadesChip extends StatelessWidget {
  const _NecesidadesChip({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final color = value == 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    return Row(
      children: [
        Icon(Icons.warning_amber_rounded, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          'Necesidades: ',
          style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Text(
            '$value',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value == 0 ? 'Sin necesidades detectadas' : 'ítems a reemplazar o reparar',
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8)),
          ),
        ),
      ],
    );
  }
}

class _ManualBanner extends StatelessWidget {
  static const _url =
      'https://www.mineducacion.gov.co/1759/articles-355996_archivo_pdf_manual_dotaciones.pdf';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => launchUrl(Uri.parse(_url), mode: LaunchMode.externalApplication),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1565C0), width: 1),
        ),
        child: const Row(
          children: [
            Icon(Icons.menu_book_outlined, color: Color(0xFF1565C0), size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manual de Dotaciones MEN',
                    style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Consulte el manual oficial para conocer las especificaciones de cada ítem',
                    style: TextStyle(
                      color: Color(0xFF1976D2),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new, color: Color(0xFF1565C0), size: 16),
          ],
        ),
      ),
    );
  }
}

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
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
