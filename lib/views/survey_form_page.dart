import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/generalInfo.dart';
import '../models/survey_state.dart';
import '../widgets/form/custom_text_field.dart';
import '../widgets/form/custom_date_field.dart';
import '../widgets/form/location_dropdown.dart';
import '../widgets/layout/enhanced_form_container.dart';
import '../utils/form_navigator.dart';
import '../utils/location_data.dart';
import 'institutionalFormPage.dart';

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
    if (_generalInfo.department != null) {
      _municipalities = LocationData.getMunicipalities(
        _generalInfo.department!,
      );
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
      if (_generalInfo.municipality != null &&
          !_municipalities.contains(_generalInfo.municipality)) {
        _generalInfo.municipality = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return EnhancedFormContainer(
      title: 'Información General',
      subtitle: 'Datos básicos de la caracterización',
      currentStep: 1,
      onNext: _submitForm,
      showPrevious: false,
      transitionType: FormTransitionType.slideScale,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode:
                _showErrors
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4CAF50).withValues(alpha: 0.1),
                        const Color(0xFF4CAF50).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 32,
                        color: Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Caracterización CENS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E2E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete la información básica para iniciar el proceso de caracterización de la sede educativa',
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

                LocationDropdown(
                  label: 'Departamento',
                  value: _generalInfo.department,
                  placeholder: 'Seleccionar departamento',
                  items: LocationData.departments,
                  prefixIcon: Icons.location_on_outlined,
                  onChanged: (String? newValue) {
                    setState(() {
                      _generalInfo.department = newValue;
                      _updateMunicipalities(newValue);
                    });
                  },
                  validator:
                      (value) =>
                          value == null ? 'Seleccione un departamento' : null,
                ),

                const SizedBox(height: 16),

                LocationDropdown(
                  label: 'Municipio',
                  value: _generalInfo.municipality,
                  placeholder: 'Seleccionar municipio',
                  items: _municipalities,
                  prefixIcon: Icons.location_city_outlined,
                  enabled: _generalInfo.department != null,
                  parentSelection: _generalInfo.department,
                  onChanged: (String? newValue) {
                    setState(() {
                      _generalInfo.municipality = newValue;
                    });
                  },
                  validator:
                      (value) =>
                          value == null ? 'Seleccione un municipio' : null,
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
    );
  }

  void _submitForm() {
    setState(() {
      _showErrors = true;
    });

    if (_formKey.currentState!.validate()) {
      Provider.of<SurveyState>(
        context,
        listen: false,
      ).updateGeneralInfo(_generalInfo);

      // Usar el nuevo sistema de navegación con transiciones
      FormNavigator.pushForm(
        context,
        const InstitutionalFormPage(),
        type: FormTransitionType.slideScale,
        stepNumber: 2,
      );
    } else {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
