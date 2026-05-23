import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/unified_survey_state.dart';
import '../../utils/form_navigator.dart';
import '../../widgets/layout/enhanced_form_container.dart';
import 'phase3_energia_page.dart';

class Phase2DotacionPage extends StatefulWidget {
  const Phase2DotacionPage({super.key});

  @override
  State<Phase2DotacionPage> createState() => _Phase2DotacionPageState();
}

class _Phase2DotacionPageState extends State<Phase2DotacionPage> {
  late UnifiedSurveyState _state;

  // Servicios Públicos
  final _empresaInternetCtrl = TextEditingController();

  // Infraestructura — Espacios
  final _cantSalonesCtrl = TextEditingController();
  final _estadoSalonesCtrl = TextEditingController();
  final _cantComedorCtrl = TextEditingController();
  final _estadoComedorCtrl = TextEditingController();
  final _cantCocinaCtrl = TextEditingController();
  final _estadoCocinaCtrl = TextEditingController();
  final _cantSalonReunionesCtrl = TextEditingController();
  final _estadoSalonReunionesCtrl = TextEditingController();
  final _cantHabitacionesCtrl = TextEditingController();
  final _estadoHabitacionesCtrl = TextEditingController();
  final _cantBanosCtrl = TextEditingController();
  final _estadoBanosCtrl = TextEditingController();
  final _cantOtrosEspaciosCtrl = TextEditingController();
  final _estadoOtrosEspaciosCtrl = TextEditingController();
  final _descOtrosEspaciosCtrl = TextEditingController();

  // Mobiliario: code → {cantidad, texto, observaciones}
  final Map<String, Map<String, TextEditingController>> _mobCtrl = {};

  // Dotación Especial
  final _dotNecMobCocinaCtrl = TextEditingController();
  final _dotNecUtensiliosCocinaCtrl = TextEditingController();
  final _dotNecEmergenciaCtrl = TextEditingController();

  static const Color _green = Color(0xFF2E7D32);
  static const Color _noteBg = Color(0xFFFFF9C4);

  @override
  void initState() {
    super.initState();
    _state = Provider.of<UnifiedSurveyState>(context, listen: false);

    _empresaInternetCtrl.text = _state.empresaInternet ?? '';
    _cantSalonesCtrl.text = _state.cantidadSalones ?? '';
    _estadoSalonesCtrl.text = _state.estadoSalones ?? '';
    _cantComedorCtrl.text = _state.cantidadComedor ?? '';
    _estadoComedorCtrl.text = _state.estadoComedor ?? '';
    _cantCocinaCtrl.text = _state.cantidadCocina ?? '';
    _estadoCocinaCtrl.text = _state.estadoCocina ?? '';
    _cantSalonReunionesCtrl.text = _state.cantidadSalonReuniones ?? '';
    _estadoSalonReunionesCtrl.text = _state.estadoSalonReuniones ?? '';
    _cantHabitacionesCtrl.text = _state.cantidadHabitaciones ?? '';
    _estadoHabitacionesCtrl.text = _state.estadoHabitaciones ?? '';
    _cantBanosCtrl.text = _state.cantidadBanos ?? '';
    _estadoBanosCtrl.text = _state.estadoBanos ?? '';
    _cantOtrosEspaciosCtrl.text = _state.cantidadOtrosEspacios ?? '';
    _estadoOtrosEspaciosCtrl.text = _state.estadoOtrosEspacios ?? '';
    _descOtrosEspaciosCtrl.text = _state.descripcionOtrosEspacios ?? '';

    for (final item in UnifiedSurveyState.mobiliarioItemsList) {
      final code = item['code']!;
      final mob = _state.mobiliarioItems[code];
      _mobCtrl[code] = {
        'cantidad':
            TextEditingController(text: mob?.cantidad?.toString() ?? ''),
        'texto': TextEditingController(text: mob?.texto ?? ''),
        'observaciones':
            TextEditingController(text: mob?.observaciones ?? ''),
      };
    }

    _dotNecMobCocinaCtrl.text = _state.dotNecesidadesMobiliarioCocina ?? '';
    _dotNecUtensiliosCocinaCtrl.text =
        _state.dotNecesidadesUtensiliosCocina ?? '';
    _dotNecEmergenciaCtrl.text = _state.dotNecesidadesEmergencia ?? '';
  }

