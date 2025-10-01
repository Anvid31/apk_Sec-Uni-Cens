import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/institutionalInfo.dart';
import '../models/survey_state.dart';
import '../widgets/form/index.dart';
import '../widgets/layout/enhanced_form_container.dart';
import '../utils/form_navigator.dart';
import 'coverageFormPage.dart';

class InstitutionalFormPage extends StatefulWidget {
  const InstitutionalFormPage({super.key});

  @override
  State<InstitutionalFormPage> createState() => _InstitutionalFormPageState();
}

class _InstitutionalFormPageState extends State<InstitutionalFormPage> {
  final _formKey = GlobalKey<FormState>();
  late InstitutionalInfo _institutionalInfo;
  bool _showErrors = false;
  
  // Agregar controllers
  final _institutionNameController = TextEditingController();
  final _headquartersController = TextEditingController();
  final _principalNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final surveyState = Provider.of<SurveyState>(context, listen: false);
    _institutionalInfo = surveyState.institutionalInfo;
    
    // Inicializar controllers
    _institutionNameController.text = _institutionalInfo.institutionName ?? '';
    _headquartersController.text = _institutionalInfo.educationalHeadquarters ?? '';
    _principalNameController.text = _institutionalInfo.principalName ?? '';
    _contactController.text = _institutionalInfo.contact ?? '';
    _emailController.text = _institutionalInfo.email ?? '';
    
    // Agregar listeners para auto-guardado
    _institutionNameController.addListener(_autoSaveData);
    _headquartersController.addListener(_autoSaveData);
    _principalNameController.addListener(_autoSaveData);
    _contactController.addListener(_autoSaveData);
    _emailController.addListener(_autoSaveData);
  }

  // Método para guardar automáticamente sin validación ni navegación
  Future<void> _autoSaveData() async {
    try {
      // Actualizar datos de controladores antes de guardar
      _institutionalInfo.institutionName = _institutionNameController.text;
      _institutionalInfo.educationalHeadquarters = _headquartersController.text;
      _institutionalInfo.principalName = _principalNameController.text;
      _institutionalInfo.contact = _contactController.text;
      _institutionalInfo.email = _emailController.text;
      
      // Actualizar Provider
      Provider.of<SurveyState>(context, listen: false)
          .updateInstitutionalInfo(_institutionalInfo);
      
      print('💾 Auto-guardado: Datos institucionales actualizados en Provider');
      print('   - Email: ${_institutionalInfo.email}');
    } catch (e) {
      print('⚠️ Error en auto-guardado institucional: $e');
    }
  }

  @override
  void dispose() {
    // Remover listeners antes de hacer dispose
    _institutionNameController.removeListener(_autoSaveData);
    _headquartersController.removeListener(_autoSaveData);
    _principalNameController.removeListener(_autoSaveData);
    _contactController.removeListener(_autoSaveData);
    _emailController.removeListener(_autoSaveData);
    
    _institutionNameController.dispose();
    _headquartersController.dispose();
    _principalNameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }  @override
  Widget build(BuildContext context) {
    return EnhancedFormContainer(
      title: 'Información Institucional',
      subtitle: 'Datos de la institución educativa',
      currentStep: 2,
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
                        const Color(0xFF2196F3).withValues(alpha: 0.1),
                        const Color(0xFF2196F3).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 32,
                        color: Color(0xFF2196F3),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Información Institucional',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E2E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Datos básicos de la institución educativa y sus responsables',
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
                CustomTextField(
                  label: 'Nombre de la Institución Educativa - Principal',
                  controller: _institutionNameController,
                  onChanged: (value) => _institutionalInfo.institutionName = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Nombre Sede Educativa',
                  controller: _headquartersController,
                  onChanged: (value) => _institutionalInfo.educationalHeadquarters = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                LocationField(
                  label: 'Ubicación geográfica de la sede educativa (Coordenadas) - Oprima el botón para adquirir ubicación',
                  initialValue: _institutionalInfo.location,
                  onChanged: (value) => _institutionalInfo.location = value,
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Nombre del Rector',
                  controller: _principalNameController,
                  onChanged: (value) => _institutionalInfo.principalName = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Telefono del Rector',
                  keyboardType: TextInputType.phone,
                  controller: _contactController,
                  onChanged: (value) => _institutionalInfo.contact = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Correo Electrónico del Rector',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  onChanged: (value) => _institutionalInfo.email = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    
                    // Validación básica de formato de email
                    if (!value.contains('@')) {
                      return 'Ingrese un correo electrónico válido';
                    }
                    
                    // Validación completa con expresión regular
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
                    );
                    
                    if (!emailRegex.hasMatch(value)) {
                      return 'Formato de correo inválido (ej: usuario@ejemplo.com)';
                    }
                    
                    // Verificar que tenga una terminación válida
                    final validDomains = [
                      '.com', '.co', '.org', '.net', '.edu', '.gov', 
                      '.es', '.mx', '.ar', '.cl', '.pe', '.ve', '.ec',
                      '.gmail.com', '.hotmail.com', '.yahoo.com', '.outlook.com'
                    ];
                    
                    final hasValidDomain = validDomains.any((domain) => 
                      value.toLowerCase().endsWith(domain));
                    
                    if (!hasValidDomain) {
                      return 'Terminación de correo no válida (ej: .com, .co, .org)';
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
      // Asegurar que todos los datos de los controladores se guarden en el objeto
      _institutionalInfo.institutionName = _institutionNameController.text;
      _institutionalInfo.educationalHeadquarters = _headquartersController.text;
      _institutionalInfo.principalName = _principalNameController.text;
      _institutionalInfo.contact = _contactController.text;
      _institutionalInfo.email = _emailController.text;
      
      // Debug: Verificar que el email se está guardando
      print('✅ Enviando datos institucionales:');
      print('   - Nombre Institución: ${_institutionalInfo.institutionName}');
      print('   - Email: ${_institutionalInfo.email}');
      
      Provider.of<SurveyState>(context, listen: false)
          .updateInstitutionalInfo(_institutionalInfo);
      
      // Usar el nuevo sistema de navegación con transiciones
      FormNavigator.pushForm(
        context,
        const CoverageFormPage(),
        type: FormTransitionType.slideScale,
        stepNumber: 3,
      );
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
