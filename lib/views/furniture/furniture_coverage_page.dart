import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/furniture_survey_state.dart';
import '../../widgets/layout/enhanced_form_container.dart';
import '../../widgets/form/custom_number_field.dart';
import '../../utils/form_navigator.dart';
import 'furniture_infrastructure_page.dart';

class FurnitureCoveragePage extends StatefulWidget {
  const FurnitureCoveragePage({Key? key}) : super(key: key);

  @override
  State<FurnitureCoveragePage> createState() => _FurnitureCoveragePageState();
}

class _FurnitureCoveragePageState extends State<FurnitureCoveragePage> {
  final _formKey = GlobalKey<FormState>();
  late FurnitureSurveyState _surveyState;

  final TextEditingController _numAlumnosController = TextEditingController();
  final TextEditingController _numMujeresController = TextEditingController();
  final TextEditingController _numHombresController = TextEditingController();
  final TextEditingController _numDocentesController = TextEditingController();
  final TextEditingController _aniosFuncionamientoController = TextEditingController();
  final TextEditingController _technicalModalityController = TextEditingController();
  
  final List<String> _availableLevels = [
    'Preescolar',
    'Primaria',
    'Secundaria',
  ];
  final List<String> _selectedLevels = [];
  
  String? _selectedJornada;
  final List<String> _jornadaOptions = ['Única', 'Tarde', 'Mañana', 'Mañana y Tarde'];

  @override
  void initState() {
    super.initState();
    _surveyState = Provider.of<FurnitureSurveyState>(context, listen: false);
    _loadData();
    
    // Escuchar cambios para calcular total
    _numMujeresController.addListener(_updateTotal);
    _numHombresController.addListener(_updateTotal);
  }

  void _updateTotal() {
    final mujeres = int.tryParse(_numMujeresController.text) ?? 0;
    final hombres = int.tryParse(_numHombresController.text) ?? 0;
    _numAlumnosController.text = (mujeres + hombres).toString();
  }

  @override
  void dispose() {
    _numMujeresController.removeListener(_updateTotal);
    _numHombresController.removeListener(_updateTotal);
    _numAlumnosController.dispose();
    _numMujeresController.dispose();
    _numHombresController.dispose();
    _numDocentesController.dispose();
    _aniosFuncionamientoController.dispose();
    _technicalModalityController.dispose();
    super.dispose();
  }

  void _loadData() {
    _numAlumnosController.text = _surveyState.numAlumnos;
    _numMujeresController.text = _surveyState.numMujeres;
    _numHombresController.text = _surveyState.numHombres;
    _numDocentesController.text = _surveyState.numDocentes;
    _aniosFuncionamientoController.text = _surveyState.aniosFuncionamiento;
    
    if (_surveyState.nivelesEducativos != null) {
      _selectedLevels.addAll(_surveyState.nivelesEducativos!);
    }
    _selectedJornada = _surveyState.jornada;
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      if (_selectedLevels.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe seleccionar al menos un nivel educativo')),
        );
        return;
      }
      
      _surveyState.updateCoverage(
        numAlumnos: _numAlumnosController.text,
        numMujeres: _numMujeresController.text,
        numHombres: _numHombresController.text,
        numDocentes: _numDocentesController.text,
        aniosFuncionamiento: _aniosFuncionamientoController.text,
        nivelesEducativos: _selectedLevels,
        jornada: _selectedJornada,
      );

      FormNavigator.pushForm(
        context,
        const FurnitureInfrastructurePage(),
        stepNumber: 3,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor diligencie todos los campos obligatorios'),
           backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return EnhancedFormContainer(
        title: 'Cobertura',
        subtitle: 'Información Estudiantil y Docente',
        currentStep: 2,
        totalSteps: 5,
        showPrevious: true,
        onPrevious: () => FormNavigator.popForm(context),
        onNext: _onNext,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomNumberField(
                        controller: _numMujeresController,
                        label: 'Cant. Mujeres',
                        icon: Icons.female,
                        isRequired: true,
                        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                        onChanged: (_) {}, // Trigger listener
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomNumberField(
                        controller: _numHombresController,
                        label: 'Cant. Hombres',
                        icon: Icons.male,
                        isRequired: true,
                        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                        onChanged: (_) {}, // Trigger listener
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomNumberField(
                  controller: _numAlumnosController,
                  label: 'Número total de alumnos matriculados',
                  icon: Icons.groups,
                  readOnly: true,
                  isRequired: true,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                CustomNumberField(
                  controller: _numDocentesController,
                  label: 'Número de docentes asignados',
                  icon: Icons.person_pin,
                  isRequired: true,
                   validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                CustomNumberField(
                  controller: _aniosFuncionamientoController,
                  label: 'Años de funcionamiento de la sede',
                  icon: Icons.history,
                  isRequired: true,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                
                const SizedBox(height: 24),
                const Text.rich(
                  TextSpan(
                    text: 'Niveles educativos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    children: [
                      TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                ..._availableLevels.map((level) {
                  return CheckboxListTile(
                    title: Text(level),
                    value: _selectedLevels.contains(level),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected ?? false) {
                          _selectedLevels.add(level);
                        } else {
                          _selectedLevels.remove(level);
                        }
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  );
                }),

                const SizedBox(height: 24),
                const Text.rich(
                  TextSpan(
                    text: 'Jornada',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    children: [
                      TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedJornada,
                  items: _jornadaOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _selectedJornada = val),
                  validator: (v) => v == null ? 'Seleccione una jornada' : null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Seleccione la jornada',
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