  @override
  void dispose() {
    _empresaInternetCtrl.dispose();
    _cantSalonesCtrl.dispose();
    _estadoSalonesCtrl.dispose();
    _cantComedorCtrl.dispose();
    _estadoComedorCtrl.dispose();
    _cantCocinaCtrl.dispose();
    _estadoCocinaCtrl.dispose();
    _cantSalonReunionesCtrl.dispose();
    _estadoSalonReunionesCtrl.dispose();
    _cantHabitacionesCtrl.dispose();
    _estadoHabitacionesCtrl.dispose();
    _cantBanosCtrl.dispose();
    _estadoBanosCtrl.dispose();
    _cantOtrosEspaciosCtrl.dispose();
    _estadoOtrosEspaciosCtrl.dispose();
    _descOtrosEspaciosCtrl.dispose();
    for (final ctrls in _mobCtrl.values) {
      for (final c in ctrls.values) c.dispose();
    }
    _dotNecMobCocinaCtrl.dispose();
    _dotNecUtensiliosCocinaCtrl.dispose();
    _dotNecEmergenciaCtrl.dispose();
    super.dispose();
  }

  String? _val(TextEditingController c) {
    final t = c.text.trim();
    return t.isNotEmpty ? t : null;
  }

  void _saveToState() {
    _state.empresaInternet = _val(_empresaInternetCtrl);
    _state.cantidadSalones = _val(_cantSalonesCtrl);
    _state.estadoSalones = _val(_estadoSalonesCtrl);
    _state.cantidadComedor = _val(_cantComedorCtrl);
    _state.estadoComedor = _val(_estadoComedorCtrl);
    _state.cantidadCocina = _val(_cantCocinaCtrl);
    _state.estadoCocina = _val(_estadoCocinaCtrl);
    _state.cantidadSalonReuniones = _val(_cantSalonReunionesCtrl);
    _state.estadoSalonReuniones = _val(_estadoSalonReunionesCtrl);
    _state.cantidadHabitaciones = _val(_cantHabitacionesCtrl);
    _state.estadoHabitaciones = _val(_estadoHabitacionesCtrl);
    _state.cantidadBanos = _val(_cantBanosCtrl);
    _state.estadoBanos = _val(_estadoBanosCtrl);
    _state.cantidadOtrosEspacios = _val(_cantOtrosEspaciosCtrl);
    _state.estadoOtrosEspacios = _val(_estadoOtrosEspaciosCtrl);
    _state.descripcionOtrosEspacios = _val(_descOtrosEspaciosCtrl);

    for (final item in UnifiedSurveyState.mobiliarioItemsList) {
      final code = item['code']!;
      final mob = _state.mobiliarioItems[code]!;
      mob.cantidad =
          int.tryParse(_mobCtrl[code]!['cantidad']!.text.trim());
      mob.texto = _val(_mobCtrl[code]!['texto']!);
      mob.observaciones = _val(_mobCtrl[code]!['observaciones']!);
    }

    _state.dotNecesidadesMobiliarioCocina = _val(_dotNecMobCocinaCtrl);
    _state.dotNecesidadesUtensiliosCocina = _val(_dotNecUtensiliosCocinaCtrl);
    _state.dotNecesidadesEmergencia = _val(_dotNecEmergenciaCtrl);
  }

  void _onNext() {
    _saveToState();
    _state.notify();
    FormNavigator.pushReplacementForm(
        context, const Phase3EnergiaPage(), stepNumber: 3);
  }

