import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/furniture_survey_state.dart';
import '../../widgets/layout/enhanced_form_container.dart';
import '../../widgets/form/custom_text_field.dart';
import '../../widgets/form/repeating_icon_button.dart';
import '../../utils/form_navigator.dart';
import 'furniture_photos_page.dart';

class FurnitureInfrastructurePage extends StatefulWidget {
  const FurnitureInfrastructurePage({Key? key}) : super(key: key);

  @override
  State<FurnitureInfrastructurePage> createState() => _FurnitureInfrastructurePageState();
}

class _FurnitureInfrastructurePageState extends State<FurnitureInfrastructurePage> {
  final _formKey = GlobalKey<FormState>();
  late FurnitureSurveyState _surveyState;

  final TextEditingController _otrosEspaciosController = TextEditingController();
  final TextEditingController _proyectosEjecucionController = TextEditingController();
  final TextEditingController _serviciosPublicosController = TextEditingController(); // Otros
  // final TextEditingController _electrodomesticosController = TextEditingController(); // Removed


  // Estados locales para checkbox y cantidades
  bool _hasSalones = false; int _cantidadSalones = 0; TextEditingController _estadoSalonesCtrl = TextEditingController();
  bool _hasComedor = false; int _cantidadComedor = 0; TextEditingController _estadoComedorCtrl = TextEditingController();
  bool _hasCocina = false; int _cantidadCocina = 0; TextEditingController _estadoCocinaCtrl = TextEditingController();
  bool _hasSalonReuniones = false; int _cantidadSalonReuniones = 0; TextEditingController _estadoSalonReunionesCtrl = TextEditingController();
  bool _hasHabitaciones = false; int _cantidadHabitaciones = 0; TextEditingController _estadoHabitacionesCtrl = TextEditingController();
  bool _hasBanos = false; int _cantidadBanos = 0; TextEditingController _estadoBanosCtrl = TextEditingController();
  bool _hasOtros = false; int _cantidadOtros = 0; TextEditingController _estadoOtrosCtrl = TextEditingController();

  // Electrodomésticos states
  bool _hasNevera = false; int _cantidadNevera = 0;
  bool _hasTelevisor = false; int _cantidadTelevisor = 0;
  bool _hasComputador = false; int _cantidadComputador = 0;
  bool _hasVentilador = false; int _cantidadVentilador = 0;
  bool _hasVideoBeam = false; int _cantidadVideoBeam = 0;
  bool _hasImpresora = false; int _cantidadImpresora = 0;
  bool _hasEquipoSonido = false; int _cantidadEquipoSonido = 0;
 
  // Dynamic list for other appliances
  List<Map<String, dynamic>> _otrosElectrodomesticos = [];

  bool _hasEnergy = false;
  String? _fuenteEnergia;
  
  bool _hasAgua = false;
  String? _fuenteAgua;

  bool _hasGas = false;
  String? _fuenteGas;

  bool _hasInternet = false;

  @override
  void initState() {
    super.initState();
    _surveyState = Provider.of<FurnitureSurveyState>(context, listen: false);
    _loadData();
  }

