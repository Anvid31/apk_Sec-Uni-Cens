import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/electricity_info.dart';
import '../models/survey_state.dart';
import '../widgets/layout/enhanced_form_container.dart';
import '../utils/form_navigator.dart';
import 'appliancesFormPage.dart';

class ElectricityFormPage extends StatefulWidget {
  const ElectricityFormPage({super.key});

  @override
  State<ElectricityFormPage> createState() => _ElectricityFormPageState();
}

class _ElectricityFormPageState extends State<ElectricityFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _otherServiceController = TextEditingController();
  final _observationsController = TextEditingController();
  late ElectricityInfo _electricityInfo;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _electricityInfo = Provider.of<SurveyState>(context, listen: false).electricityInfo;
    _otherServiceController.text = _electricityInfo.otherElectricServiceDescription ?? '';
    _observationsController.text = _electricityInfo.observations ?? '';
  }

  @override
  void dispose() {
    _otherServiceController.dispose();
    _observationsController.dispose();
    super.dispose();
  }  @override
  Widget build(BuildContext context) {
    return EnhancedFormContainer(
      title: 'Energía Eléctrica',
      subtitle: 'Información sobre servicio eléctrico',
      currentStep: 5,
      onPrevious: () {
        // Guardar el estado actual
        Provider.of<SurveyState>(context, listen: false)
            .updateElectricityInfo(_electricityInfo);
        FormNavigator.popForm(context);
      },
      transitionType: FormTransitionType.slideScale,onNext: () {
        setState(() {
          _showErrors = true;
        });
        
        // Validar que las preguntas estén respondidas
        bool isValid = true;
        
        if (_electricityInfo.hasElectricService == null) {
          isValid = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Por favor, responda si la sede cuenta con servicio'),
                ],
              ),
              backgroundColor: Colors.orange.shade600,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
        
        // Validar que si tiene servicio eléctrico, haya seleccionado el tipo
        if (_electricityInfo.hasElectricService == true && 
            (_electricityInfo.electricServiceType == null || _electricityInfo.electricServiceType!.isEmpty)) {
          isValid = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Por favor, indique de qué manera recibe servicio'),
                ],
              ),
              backgroundColor: Colors.orange.shade600,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
        
        // Validar que si seleccionó "Otro", haya especificado cuál
        if (_electricityInfo.electricServiceType == 'Otro' && 
            (_electricityInfo.otherElectricServiceDescription == null || _electricityInfo.otherElectricServiceDescription!.trim().isEmpty)) {
          isValid = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Por favor, especifique el tipo'),
                ],
              ),
              backgroundColor: Colors.orange.shade600,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
        
        if (_electricityInfo.interestedInSolarPanels == null) {
          isValid = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Por favor, responda sobre el interés en paneles'),
                ],
              ),
              backgroundColor: Colors.orange.shade600,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
          if (isValid && (_formKey.currentState?.validate() ?? false)) {
          // Guardar el estado actual
          Provider.of<SurveyState>(context, listen: false)
              .updateElectricityInfo(_electricityInfo);
          
          // Usar el nuevo sistema de navegación con transiciones suaves
          FormNavigator.pushForm(
            context,
            const AppliancesFormPage(),
            type: FormTransitionType.slideScale,
            stepNumber: 6,
          );
        }      },
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _showErrors 
                ? AutovalidateMode.always 
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header con descripción
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withValues(alpha: 0.1),
                        Colors.orange.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.electrical_services,
                        size: 32,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Servicio de Energía Eléctrica',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E2E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Información sobre el acceso y uso de energía eléctrica en la sede educativa',
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
                const SizedBox(height: 32),
                
                // Primera pregunta - Servicio de energía eléctrica
                _buildQuestionCard(
                  icon: Icons.power,
                  iconColor: Colors.green,
                  question: '¿La sede educativa cuenta con servicio de energía eléctrica?',
                  value: _electricityInfo.hasElectricService,
                  onChanged: (value) {
                    setState(() {
                      _electricityInfo.hasElectricService = value;
                      // Si selecciona "No", limpiar el tipo de servicio y descripción
                      if (value == false) {
                        _electricityInfo.electricServiceType = null;
                        _electricityInfo.otherElectricServiceDescription = null;
                        _otherServiceController.clear();
                      }
                    });
                  },
                  yesLabel: 'Sí, tiene servicio eléctrico',
                  noLabel: 'No, no tiene servicio eléctrico',
                ),

                // Pregunta condicionada - Tipo de servicio eléctrico
                if (_electricityInfo.hasElectricService == true) ...[
                  const SizedBox(height: 16),
                  _buildElectricServiceTypeCard(),
                  const SizedBox(height: 16),
                  _buildObservationsCard(),
                ],

                const SizedBox(height: 24),
                
                // Segunda pregunta - Paneles solares
                _buildQuestionCard(
                  icon: Icons.solar_power,
                  iconColor: Colors.orange,
                  question: '¿Le interesaría instalar paneles solares en la escuela?',
                  value: _electricityInfo.interestedInSolarPanels,
                  onChanged: (value) {
                    setState(() {
                      _electricityInfo.interestedInSolarPanels = value;
                    });
                  },
                  yesLabel: 'Sí, me interesa',
                  noLabel: 'No, no me interesa',
                ),
                
                const SizedBox(height: 80), // Espacio para los botones fijos
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required IconData icon,
    required Color iconColor,
    required String question,
    required bool? value,
    required Function(bool?) onChanged,
    required String yesLabel,
    required String noLabel,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la pregunta
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.05),
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
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E2E),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Opciones de respuesta
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Opción Sí
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: value == true 
                          ? Colors.green 
                          : Colors.grey.shade300,
                      width: value == true ? 2 : 1,
                    ),
                    color: value == true 
                        ? Colors.green.withValues(alpha: 0.05)
                        : Colors.white,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onChanged(true),
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
                                color: value == true 
                                    ? Colors.green 
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                              color: value == true 
                                  ? Colors.green 
                                  : Colors.white,
                            ),
                            child: value == true
                                ? const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.check_circle,
                            color: value == true 
                                ? Colors.green 
                                : Colors.grey.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              yesLabel,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: value == true 
                                    ? FontWeight.w600 
                                    : FontWeight.w500,
                                color: value == true 
                                    ? Colors.green.shade700 
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Opción No
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: value == false 
                          ? Colors.red 
                          : Colors.grey.shade300,
                      width: value == false ? 2 : 1,
                    ),
                    color: value == false 
                        ? Colors.red.withValues(alpha: 0.05)
                        : Colors.white,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onChanged(false),
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
                                color: value == false 
                                    ? Colors.red 
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                              color: value == false 
                                  ? Colors.red 
                                  : Colors.white,
                            ),
                            child: value == false
                                ? const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.cancel,
                            color: value == false 
                                ? Colors.red 
                                : Colors.grey.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              noLabel,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: value == false 
                                    ? FontWeight.w600 
                                    : FontWeight.w500,
                                color: value == false 
                                    ? Colors.red.shade700 
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElectricServiceTypeCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la pregunta
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
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
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings_input_composite,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '¿De qué manera recibe servicio eléctrico la sede?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E2E),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Opciones de respuesta
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildServiceTypeOption(
                  'Red eléctrica y contador de energia',
                  Icons.power_outlined,
                  'Red eléctrica y contador de energia',
                ),
                const SizedBox(height: 8),
                _buildServiceTypeOption(
                  'A través de una vivienda cercana',
                  Icons.cable,
                  'A través de una vivienda cercana',
                ),
                const SizedBox(height: 8),
                _buildServiceTypeOption(
                  'Planta de gasolina o ACPM',
                  Icons.local_gas_station,
                  'Planta de gasolina o ACPM',
                ),
                const SizedBox(height: 8),
                _buildServiceTypeOption(
                  'Conectado de Manera Irregular',
                  Icons.local_gas_station,
                  'Conectado de Manera Irregular',
                ),
                const SizedBox(height: 8),
                _buildServiceTypeOption(
                  'Conectado de Red Construida por la Comunidad',
                  Icons.local_gas_station,
                  'Conectado de Red Construida por la Comunidad',
                ),
                const SizedBox(height: 8),
                _buildServiceTypeOption(
                  'Energias Renovables (Paneles solares, hídrico, biomasa, etc.)',
                  Icons.local_gas_station,
                  'Energias Renovables (Paneles solares, hídrico, biomasa, etc.)',
                ),
                
                // Campo de texto para "Otro" - aparece cuando se selecciona Otro
                if (_electricityInfo.electricServiceType == 'Otro') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              color: Colors.blue.shade600,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Especifique el tipo:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _otherServiceController,
                          onChanged: (value) {
                            _electricityInfo.otherElectricServiceDescription = value.trim();
                          },
                          decoration: InputDecoration(
                            hintText: 'Ej: Planta eléctrica comunitaria, micro-hidráulica, etc.',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (_electricityInfo.electricServiceType == 'Otro' && 
                                (value == null || value.trim().isEmpty)) {
                              return 'Por favor, especifique el tipo de servicio';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationsCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la sección
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.05),
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
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.comment,
                    color: Colors.purple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Observaciones y Comentarios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E2E),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Campo de texto
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agregue cualquier observación o comentario adicional sobre el servicio eléctrico:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade50,
                  ),
                  child: TextFormField(
                    controller: _observationsController,
                    onChanged: (value) {
                      _electricityInfo.observations = value.trim().isEmpty ? null : value.trim();
                    },
                    maxLines: 4,
                    minLines: 3,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Ej: Calidad del servicio, cortes frecuentes, horarios de disponibilidad, voltaje, problemas técnicos, etc.',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTypeOption(String label, IconData icon, String value) {
    final isSelected = _electricityInfo.electricServiceType == value;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? Colors.blue 
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected 
            ? Colors.blue.withValues(alpha: 0.05)
            : Colors.white,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _electricityInfo.electricServiceType = value;
            // Si no selecciona "Otro", limpiar la descripción
            if (value != 'Otro') {
              _electricityInfo.otherElectricServiceDescription = null;
              _otherServiceController.clear();
            }
          });
        },
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
                  label,
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
}