  @override
  Widget build(BuildContext context) {
    return EnhancedFormContainer(
      title: 'Dotación',
      subtitle: 'Servicios, infraestructura y mobiliario',
      currentStep: 2,
      totalSteps: 4,
      showPrevious: true,
      onPrevious: () => FormNavigator.popForm(context),
      onNext: _onNext,
      nextLabel: 'Continuar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Servicios Públicos ───────────────────────────────
          _SectionHeader('Servicios Públicos'),
          const SizedBox(height: 12),
          _buildYesNo(
            label: '¿Tiene gas?',
            value: _state.tieneGas,
            onChanged: (v) => setState(() => _state.tieneGas = v),
          ),
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
            label: '¿Cuenta con Conectividad/Internet?',
            value: _state.tieneInternet,
            onChanged: (v) => setState(() => _state.tieneInternet = v),
          ),
          if (_state.tieneInternet == true) ...[
            const SizedBox(height: 10),
            _buildTextField(
              controller: _empresaInternetCtrl,
              label: '¿Qué empresa presta este servicio de internet?',
            ),
          ],
          const SizedBox(height: 20),

          // ─── Infraestructura — Espacios ───────────────────────
          _SectionHeader('Infraestructura — Espacios'),
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
            cantCtrl: _cantSalonReunionesCtrl,
            estadoCtrl: _estadoSalonReunionesCtrl,
          ),
          _buildSpaceSection(
            label: '¿Tiene habitaciones?',
            spaceName: 'habitaciones',
            value: _state.tieneHabitaciones,
            onChanged: (v) => setState(() => _state.tieneHabitaciones = v),
            cantCtrl: _cantHabitacionesCtrl,
            estadoCtrl: _estadoHabitacionesCtrl,
          ),
          _buildSpaceSection(
            label: '¿Tiene baños?',
            spaceName: 'baños',
            value: _state.tieneBanos,
            onChanged: (v) => setState(() => _state.tieneBanos = v),
            cantCtrl: _cantBanosCtrl,
            estadoCtrl: _estadoBanosCtrl,
          ),
          _buildYesNo(
            label: '¿Tiene otros espacios?',
            value: _state.tieneOtrosEspacios,
            onChanged: (v) => setState(() => _state.tieneOtrosEspacios = v),
          ),
          if (_state.tieneOtrosEspacios == true) ...[
            const SizedBox(height: 10),
            _buildTextField(
                controller: _cantOtrosEspaciosCtrl,
                label: 'Cantidad de otros espacios'),
            const SizedBox(height: 8),
            _buildTextField(
                controller: _estadoOtrosEspaciosCtrl,
                label: 'Estado de otros espacios'),
            const SizedBox(height: 8),
            _buildTextField(
                controller: _descOtrosEspaciosCtrl,
                label: 'Descripción otros espacios',
                maxLines: 2),
          ],
          const SizedBox(height: 20),

          // ─── Ítems de Mobiliario ──────────────────────────────
          _SectionHeader('Ítems de Mobiliario'),
          const SizedBox(height: 8),
          _buildNoteCard(
              'No es un inventario, diligenciar información de las necesidades actuales de la sede educativa.'),
          const SizedBox(height: 12),
          ...UnifiedSurveyState.mobiliarioItemsList.map(
              (item) => _buildMobiliarioItem(item['code']!, item['name']!)),
          const SizedBox(height: 20),

          // ─── Dotación Especial ────────────────────────────────
          _SectionHeader('Dotación Especial'),
          const SizedBox(height: 8),
          _buildNoteCard(
              'No es un inventario, diligenciar información de las necesidades actuales de la sede educativa.'),
          const SizedBox(height: 12),
          _buildYesNo(
            label: '¿Tiene cocina?',
            value: _state.dotTieneCocina,
            onChanged: (v) => setState(() => _state.dotTieneCocina = v),
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _dotNecMobCocinaCtrl,
            label: 'Necesidades mobiliario cocina (Si aplica)',
            hint: 'Ej: mesas, sillas, alacenas...',
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _dotNecUtensiliosCocinaCtrl,
            label: 'Necesidades utensilios cocina (Si aplica)',
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          _buildYesNo(
            label: '¿Necesita botiquín?',
            value: _state.dotNecesitaBotiquin,
            onChanged: (v) => setState(() => _state.dotNecesitaBotiquin = v),
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _dotNecEmergenciaCtrl,
            label: 'Necesidades de emergencia (Si aplica)',
            maxLines: 2,
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
        Text(label,
            style:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
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
      String label, T opt, T? group, void Function(T) onChanged) {
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildMultiSelect({
    required String label,
    required List<String> options,
    required List<String> selected,
    required void Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 4),
        ...options.map((opt) => CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: selected.contains(opt),
              title: Text(opt, style: const TextStyle(fontSize: 14)),
              activeColor: _green,
              onChanged: (checked) {
                final list = List<String>.from(selected);
                if (checked == true) {
                  list.add(opt);
                } else {
                  list.remove(opt);
                }
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
        _buildYesNo(label: label, value: value, onChanged: onChanged),
        if (value == true) ...[
          const SizedBox(height: 8),
          _buildTextField(
              controller: cantCtrl, label: 'Cantidad de $spaceName'),
          const SizedBox(height: 8),
          _buildTextField(
              controller: estadoCtrl, label: 'Estado de $spaceName'),
        ],
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildMobiliarioItem(String code, String name) {
    final ctrls = _mobCtrl[code]!;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(code,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: ctrls['cantidad'],
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: ctrls['texto'],
                    decoration: InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: ctrls['observaciones'],
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Observaciones',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _noteBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w500)),
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
