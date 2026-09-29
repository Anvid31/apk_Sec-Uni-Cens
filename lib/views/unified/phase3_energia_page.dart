import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/tokens.dart';
import '../../models/unified_survey_state.dart';
import '../../utils/draft_autosave.dart';
import '../../utils/form_navigator.dart';
import '../../widgets/form/photo_capture_field.dart';
import '../../widgets/form/si_no_cantidad_buttons.dart';
import '../../widgets/form/yes_no_buttons.dart';
import '../../widgets/layout/enhanced_form_container.dart';
import 'phase4_agua_page.dart';

class Phase3EnergiaPage extends StatefulWidget {
  const Phase3EnergiaPage({super.key});

  @override
  State<Phase3EnergiaPage> createState() => _Phase3EnergiaPageState();
}

class _Phase3EnergiaPageState extends State<Phase3EnergiaPage>
    with DraftAutosave<Phase3EnergiaPage> {
  @override
  UnifiedSurveyState get draftState => _state;

  @override
  void syncDraftToState() => _saveToState();

  late UnifiedSurveyState _state;
  bool _showErrors = false;

  final _numeroCLienteCtrl = TextEditingController();
  final _motivoCalidadCtrl = TextEditingController();

  static const List<String> _calidadServicioOpts = [
    'Bueno',
    'Regular',
    'Malo',
  ];

  final Map<String, TextEditingController> _cantCtrl = {};

  /// Controllers para la lista dinámica de otros electrodomésticos.
  final List<TextEditingController> _otroNombreCtrls = [];
  final List<TextEditingController> _otroCantCtrls = [];

  static const Color _green = Color(0xFF2E7D32);

  static const String _fuenteRedCens =
      'Red CENS (Convencional Red eléctrica y contador de energía)';

  static const List<String> _fuentesEnergia = [
    _fuenteRedCens,
    'A través de una vivienda cercana',
    'Conectado de Manera Irregular',
    'Planta Eléctrica (ACPM/Gasolina)',
    'Energías Renovables (Paneles solares, hídrico, biomasa, etc.)',
    'Red Artesana (Red Construida por la Comunidad)',
  ];

  bool get _isRedCens => _state.fuenteEnergia == _fuenteRedCens;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<UnifiedSurveyState>(context, listen: false);
    startDraftAutosave();
    _numeroCLienteCtrl.text = _state.numeroCLientesCENS ?? '';
    _motivoCalidadCtrl.text = _state.motivoCalidadServicioCENS ?? '';

    for (final item in UnifiedSurveyState.electrodomesticosList) {
      final key = item['key']!;
      final ed = _state.electrodomesticos[key];
      _cantCtrl[key] = TextEditingController(
        text: ed?.cantidad?.toString() ?? '',
      );
    }

    if (_state.otrosElectrodomesticos.isEmpty) {
      _addOtroRow(silent: true);
    } else {
      for (final item in _state.otrosElectrodomesticos) {
        _otroNombreCtrls.add(TextEditingController(text: item.nombre));
        _otroCantCtrls.add(
          TextEditingController(text: item.cantidad?.toString() ?? ''),
        );
      }
    }
  }

  @override
  void dispose() {
    _numeroCLienteCtrl.dispose();
    _motivoCalidadCtrl.dispose();
    for (final c in _cantCtrl.values) {
      c.dispose();
    }
    for (final c in _otroNombreCtrls) {
      c.dispose();
    }
    for (final c in _otroCantCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOtroRow({bool silent = false}) {
    void doAdd() {
      _otroNombreCtrls.add(TextEditingController());
      _otroCantCtrls.add(TextEditingController());
    }

    if (silent) {
      doAdd();
    } else {
      setState(doAdd);
    }
  }

  void _removeOtroRow(int index) {
    setState(() {
      _otroNombreCtrls[index].dispose();
      _otroCantCtrls[index].dispose();
      _otroNombreCtrls.removeAt(index);
      _otroCantCtrls.removeAt(index);
      if (_otroNombreCtrls.isEmpty) {
        _otroNombreCtrls.add(TextEditingController());
        _otroCantCtrls.add(TextEditingController());
      }
    });
  }

  void _clearRedCensFields() {
    _numeroCLienteCtrl.clear();
    _motivoCalidadCtrl.clear();
    _state.numeroCLientesCENS = null;
    _state.calidadServicioCENS = null;
    _state.motivoCalidadServicioCENS = null;
  }

  void _saveToState() {
    if (_isRedCens) {
      _state.numeroCLientesCENS =
          _numeroCLienteCtrl.text.trim().isNotEmpty
              ? _numeroCLienteCtrl.text.trim()
              : null;
      _state.motivoCalidadServicioCENS =
          _motivoCalidadCtrl.text.trim().isNotEmpty
              ? _motivoCalidadCtrl.text.trim()
              : null;
    } else {
      _clearRedCensFields();
    }

    final otros = <OtroElectrodomesticoItem>[];
    for (var i = 0; i < _otroNombreCtrls.length; i++) {
      final nombre = _otroNombreCtrls[i].text.trim();
      if (nombre.isEmpty) continue;
      otros.add(
        OtroElectrodomesticoItem(
          nombre: nombre,
          cantidad: int.tryParse(_otroCantCtrls[i].text.trim()),
        ),
      );
    }
    _state.otrosElectrodomesticos = otros;

    for (final item in UnifiedSurveyState.electrodomesticosList) {
      final key = item['key']!;
      final ed = _state.electrodomesticos[key]!;
      if (ed.tiene == 'si' || ed.tiene == 'numero') {
        ed.cantidad = int.tryParse(_cantCtrl[key]!.text.trim());
        if (ed.cantidad != null) {
          ed.tiene = 'numero';
        } else if (ed.tiene == 'numero') {
          ed.tiene = 'si';
        }
      } else {
        ed.cantidad = null;
      }
    }
  }

  void _onNext() {
    _saveToState();

    final List<String> missing = [];
    if (_state.tieneEnergiaElectrica == null) missing.add('¿Tiene energía eléctrica?');
    if (_state.tieneEnergiaElectrica == false && _state.interesSolucionesSolares == null) {
      missing.add('Interés en soluciones solares');
    }
    if (_state.tieneEnergiaElectrica == true && _state.fuenteEnergia == null) {
      missing.add('Fuente de energía');
    }
    if (_isRedCens && _state.calidadServicioCENS == null) {
      missing.add('Calificación del servicio');
    }
    if (_state.cuentaSalonHerramientasTIC == null) missing.add('Salón con herramientas TIC');
    if (_state.instalacionesElectricasAdecuadas == null) {
      missing.add('Instalaciones eléctricas adecuadas');
    }

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

    _state.notify();
    FormNavigator.pushForm(
      context,
      const Phase4AguaPage(),
      stepNumber: 4,
    );
  }

  Widget _fieldError([String msg = 'Campo requerido']) => Padding(
    padding: const EdgeInsets.only(left: 12, top: 2, bottom: 4),
    child: Text(msg, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
  );

  @override
  Widget build(BuildContext context) {
    return EnhancedFormContainer(
      title: 'Energía',
      subtitle: 'Servicios eléctricos y electrodomésticos',
      currentStep: 3,
      totalSteps: 5,
      showPrevious: true,
      onPrevious: () => FormNavigator.popForm(context),
      onNext: _onNext,
      nextLabel: 'Continuar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Servicios Públicos'),
          const SizedBox(height: 12),
          _buildYesNo(
            label: '¿Tiene energía eléctrica? *',
            value: _state.tieneEnergiaElectrica,
            onChanged: (v) => setState(() {
              _state.tieneEnergiaElectrica = v;
              if (v == true) {
                _state.interesSolucionesSolares = null;
              } else {
                _state.fuenteEnergia = null;
                _clearRedCensFields();
              }
            }),
          ),
          if (_showErrors && _state.tieneEnergiaElectrica == null) _fieldError(),
          if (_state.tieneEnergiaElectrica == false) ...[
            const SizedBox(height: 16),
            _buildYesNo(
              label:
                  '¿Estarían interesados en la instalación de soluciones solares fotovoltaicas? *',
              value: _state.interesSolucionesSolares,
              onChanged: (v) =>
                  setState(() => _state.interesSolucionesSolares = v),
            ),
            if (_showErrors && _state.interesSolucionesSolares == null) _fieldError(),
          ],
          if (_state.tieneEnergiaElectrica == true) ...[
            const SizedBox(height: 16),
            const Text(
              'Fuente de energía (Única opción) *',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            ..._fuentesEnergia.map(
              (opt) => RadioListTile<String>(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: opt,
                groupValue: _state.fuenteEnergia,
                title: Text(opt, style: const TextStyle(fontSize: 14)),
                activeColor: _green,
                onChanged: (v) => setState(() {
                  _state.fuenteEnergia = v;
                  if (v != _fuenteRedCens) {
                    _clearRedCensFields();
                  }
                }),
              ),
            ),
            if (_showErrors && _state.fuenteEnergia == null) _fieldError(),
            if (_isRedCens) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _numeroCLienteCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Número de cliente CENS',
                  hintText: 'Número en la factura',
                  helperText:
                      'Se encuentra en la factura, en la parte superior derecha, resaltado en amarillo.',
                  helperMaxLines: 3,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Cómo califica el servicio? *',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  for (var i = 0; i < _calidadServicioOpts.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    _radioBtn(
                      _calidadServicioOpts[i],
                      _calidadServicioOpts[i],
                      _state.calidadServicioCENS,
                      (v) => setState(() => _state.calidadServicioCENS = v),
                    ),
                  ],
                ],
              ),
              if (_showErrors && _state.calidadServicioCENS == null) _fieldError(),
              const SizedBox(height: 12),
              TextFormField(
                controller: _motivoCalidadCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: '¿Por qué califica el servicio?',
                  hintText:
                      'Ej. Variación de voltaje, servicio intermitente, etc.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 20),
          const _SectionHeader('Electrodomésticos'),
          const SizedBox(height: 8),
          _buildNoteCard(
            'Para cada electrodoméstico indique Sí o No. Si tiene, puede registrar la cantidad.',
          ),
          const SizedBox(height: 12),
          ...UnifiedSurveyState.electrodomesticosList.map(
            (item) => _buildElectroItem(item['key']!, item['name']!),
          ),
          const SizedBox(height: 16),
          _buildOtrosElectroList(),
          const SizedBox(height: 20),
          _buildYesNo(
            label:
                '¿Cuenta con salón con herramientas TIC? (TV o Videobeam) *',
            value: _state.cuentaSalonHerramientasTIC,
            onChanged: (v) =>
                setState(() => _state.cuentaSalonHerramientasTIC = v),
          ),
          if (_showErrors && _state.cuentaSalonHerramientasTIC == null) _fieldError(),
          const SizedBox(height: 16),
          _buildYesNo(
            label: '¿Cuenta con instalaciones eléctricas adecuadas? *',
            value: _state.instalacionesElectricasAdecuadas,
            onChanged: (v) =>
                setState(() => _state.instalacionesElectricasAdecuadas = v),
          ),
          if (_showErrors && _state.instalacionesElectricasAdecuadas == null) _fieldError(),
          const SizedBox(height: 12),
          PhotoCaptureField(
            label: 'Foto evidencia de instalaciones eléctricas',
            hintText: 'Anexe una foto como evidencia',
            imagePath: _state.photoInstalacionesElectricas,
            onImageSelected: (p) =>
                setState(() => _state.photoInstalacionesElectricas = p),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildYesNo({
    required String label,
    required bool? value,
    required void Function(bool) onChanged,
  }) {
    return YesNoButtons(label: label, value: value, onChanged: onChanged);
  }

  Widget _radioBtn<T>(
    String label,
    T opt,
    T? group,
    void Function(T) onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(opt),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<T>(
            value: opt,
            groupValue: group,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
            activeColor: _green,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildElectroItem(String key, String name) {
    final ed = _state.electrodomesticos[key]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Insets.lg),
          child: SiNoCantidadButtons(
            label: name,
            value: ed.tiene,
            cantidadController: _cantCtrl[key]!,
            onChanged: (v) => setState(() => ed.tiene = v),
          ),
        ),
      ),
    );
  }

  Widget _buildOtrosElectroList() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Otros electrodomésticos',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: Insets.xs),
        Text(
          'Agregue nombre y cantidad de cada equipo adicional.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Insets.md),
        for (var i = 0; i < _otroNombreCtrls.length; i++) ...[
          if (i > 0) const SizedBox(height: Insets.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Insets.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _otroNombreCtrls[i],
                      textCapitalization: TextCapitalization.sentences,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nombre',
                        prefixIcon: Icon(
                          Icons.devices_other_outlined,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: scheme.surfaceContainerLowest,
                      ),
                    ),
                  ),
                  const SizedBox(width: Insets.sm),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _otroCantCtrls[i],
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cant.',
                        prefixIcon: Icon(
                          Icons.tag_rounded,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: scheme.surfaceContainerLowest,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeOtroRow(i),
                    tooltip: 'Eliminar',
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: scheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: Insets.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addOtroRow,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar electrodoméstico'),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteCard(String text) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Insets.md),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.35),
        borderRadius: Radii.card,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: scheme.primary),
          const SizedBox(width: Insets.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
