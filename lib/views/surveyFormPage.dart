import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/generalInfo.dart';
import '../models/survey_state.dart';
import '../widgets/form/custom_text_field.dart';
import '../widgets/form/custom_date_field.dart';
import '../widgets/form/form_navigation_buttons.dart';
import '../widgets/layout/form_container.dart';
import '../utils/location_data.dart';

class SurveyFormPage extends StatefulWidget {
  const SurveyFormPage({super.key});

  @override
  State<SurveyFormPage> createState() => _SurveyFormPageState();
}

class _SurveyFormPageState extends State<SurveyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  late GeneralInfo _generalInfo;
  List<String> _municipalities = [];
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _generalInfo = Provider.of<SurveyState>(context, listen: false).generalInfo;
    // Si ya hay un departamento seleccionado, cargar sus municipios
    if (_generalInfo.department != null) {
      _municipalities = LocationData.getMunicipalities(_generalInfo.department!);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateMunicipalities(String? department) {
    if (department == null) return;
    
    setState(() {
      _municipalities = LocationData.getMunicipalities(department);
      // Solo resetear el municipio si el nuevo no está en la lista
      if (_generalInfo.municipality != null && 
          !_municipalities.contains(_generalInfo.municipality)) {
        _generalInfo.municipality = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormContainer(
      title: 'Información General',
      currentStep: 1,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _showErrors 
                      ? AutovalidateMode.always 
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información General',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      CustomDateField(
                        label: 'Fecha de Diligenciamiento',
                        initialDate: _generalInfo.date,
                        onDateSelected: (date) {
                          setState(() {
                            _generalInfo.date = date;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo de Departamento con menú desplegable
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Departamento',
                          border: OutlineInputBorder(),
                        ),
                        value: _generalInfo.department,
                        isExpanded: true,
                        items: LocationData.departments.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _generalInfo.department = newValue;
                            _updateMunicipalities(newValue);
                          });
                        },
                        validator: (value) => value == null ? 'Seleccione un departamento' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo de Municipio con menú desplegable
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Municipio',
                          border: OutlineInputBorder(),
                        ),
                        value: _generalInfo.municipality,
                        isExpanded: true,
                        items: _municipalities.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: _generalInfo.department != null
                            ? (String? newValue) {
                                setState(() {
                                  _generalInfo.municipality = newValue;
                                });
                              }
                            : null,
                        validator: (value) => value == null ? 'Seleccione un municipio' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      CustomTextField(
                        label: 'Corregimiento',
                        onChanged: (value) => _generalInfo.district = value,
                        validator: (value) => null, // Campo no obligatorio
                      ),
                      const SizedBox(height: 16),
                      
                      CustomTextField(
                        label: 'Vereda',
                        onChanged: (value) => _generalInfo.village = value,
                        validator: (value) => null, // Campo no obligatorio
                      ),
                      const SizedBox(height: 16),
                      
                      CustomTextField(
                        label: 'Nombre del Entrevistado/a y cargo',
                        maxLines: 2,
                        onChanged: (value) => _generalInfo.intervieweeName = value,
                      ),
                      const SizedBox(height: 16),
                      
                      CustomTextField(
                        label: 'Contacto',
                        hintText: 'Teléfono y/o correo electrónico',
                        onChanged: (value) => _generalInfo.contact = value,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Este Container siempre debe ser el último elemento
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: FormNavigationButtons(
              onPrevious: () => Navigator.pop(context),
              onNext: _submitForm,
              showPrevious: false,
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    setState(() {
      _showErrors = true;
    });

    if (_formKey.currentState!.validate()) {
      // Guardar datos en el provider
      Provider.of<SurveyState>(context, listen: false)
          .updateGeneralInfo(_generalInfo);
      Navigator.pushNamed(context, '/institutional');
    } else {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
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