  void _loadData() {
    _hasSalones = _surveyState.hasSalones;
    _cantidadSalones = _surveyState.cantidadSalones;
    _estadoSalonesCtrl.text = _surveyState.estadoSalones;

    _hasComedor = _surveyState.hasComedor;
    _cantidadComedor = _surveyState.cantidadComedor;
    _estadoComedorCtrl.text = _surveyState.estadoComedor;

    _hasCocina = _surveyState.hasCocina;
    _cantidadCocina = _surveyState.cantidadCocina;
    _estadoCocinaCtrl.text = _surveyState.estadoCocina;

    _hasSalonReuniones = _surveyState.hasSalonReuniones;
    _cantidadSalonReuniones = _surveyState.cantidadSalonReuniones;
    _estadoSalonReunionesCtrl.text = _surveyState.estadoSalonReuniones;

    _hasHabitaciones = _surveyState.hasHabitaciones;
    _cantidadHabitaciones = _surveyState.cantidadHabitaciones;
    _estadoHabitacionesCtrl.text = _surveyState.estadoHabitaciones;

    _hasBanos = _surveyState.hasBanos;
    _cantidadBanos = _surveyState.cantidadBanos;
    _estadoBanosCtrl.text = _surveyState.estadoBanos;

    _hasOtros = _surveyState.hasOtros;
    _cantidadOtros = _surveyState.cantidadOtros;
    _estadoOtrosCtrl.text = _surveyState.estadoOtros;
    _otrosEspaciosController.text = _surveyState.descripcionOtrosEspacios;

    _proyectosEjecucionController.text = _surveyState.proyectosEjecucion;
    _serviciosPublicosController.text = _surveyState.serviciosPublicos;
    
    _hasEnergy = _surveyState.tieneEnergia;
    _fuenteEnergia = _surveyState.fuenteEnergia;
    
    _hasAgua = _surveyState.tieneAgua;
    _fuenteAgua = _surveyState.fuenteAgua;
    
    _hasGas = _surveyState.tieneGas;
    _fuenteGas = _surveyState.fuenteGas;

    _hasNevera = _surveyState.hasNevera;
    _cantidadNevera = _surveyState.cantidadNevera;

    _hasTelevisor = _surveyState.hasTelevisor;
    _cantidadTelevisor = _surveyState.cantidadTelevisor;

    _hasComputador = _surveyState.hasComputador;
    _cantidadComputador = _surveyState.cantidadComputador;

    _hasVentilador = _surveyState.hasVentilador;
    _cantidadVentilador = _surveyState.cantidadVentilador;

    _hasVideoBeam = _surveyState.hasVideoBeam;
    _cantidadVideoBeam = _surveyState.cantidadVideoBeam;

    _hasImpresora = _surveyState.hasImpresora;
    _cantidadImpresora = _surveyState.cantidadImpresora;

    _hasEquipoSonido = _surveyState.hasEquipoSonido;
    _cantidadEquipoSonido = _surveyState.cantidadEquipoSonido;

    _otrosElectrodomesticos = List.from(_surveyState.otrosElectrodomesticos); // Copy list

    _hasInternet = _surveyState.tieneInternet;
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      // Validaciones de Cantidad para Espacios seleccionados
      if (_hasSalones && _cantidadSalones <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indique la cantidad de Salones')));
        return;
      }
      if (_hasComedor && _cantidadComedor <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indique la cantidad de Comedor')));
        return;
      }
      if (_hasCocina && _cantidadCocina <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indique la cantidad de Cocina')));
        return;
      }
      if (_hasSalonReuniones && _cantidadSalonReuniones <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indique la cantidad de Salón de Reuniones')));
        return;
      }
      if (_hasHabitaciones && _cantidadHabitaciones <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indique la cantidad de Habitaciones')));
        return;
      }
      if (_hasBanos && _cantidadBanos <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indique la cantidad de Baños')));
        return;
      }
      if (_hasOtros && _cantidadOtros <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indique la cantidad de Otros espacios')));
        return;
      }

      // Validaciones de Cantidad para Electrodomésticos seleccionados
      if (_hasNevera && _cantidadNevera <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indique cantidad de Neveras')));
        return;
      }
      if (_hasTelevisor && _cantidadTelevisor <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indique cantidad de Televisores')));
        return;
      }
      if (_hasComputador && _cantidadComputador <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indique cantidad de Computadores')));
        return;
      }
      if (_hasVentilador && _cantidadVentilador <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indique cantidad de Ventiladores')));
        return;
      }
      if (_hasVideoBeam && _cantidadVideoBeam <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indique cantidad de Video Beams')));
        return;
      }
      if (_hasImpresora && _cantidadImpresora <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indique cantidad de Impresoras')));
        return;
      }
      if (_hasEquipoSonido && _cantidadEquipoSonido <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indique cantidad de Equipos de Sonido')));
        return;
      }

      // Validaciones de Servicios Públicos
      // ... (existing checks)
      if (_hasEnergy && (_fuenteEnergia == null || _fuenteEnergia!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione la fuente de energía')));
        return;
      }
      if (_hasAgua && (_fuenteAgua == null || _fuenteAgua!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione la fuente de agua')));
        return;
      }
      if (_hasGas && (_fuenteGas == null || _fuenteGas!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione la fuente de gas')));
        return;
      }

      _surveyState.updateInfrastructure(
        hasSalones: _hasSalones, cantidadSalones: _cantidadSalones, estadoSalones: _estadoSalonesCtrl.text,
        hasComedor: _hasComedor, cantidadComedor: _cantidadComedor, estadoComedor: _estadoComedorCtrl.text,
        hasCocina: _hasCocina, cantidadCocina: _cantidadCocina, estadoCocina: _estadoCocinaCtrl.text,
        hasSalonReuniones: _hasSalonReuniones, cantidadSalonReuniones: _cantidadSalonReuniones, estadoSalonReuniones: _estadoSalonReunionesCtrl.text,
        hasHabitaciones: _hasHabitaciones, cantidadHabitaciones: _cantidadHabitaciones, estadoHabitaciones: _estadoHabitacionesCtrl.text,
        hasBanos: _hasBanos, cantidadBanos: _cantidadBanos, estadoBanos: _estadoBanosCtrl.text,
        hasOtros: _hasOtros, cantidadOtros: _cantidadOtros, estadoOtros: _estadoOtrosCtrl.text,
        descripcionOtrosEspacios: _otrosEspaciosController.text,

        proyectosEjecucion: _proyectosEjecucionController.text,
        serviciosPublicos: _serviciosPublicosController.text,
        
        tieneEnergia: _hasEnergy,
        fuenteEnergia: _hasEnergy ? _fuenteEnergia : '', // Usar variable local string
        
        tieneAgua: _hasAgua,
        fuenteAgua: _hasAgua ? _fuenteAgua : '',

        tieneGas: _hasGas,
        fuenteGas: _hasGas ? _fuenteGas : '',

        hasNevera: _hasNevera, cantidadNevera: _cantidadNevera,
        hasTelevisor: _hasTelevisor, cantidadTelevisor: _cantidadTelevisor,
        hasComputador: _hasComputador, cantidadComputador: _cantidadComputador,
        hasVentilador: _hasVentilador, cantidadVentilador: _cantidadVentilador,
        hasVideoBeam: _hasVideoBeam, cantidadVideoBeam: _cantidadVideoBeam,
        hasImpresora: _hasImpresora, cantidadImpresora: _cantidadImpresora,
        hasEquipoSonido: _hasEquipoSonido, cantidadEquipoSonido: _cantidadEquipoSonido,
        
        otrosElectrodomesticos: _otrosElectrodomesticos,

        tieneInternet: _hasInternet,
      );

      FormNavigator.pushForm(
        context,
        const FurniturePhotosPage(),
        stepNumber: 4,
      );
    }
  }

  Widget _buildRadioOption(String title, String value, String? groupValue, Function(String?) onChanged, IconData icon) {
    final isSelected = groupValue == value;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? Colors.blue 
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected 
            ? Colors.blue.withOpacity(0.05)
            : Colors.white,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(value),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected 
                        ? Colors.blue 
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: isSelected 
                      ? Colors.blue 
                      : Colors.white,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Icon(
                icon,
                color: isSelected 
                    ? Colors.blue 
                    : Colors.grey.shade400,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected 
                        ? FontWeight.w600 
                        : FontWeight.w500,
                    color: isSelected 
                        ? Colors.blue.shade700 
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool value,
    required Function(bool) onChanged,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: color,
                ),
              ],
            ),
          ),
          if (value)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seleccione la fuente principal:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...children,
                ],
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildSpaceCheckbox({
    required String title,
    required IconData icon,
    required bool value,
    required int quantity,
    TextEditingController? stateController,
    required Function(bool) onCheckChanged,
    required Function(int) onQuantityChanged,
    bool isOther = false,
    TextEditingController? otherController,
    String? otherLabel,
    bool showState = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? Colors.green : Colors.grey.shade300,
          width: value ? 2 : 1,
        ),
        color: value ? Colors.green.withOpacity(0.05) : Colors.white,
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onCheckChanged(!value),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  value
                      ? const Icon(Icons.check_box, color: Colors.green)
                      : const Icon(Icons.check_box_outline_blank, color: Colors.grey),
                  const SizedBox(width: 12),
                  Icon(icon, color: value ? Colors.green : Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: value ? FontWeight.bold : FontWeight.normal,
                        color: value ? Colors.green.shade700 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (value) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Cantidad:'),
                  const SizedBox(width: 12),
                  RepeatingIconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: quantity > 0 ? () => onQuantityChanged(quantity - 1) : null,
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  RepeatingIconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => onQuantityChanged(quantity + 1),
                  ),
                ],
              ),
            ),
             if (showState && stateController != null)
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: stateController,
                  validator: (v) => value && (v == null || v.isEmpty) ? 'Requerido: Estado físico' : null,
                  decoration: InputDecoration(
                    labelText: 'Estado físico de : $title',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            if (isOther)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextFormField(
                  controller: otherController ?? _otrosEspaciosController,
                  validator: (v) => value && (v == null || v.isEmpty) ? 'Especifique el espacio' : null,
                  decoration: InputDecoration(
                    labelText: otherLabel ?? 'Especifique otros espacios',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDynamicOtherElectroList() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Otros Equipos / Electrodomésticos',
               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
             IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue),
              onPressed: () {
                setState(() {
                  _otrosElectrodomesticos.add({'name': '', 'quantity': 1});
                });
              },
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _otrosElectrodomesticos.length,
          itemBuilder: (context, index) {
            final item = _otrosElectrodomesticos[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: item['name'],
                        decoration: const InputDecoration(
                          labelText: 'Nombre del equipo',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          item['name'] = val;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                     Row(
                      children: [
                        RepeatingIconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (item['quantity'] > 0) {
                               setState(() {
                                 item['quantity']--;
                               });
                            }
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                        Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        RepeatingIconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() {
                               item['quantity']++;
                             });
                          },
                           constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _otrosElectrodomesticos.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return EnhancedFormContainer(
      title: 'Diagnóstico de Infraestructura',
      subtitle: 'Estado físico y servicios',
      currentStep: 3,
      totalSteps: 5,
      showPrevious: true,
      onPrevious: () => FormNavigator.popForm(context),
      onNext: _onNext,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Seleccione los espacios existentes y su cantidad:',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              
              _buildSpaceCheckbox(
                title: 'Salones', icon: Icons.school, value: _hasSalones, quantity: _cantidadSalones, stateController: _estadoSalonesCtrl,
                onCheckChanged: (v) => setState(() { _hasSalones = v; _cantidadSalones = v ? 1 : 0; }),
                onQuantityChanged: (q) => setState(() => _cantidadSalones = q),
              ),
              _buildSpaceCheckbox(
                title: 'Comedor', icon: Icons.restaurant, value: _hasComedor, quantity: _cantidadComedor, stateController: _estadoComedorCtrl,
                onCheckChanged: (v) => setState(() { _hasComedor = v; _cantidadComedor = v ? 1 : 0; }),
                onQuantityChanged: (q) => setState(() => _cantidadComedor = q),
              ),
              _buildSpaceCheckbox(
                title: 'Cocina', icon: Icons.kitchen, value: _hasCocina, quantity: _cantidadCocina, stateController: _estadoCocinaCtrl,
                onCheckChanged: (v) => setState(() { _hasCocina = v; _cantidadCocina = v ? 1 : 0; }),
                onQuantityChanged: (q) => setState(() => _cantidadCocina = q),
              ),
              _buildSpaceCheckbox(
                title: 'Salón para reuniones', icon: Icons.meeting_room, value: _hasSalonReuniones, quantity: _cantidadSalonReuniones, stateController: _estadoSalonReunionesCtrl,
                onCheckChanged: (v) => setState(() { _hasSalonReuniones = v; _cantidadSalonReuniones = v ? 1 : 0; }),
                onQuantityChanged: (q) => setState(() => _cantidadSalonReuniones = q),
              ),
              _buildSpaceCheckbox(
                title: 'Habitaciones', icon: Icons.bed, value: _hasHabitaciones, quantity: _cantidadHabitaciones, stateController: _estadoHabitacionesCtrl,
                onCheckChanged: (v) => setState(() { _hasHabitaciones = v; _cantidadHabitaciones = v ? 1 : 0; }),
                onQuantityChanged: (q) => setState(() => _cantidadHabitaciones = q),
              ),
              _buildSpaceCheckbox(
                title: 'Baños', icon: Icons.wc, value: _hasBanos, quantity: _cantidadBanos, stateController: _estadoBanosCtrl,
                onCheckChanged: (v) => setState(() { _hasBanos = v; _cantidadBanos = v ? 1 : 0; }),
                onQuantityChanged: (q) => setState(() => _cantidadBanos = q),
              ),
              _buildSpaceCheckbox(
                title: 'Otros espacios', icon: Icons.more_horiz, value: _hasOtros, quantity: _cantidadOtros, stateController: _estadoOtrosCtrl,
                onCheckChanged: (v) => setState(() { _hasOtros = v; if(v) { _cantidadOtros = 1; } else { _cantidadOtros = 0; _otrosEspaciosController.clear(); } }),
                onQuantityChanged: (q) => setState(() => _cantidadOtros = q),
                isOther: true,
              ),

              const SizedBox(height: 12),
              CustomTextField(
                controller: _proyectosEjecucionController,
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                label: 'Proyectos en ejecución y ejecutados de obras por impuesto y la entidad a cargo',
                hintText: 'Remodelaciones, dotaciones...',
                prefixIcon: Icons.engineering,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              
              // --- Energía ---
              _buildServiceSectionCard(
                title: '¿Cuenta con energía eléctrica?',
                icon: Icons.lightbulb,
                color: Colors.amber.shade700,
                value: _hasEnergy,
                onChanged: (val) => setState(() { _hasEnergy = val; if (!val) _fuenteEnergia = null; }),
                children: [
                  _buildRadioOption('Red CENS (Convencional)', 'Red CENS', _fuenteEnergia, (v) => setState(() => _fuenteEnergia = v), Icons.electrical_services),
                  _buildRadioOption('Planta Eléctrica (ACPM/Gasolina)', 'Planta Eléctrica', _fuenteEnergia, (v) => setState(() => _fuenteEnergia = v), Icons.settings_power),
                  _buildRadioOption('Paneles Solares / Renovables', 'Paneles Solares', _fuenteEnergia, (v) => setState(() => _fuenteEnergia = v), Icons.solar_power),
                  _buildRadioOption('Red Artesanal / Contrabando', 'Red Artesanal', _fuenteEnergia, (v) => setState(() => _fuenteEnergia = v), Icons.warning_amber),
                ],
              ),

              // --- Agua ---
              _buildServiceSectionCard(
                title: '¿Cuenta con servicio de agua?',
                icon: Icons.water_drop,
                color: Colors.blue.shade700,
                value: _hasAgua,
                onChanged: (val) => setState(() { _hasAgua = val; if (!val) _fuenteAgua = null; }),
                children: [
                   _buildRadioOption('Acueducto Veredal', 'Acueducto Veredal', _fuenteAgua, (v) => setState(() => _fuenteAgua = v), Icons.water),
                   _buildRadioOption('Pozo', 'Pozo', _fuenteAgua, (v) => setState(() => _fuenteAgua = v), Icons.waves),
                   _buildRadioOption('Río / Quebrada', 'Rio', _fuenteAgua, (v) => setState(() => _fuenteAgua = v), Icons.landscape),
                ],
              ),

              // --- Gas ---
              _buildServiceSectionCard(
                title: '¿Cuenta con servicio de gas?',
                icon: Icons.propane_tank,
                color: Colors.deepOrange.shade600,
                value: _hasGas,
                onChanged: (val) => setState(() { _hasGas = val; if (!val) _fuenteGas = null; }),
                children: [
                   _buildRadioOption('Gas Domiciliario (Red)', 'Gas Domiciliario', _fuenteGas, (v) => setState(() => _fuenteGas = v), Icons.fire_hydrant_alt),
                   _buildRadioOption('Bombonas (Cilindro)', 'Bombonas', _fuenteGas, (v) => setState(() => _fuenteGas = v), Icons.propane),
                ],
              ),

              CustomTextField(
                controller: _serviciosPublicosController,
                validator: (v) => null, // Explícitamente opcional para sobreescribir el default require
                label: 'Otros servicios públicos (Opcional)',
                prefixIcon: Icons.settings_input_component,
                maxLines: 1,
              ),
              const SizedBox(height: 12),

              const SizedBox(height: 12),
              const Text(
                'Seleccione los electrodomésticos y equipos actuales:',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              
              _buildSpaceCheckbox(
                title: 'Nevera / Refrigerador', icon: Icons.kitchen, value: _hasNevera, quantity: _cantidadNevera, showState: false, stateController: null,
                onCheckChanged: (v) => setState(() { _hasNevera = v; _cantidadNevera = v ? 1 : 0; }),
                onQuantityChanged: (q) => setState(() => _cantidadNevera = q),
              ),
              _buildSpaceCheckbox(
                title: 'Televisor', icon: Icons.tv, value: _hasTelevisor, quantity: _cantidadTelevisor, showState: false, stateController: null,
                onCheckChanged: (v) => setState(() { _hasTelevisor = v; _cantidadTelevisor = v ? 1 : 0; }),
                onQuantityChanged: (q) => setState(() => _cantidadTelevisor = q),
              ),
              _buildSpaceCheckbox(
                title: 'Computador', icon: Icons.computer, value: _hasComputador, quantity: _cantidadComputador, showState: false, stateController: null,
                onCheckChanged: (v) => setState(() { _hasComputador = v; _cantidadComputador = v ? 1 : 0; }),
                onQuantityChanged: (q) => setState(() => _cantidadComputador = q),
              ),
              _buildSpaceCheckbox(
                title: 'Ventilador / Aire Acond.', icon: Icons.wind_power, value: _hasVentilador, quantity: _cantidadVentilador, showState: false, stateController: null,
                onCheckChanged: (v) => setState(() { _hasVentilador = v; _cantidadVentilador = v ? 1 : 0; }),
                onQuantityChanged: (q) => setState(() => _cantidadVentilador = q),
              ),
              _buildSpaceCheckbox(
                title: 'Video Beam', icon: Icons.videocam, value: _hasVideoBeam, quantity: _cantidadVideoBeam, showState: false, stateController: null,
                onCheckChanged: (v) => setState(() { _hasVideoBeam = v; _cantidadVideoBeam = v ? 1 : 0; }),
                onQuantityChanged: (q) => setState(() => _cantidadVideoBeam = q),
              ),
              _buildSpaceCheckbox(
                title: 'Impresora', icon: Icons.print, value: _hasImpresora, quantity: _cantidadImpresora, showState: false, stateController: null,
                onCheckChanged: (v) => setState(() { _hasImpresora = v; _cantidadImpresora = v ? 1 : 0; }),
                onQuantityChanged: (q) => setState(() => _cantidadImpresora = q),
              ),
              _buildSpaceCheckbox(
                title: 'Equipo de Sonido', icon: Icons.speaker, value: _hasEquipoSonido, quantity: _cantidadEquipoSonido, showState: false, stateController: null,
                onCheckChanged: (v) => setState(() { _hasEquipoSonido = v; _cantidadEquipoSonido = v ? 1 : 0; }),
                onQuantityChanged: (q) => setState(() => _cantidadEquipoSonido = q),
              ),
              
              _buildDynamicOtherElectroList(),
               
               const SizedBox(height: 12),
               SwitchListTile(
                title: const Text('¿Cuenta con conectividad/internet?'),
                value: _hasInternet,
                onChanged: (val) => setState(() => _hasInternet = val),
                secondary: const Icon(Icons.wifi),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
