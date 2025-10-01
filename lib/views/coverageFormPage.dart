import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/coverageInfo.dart';
import '../models/survey_state.dart';
import '../widgets/form/number_field_widget.dart';
import '../widgets/layout/enhanced_form_container.dart';
import '../utils/form_navigator.dart';
import 'infrastructureFormPage.dart';

class CoverageFormPage extends StatefulWidget {
  const CoverageFormPage({super.key});

  @override
  State<CoverageFormPage> createState() => _CoverageFormPageState();
}

class _CoverageFormPageState extends State<CoverageFormPage> {
  final _formKey = GlobalKey<FormState>();
  late CoverageInfo _coverageInfo;
  final _educationalLevelsController = TextEditingController();
  bool _showErrors = false;

  final List<String> _availableLevels = [
    'Preescolar',
    'Primaria',
    'Secundaria',
  ];

  List<String> _selectedLevels = [];

  @override
  void initState() {
    super.initState();
    final surveyState = Provider.of<SurveyState>(context, listen: false);
    _coverageInfo = surveyState.coverageInfo;
    
    // Inicializar selectedLevels basado en los campos booleanos si existen
    _selectedLevels = [];
    if (_coverageInfo.preescolar == true) _selectedLevels.add('Preescolar');
    if (_coverageInfo.primaria == true) _selectedLevels.add('Primaria');
    if (_coverageInfo.segundaria == true) _selectedLevels.add('Secundaria');
    
    // Si no hay booleanos definidos, usar educationalLevels como fallback
    if (_selectedLevels.isEmpty && _coverageInfo.educationalLevels != null) {
      _selectedLevels = _coverageInfo.educationalLevels ?? [];
    }
    
    _educationalLevelsController.text = _selectedLevels.join(', ');
  }

  @override
  void dispose() {
    _educationalLevelsController.dispose();
    super.dispose();
  }

  void _updateSelectedLevels(List<String> levels) {
    setState(() {
      _selectedLevels = levels;
      _coverageInfo.educationalLevels = levels;
      _educationalLevelsController.text = levels.join(', ');
      
      // Actualizar campos booleanos basados en los niveles seleccionados
      _coverageInfo.preescolar = levels.contains('Preescolar');
      _coverageInfo.primaria = levels.contains('Primaria');
      _coverageInfo.segundaria = levels.contains('Secundaria');
    });
  }

  void _showLevelsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Niveles educativos'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: _availableLevels.map((level) {
                    return CheckboxListTile(
                      title: Text(level),
                      value: _selectedLevels.contains(level),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected ?? false) {
                            if (!_selectedLevels.contains(level)) {
                              _selectedLevels.add(level);
                            }
                          } else {
                            _selectedLevels.remove(level);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    _updateSelectedLevels(_selectedLevels);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return EnhancedFormContainer(
      title: 'Cobertura',
      subtitle: 'Información de cobertura educativa',
      currentStep: 3,
      onPrevious: () => FormNavigator.popForm(context),
      onNext: _submitForm,
      transitionType: FormTransitionType.slideScale,
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
                // Caja informativa con descripción
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF9800).withValues(alpha: 0.1),
                        const Color(0xFFFF9800).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 32,
                        color: Color(0xFFFF9800),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Cobertura Educativa',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E2E),
                        ),
                        textAlign: TextAlign.center,                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Información sobre estudiantes, docentes y niveles educativos ofertados',
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
                
                CustomNumberField(
                  label: 'N° alumnos Totales',
                  initialValue: _coverageInfo.totalStudents,
                  onChanged: (value) => _coverageInfo.totalStudents = value,
                ),
                
                const SizedBox(height: 16),
                
                CustomNumberField(
                  label: 'N° niños',
                  initialValue: _coverageInfo.boysCount,
                  onChanged: (value) => _coverageInfo.boysCount = value,
                ),
                
                const SizedBox(height: 16),
                
                CustomNumberField(
                  label: 'N° niñas',
                  initialValue: _coverageInfo.girlsCount,
                  onChanged: (value) => _coverageInfo.girlsCount = value,
                ),
                
                const SizedBox(height: 16),
                
                CustomNumberField(
                  label: 'N° Docentes',
                  initialValue: _coverageInfo.teachersCount,
                  onChanged: (value) => _coverageInfo.teachersCount = value,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _educationalLevelsController,
                  decoration: InputDecoration(
                    labelText: 'Niveles educativos ofertados',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: _showLevelsDialog,
                    ),
                  ),
                  readOnly: true,
                  onTap: _showLevelsDialog,
                  validator: (value) {
                    if (_selectedLevels.isEmpty) {
                      return 'Seleccione al menos un nivel educativo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _submitForm() {
    setState(() {
      _showErrors = true;
    });

    if (_formKey.currentState!.validate()) {
      // Validaciones adicionales
      if (_coverageInfo.totalStudents != (_coverageInfo.boysCount ?? 0) + (_coverageInfo.girlsCount ?? 0)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El número total de alumnos debe ser igual a la suma de niños y niñas'),
            backgroundColor: Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
        return;
      }

      Provider.of<SurveyState>(context, listen: false)
          .updateCoverageInfo(_coverageInfo);
      
      // Usar el nuevo sistema de navegación con transiciones
      FormNavigator.pushForm(
        context,
        const InfrastructureFormPage(),
        type: FormTransitionType.slideScale,
        stepNumber: 4,      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos requeridos'),
          backgroundColor: Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }
}
