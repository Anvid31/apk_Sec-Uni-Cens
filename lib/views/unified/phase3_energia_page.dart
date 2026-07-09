import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/unified_survey_state.dart';
import '../../utils/form_navigator.dart';
import '../../widgets/layout/enhanced_form_container.dart';
import 'phase4_agua_page.dart';

class Phase3EnergiaPage extends StatefulWidget {
  const Phase3EnergiaPage({super.key});

  @override
  State<Phase3EnergiaPage> createState() => _Phase3EnergiaPageState();
}

class _Phase3EnergiaPageState extends State<Phase3EnergiaPage> {
  late UnifiedSurveyState _state;

  final _numeroCLienteCtrl = TextEditingController();
  final _otrosElectroCtrl = TextEditingController();

  // Para cada electrodoméstico en modo 'numero': su controller de cantidad
  final Map<String, TextEditingController> _cantCtrl = {};

  static const Color _green = Color(0xFF2E7D32);

  static const List<String> _fuentesEnergia = [
    'Red CENS (Convencional Red eléctrica y contador de energía)',
    'A través de una vivienda cercana',
    'Conectado de Manera Irregular',
    'Planta Eléctrica (ACPM/Gasolina)',
    'Energías Renovables (Paneles solares, hídrico, biomasa, etc.)',
    'Red Artesana (Red Construida por la Comunidad)',
  ];

  @override
  void initState() {
    super.initState();
    _state = Provider.of<UnifiedSurveyState>(context, listen: false);
    _numeroCLienteCtrl.text = _state.numeroCLientesCENS ?? '';
    _otrosElectroCtrl.text = _state.otrosElectrodomesticos ?? '';

    for (final item in UnifiedSurveyState.electrodomesticosList) {
      final key = item['key']!;
      final ed = _state.electrodomesticos[key];
      _cantCtrl[key] = TextEditingController(
        text: ed?.cantidad?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    _numeroCLienteCtrl.dispose();
    _otrosElectroCtrl.dispose();
    for (final c in _cantCtrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveToState() {
    _state.numeroCLientesCENS =
        _numeroCLienteCtrl.text.trim().isNotEmpty
            ? _numeroCLienteCtrl.text.trim()
            : null;
    _state.otrosElectrodomesticos =
        _otrosElectroCtrl.text.trim().isNotEmpty
            ? _otrosElectroCtrl.text.trim()
            : null;

    for (final item in UnifiedSurveyState.electrodomesticosList) {
      final key = item['key']!;
      final ed = _state.electrodomesticos[key]!;
      if (ed.tiene == 'numero') {
        ed.cantidad = int.tryParse(_cantCtrl[key]!.text.trim());
      } else {
        ed.cantidad = null;
      }
    }
  }

  void _onNext() {
    _saveToState();
    _state.notify();
    FormNavigator.pushReplacementForm(
      context,
      const Phase4AguaPage(),
      stepNumber: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return EnhancedFormContainer(
      title: 'Energía',
      subtitle: 'Servicios eléctricos y electrodomésticos',
      currentStep: 3,
      totalSteps: 4,
      showPrevious: true,
      onPrevious: () => FormNavigator.popForm(context),
      onNext: _onNext,
      nextLabel: 'Continuar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Servicios Públicos ───────────────────────────────
          const _SectionHeader('Servicios Públicos'),
          const SizedBox(height: 12),
          _buildYesNo(
            label: '¿Tiene energía eléctrica?',
            value: _state.tieneEnergiaElectrica,
            onChanged: (v) => setState(() => _state.tieneEnergiaElectrica = v),
          ),
          if (_state.tieneEnergiaElectrica == true) ...[
            const SizedBox(height: 16),
            const Text(
              'Fuente de energía (Única opción)',
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
                onChanged: (v) => setState(() => _state.fuenteEnergia = v),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _numeroCLienteCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Número de cliente CENS',
                hintText:
                    'Número en la factura (esquina sup. derecha amarilla)',
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
          const SizedBox(height: 20),

          // ─── Electrodomésticos ────────────────────────────────
          const _SectionHeader('Electrodomésticos'),
          const SizedBox(height: 8),
          _buildNoteCard(
            'Para cada electrodoméstico seleccione: Sí (tiene pero sin cantidad), N° (tiene y especifique cantidad), o No (no tiene).',
          ),
          const SizedBox(height: 12),
          ...UnifiedSurveyState.electrodomesticosList.map(
            (item) => _buildElectroItem(item['key']!, item['name']!),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _otrosElectroCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Otros electrodomésticos (nombre + cantidad)',
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
        ],
      ),
    );
  }

  // ─────────────────────── helpers ───────────────────────

  Widget _buildYesNo({
    required String label,
    required bool? value,
    required void Function(bool) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _radioBtn('Sí', true, value, onChanged),
            const SizedBox(width: 24),
            _radioBtn('No', false, value, onChanged),
          ],
        ),
      ],
    );
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _strRadio(
                'Sí',
                'si',
                ed.tiene,
                (v) => setState(() {
                  ed.tiene = v;
                  _cantCtrl[key]!.clear();
                }),
              ),
              const SizedBox(width: 16),
              _strRadio(
                'No',
                'no',
                ed.tiene,
                (v) => setState(() {
                  ed.tiene = v;
                  _cantCtrl[key]!.clear();
                }),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 80,
                child: TextFormField(
                  controller: _cantCtrl[key],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged:
                      (val) => setState(() {
                        ed.tiene = val.trim().isNotEmpty ? 'numero' : null;
                      }),
                  decoration: InputDecoration(
                    labelText: 'N°',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _strRadio(
    String label,
    String opt,
    String? group,
    void Function(String) onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(opt),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
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

  Widget _buildNoteCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade900,
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
