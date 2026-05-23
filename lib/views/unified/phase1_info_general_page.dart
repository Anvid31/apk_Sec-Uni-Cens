import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/unified_survey_state.dart';
import '../../widgets/form/custom_text_field.dart';
import '../../widgets/form/custom_dropdown_field.dart';
import '../../widgets/form/photo_capture_field.dart';
import '../../widgets/layout/enhanced_form_container.dart';
import '../../utils/form_navigator.dart';
import '../../utils/location_data.dart';
import '../../config/theme.dart';
import '../../services/location_service.dart';
import 'phase2_dotacion_page.dart';

class Phase1InfoGeneralPage extends StatefulWidget {
  const Phase1InfoGeneralPage({super.key});

  @override
  State<Phase1InfoGeneralPage> createState() => _Phase1InfoGeneralPageState();
}

class _Phase1InfoGeneralPageState extends State<Phase1InfoGeneralPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late UnifiedSurveyState _state;
  bool _showErrors = false;
  bool _isLoadingLocation = false;

  // Text controllers — Información General
  final _corregimientoCtrl = TextEditingController();
  final _veredaCtrl = TextEditingController();
  final _intervieweeNameCtrl = TextEditingController();
  final _intervieweeRoleCtrl = TextEditingController();
  final _intervieweeContactCtrl = TextEditingController();
  final _principalInstitutionCtrl = TextEditingController();
  final _schoolNameCtrl = TextEditingController();
  final _daneCodeCtrl = TextEditingController();
  final _principalNameCtrl = TextEditingController();
  final _principalPhoneCtrl = TextEditingController();
  final _principalEmailCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lonCtrl = TextEditingController();
  final _accessObsCtrl = TextEditingController();
  final _recentProjectsCtrl = TextEditingController();

  // Text controllers — Cobertura
  final _totalStudentsCtrl = TextEditingController();
  final _girlsCtrl = TextEditingController();
  final _boysCtrl = TextEditingController();
  final _refugeeCtrl = TextEditingController();
  final _conflictCtrl = TextEditingController();
  final _ethnicCtrl = TextEditingController();
  final _disabledCtrl = TextEditingController();
  final _teachersCtrl = TextEditingController();
  final _adminCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _state = Provider.of<UnifiedSurveyState>(context, listen: false);
    _corregimientoCtrl.text = _state.corregimiento ?? '';
    _veredaCtrl.text = _state.vereda ?? '';
    _intervieweeNameCtrl.text = _state.intervieweeName ?? '';
    _intervieweeRoleCtrl.text = _state.intervieweeRole ?? '';
    _intervieweeContactCtrl.text = _state.intervieweeContact ?? '';
    _principalInstitutionCtrl.text = _state.principalInstitution ?? '';
    _schoolNameCtrl.text = _state.schoolName ?? '';
    _daneCodeCtrl.text = _state.daneCode ?? '';
    _principalNameCtrl.text = _state.principalName ?? '';
    _principalPhoneCtrl.text = _state.principalPhone ?? '';
    _principalEmailCtrl.text = _state.principalEmail ?? '';
    _latCtrl.text = _state.latitude?.toString() ?? '';
    _lonCtrl.text = _state.longitude?.toString() ?? '';
    _accessObsCtrl.text = _state.accessObservations ?? '';
    _recentProjectsCtrl.text = _state.recentProjects ?? '';
    _totalStudentsCtrl.text = _state.totalStudents?.toString() ?? '';
    _girlsCtrl.text = _state.girlsCount?.toString() ?? '';
    _boysCtrl.text = _state.boysCount?.toString() ?? '';
    _refugeeCtrl.text = _state.refugeeStudents?.toString() ?? '';
    _conflictCtrl.text = _state.conflictVictims?.toString() ?? '';
    _ethnicCtrl.text = _state.ethnicStudents?.toString() ?? '';
    _disabledCtrl.text = _state.disabledStudents?.toString() ?? '';
    _teachersCtrl.text = _state.teachersCount?.toString() ?? '';
    _adminCtrl.text = _state.adminStaff?.toString() ?? '';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _corregimientoCtrl.dispose();
    _veredaCtrl.dispose();
    _intervieweeNameCtrl.dispose();
    _intervieweeRoleCtrl.dispose();
    _intervieweeContactCtrl.dispose();
    _principalInstitutionCtrl.dispose();
    _schoolNameCtrl.dispose();
    _daneCodeCtrl.dispose();
    _principalNameCtrl.dispose();
    _principalPhoneCtrl.dispose();
    _principalEmailCtrl.dispose();
    _latCtrl.dispose();
    _lonCtrl.dispose();
    _accessObsCtrl.dispose();
    _recentProjectsCtrl.dispose();
    _totalStudentsCtrl.dispose();
    _girlsCtrl.dispose();
    _boysCtrl.dispose();
    _refugeeCtrl.dispose();
    _conflictCtrl.dispose();
    _ethnicCtrl.dispose();
    _disabledCtrl.dispose();
    _teachersCtrl.dispose();
    _adminCtrl.dispose();
    super.dispose();
  }

  // Guarda todos los valores de los controllers al state
  void _saveToState() {
    _state.corregimiento =
        _corregimientoCtrl.text.isEmpty ? null : _corregimientoCtrl.text;
    _state.vereda = _veredaCtrl.text.isEmpty ? null : _veredaCtrl.text;
    _state.intervieweeName =
        _intervieweeNameCtrl.text.isEmpty ? null : _intervieweeNameCtrl.text;
    _state.intervieweeRole =
        _intervieweeRoleCtrl.text.isEmpty ? null : _intervieweeRoleCtrl.text;
    _state.intervieweeContact = _intervieweeContactCtrl.text.isEmpty
        ? null
        : _intervieweeContactCtrl.text;
    _state.principalInstitution = _principalInstitutionCtrl.text.isEmpty
        ? null
        : _principalInstitutionCtrl.text;
    _state.schoolName =
        _schoolNameCtrl.text.isEmpty ? null : _schoolNameCtrl.text;
    _state.daneCode = _daneCodeCtrl.text.isEmpty ? null : _daneCodeCtrl.text;
    _state.principalName =
        _principalNameCtrl.text.isEmpty ? null : _principalNameCtrl.text;
    _state.principalPhone =
        _principalPhoneCtrl.text.isEmpty ? null : _principalPhoneCtrl.text;
    _state.principalEmail =
        _principalEmailCtrl.text.isEmpty ? null : _principalEmailCtrl.text;
    _state.latitude = double.tryParse(_latCtrl.text);
    _state.longitude = double.tryParse(_lonCtrl.text);
    _state.accessObservations =
        _accessObsCtrl.text.isEmpty ? null : _accessObsCtrl.text;
    _state.recentProjects =
        _recentProjectsCtrl.text.isEmpty ? null : _recentProjectsCtrl.text;
    _state.totalStudents = int.tryParse(_totalStudentsCtrl.text);
    _state.girlsCount = int.tryParse(_girlsCtrl.text);
    _state.boysCount = int.tryParse(_boysCtrl.text);
    _state.refugeeStudents = int.tryParse(_refugeeCtrl.text);
    _state.conflictVictims = int.tryParse(_conflictCtrl.text);
    _state.ethnicStudents = int.tryParse(_ethnicCtrl.text);
    _state.disabledStudents = int.tryParse(_disabledCtrl.text);
    _state.teachersCount = int.tryParse(_teachersCtrl.text);
    _state.adminStaff = int.tryParse(_adminCtrl.text);
    _state.notify();
  }

  Future<void> _getLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _latCtrl.text = position.latitude.toStringAsFixed(6);
          _lonCtrl.text = position.longitude.toStringAsFixed(6);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo obtener la ubicación. Verifique que el GPS esté activado y que haya concedido permisos.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener ubicación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _onNext() {
    _saveToState();

    // Validar campos de texto con Form
    final formValid = _formKey.currentState?.validate() ?? false;

    // Validar dropdowns requeridos manualmente
    final List<String> missing = [];
    if (_state.municipality == null) missing.add('Municipio');
    if (_state.zone == null) missing.add('Zona');

    if (!formValid || missing.isNotEmpty) {
      setState(() => _showErrors = true);
      if (missing.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complete los campos requeridos: ${missing.join(', ')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Scroll al inicio para mostrar errores
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
      return;
    }

    FormNavigator.pushReplacementForm(
      context,
      const Phase2DotacionPage(),
      stepNumber: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final hPad = (screenWidth * 0.03).clamp(8.0, 20.0);
    final vPad = screenWidth > 600 ? 24.0 : 16.0;
    return EnhancedFormContainer(
      title: 'Información General',
      subtitle: 'Datos de identificación, cobertura y registro fotográfico',
      currentStep: 1,
      totalSteps: 4,
      showPrevious: false,
      showNavigationButtons: false,
      child: Form(
        key: _formKey,
        autovalidateMode:
            _showErrors ? AutovalidateMode.always : AutovalidateMode.disabled,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // ─── SECCIÓN 1: INFORMACIÓN GENERAL ─────────────────────
              _buildSectionCard(
                title: 'Información General',
                icon: Icons.info_outline,
                children: [
                  _InfoDisplayRow(
                    label: 'Fecha',
                    value:
                        '${_state.date.day.toString().padLeft(2, '0')}/${_state.date.month.toString().padLeft(2, '0')}/${_state.date.year}',
                    hint: 'Fecha automática',
                  ),
                  const SizedBox(height: 8),
                  _InfoDisplayRow(
                    label: 'Departamento',
                    value: _state.department,
                  ),
                  const SizedBox(height: 12),
                  _buildRequiredDropdown(
                    label: 'Municipio',
                    value: _state.municipality,
                    items: LocationData.getMunicipalities('Norte de Santander'),
                    hint: 'Seleccione el municipio',
                    icon: Icons.location_city,
                    onChanged: (v) => setState(() => _state.municipality = v),
                  ),
                  _buildRequiredDropdown(
                    label: 'Zona',
                    value: _state.zone,
                    items: const ['Urbano', 'Rural'],
                    hint: 'Seleccione zona',
                    icon: Icons.map_outlined,
                    onChanged: (v) => setState(() => _state.zone = v),
                  ),
                  CustomTextField(
                    label: 'Corregimiento',
                    controller: _corregimientoCtrl,
                    hintText: 'Campo libre',
                  ),
                  CustomTextField(
                    label: 'Vereda',
                    controller: _veredaCtrl,
                    hintText: 'Campo libre',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── SECCIÓN 1b: ENTREVISTADO ────────────────────────────
              _buildSectionCard(
                title: 'Datos del Entrevistado',
                icon: Icons.person_outline,
                children: [
                  CustomTextField(
                    label: 'Nombre del entrevistado',
                    controller: _intervieweeNameCtrl,
                    hintText: 'Campo libre',
                  ),
                  CustomTextField(
                    label: 'Cargo del entrevistado',
                    controller: _intervieweeRoleCtrl,
                    hintText: 'Campo libre',
                  ),
                  CustomTextField(
                    label: 'Contacto del entrevistado',
                    controller: _intervieweeContactCtrl,
                    keyboardType: TextInputType.phone,
                    hintText: 'Número telefónico',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── SECCIÓN 1c: INSTITUCIÓN EDUCATIVA ──────────────────
              _buildSectionCard(
                title: 'Institución Educativa',
                icon: Icons.school_outlined,
                children: [
                  CustomTextField(
                    label: 'Nombre de la Institución Educativa Principal',
                    controller: _principalInstitutionCtrl,
                    showRequiredIndicator: true,
                    hintText: 'Campo libre',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Campo requerido' : null,
                  ),
                  CustomTextField(
                    label: 'Nombre de la sede',
                    controller: _schoolNameCtrl,
                    showRequiredIndicator: true,
                    hintText: 'Campo libre',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Campo requerido' : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextFormField(
                      controller: _daneCodeCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Campo requerido' : null,
                      decoration: const InputDecoration(
                        label: Text.new('Código DANE de la sede *',
                            style: TextStyle(color: Colors.black87)),
                        hintText: 'Campo numérico libre',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  CustomTextField(
                    label: 'Nombre del rector',
                    controller: _principalNameCtrl,
                    hintText: 'Campo libre',
                  ),
                  CustomTextField(
                    label: 'Número telefónico del rector',
                    controller: _principalPhoneCtrl,
                    keyboardType: TextInputType.phone,
                    hintText: 'Campo libre',
                  ),
                  CustomTextField(
                    label: 'Email del rector (campo no obligatorio)',
                    controller: _principalEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Campo libre',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── SECCIÓN 1d: UBICACIÓN Y ACCESO ─────────────────────
              _buildSectionCard(
                title: 'Ubicación y Acceso',
                icon: Icons.location_on_outlined,
                children: [
                  // Coordenadas GPS
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            controller: _latCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^-?\d*\.?\d*')),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Latitud',
                              hintText: 'Numérico',
                              prefixIcon: Icon(Icons.gps_fixed),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            controller: _lonCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^-?\d*\.?\d*')),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Longitud',
                              hintText: 'Numérico',
                              prefixIcon: Icon(Icons.gps_not_fixed),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _isLoadingLocation
                            ? const SizedBox(
                                width: 44,
                                height: 44,
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.my_location),
                                color: AppTheme.primaryColor,
                                tooltip: 'Obtener ubicación actual',
                                onPressed: _getLocation,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _MultiSelectField(
                    label: 'Tipo de acceso',
                    subtitle: 'Selección con varias opciones',
                    options: const [
                      'Vehicular (Carretera)',
                      'Fluvial (Río)',
                      'Camino Herradura (Trocha)',
                    ],
                    selected: _state.accessTypes,
                    onChanged: (v) => setState(() => _state.accessTypes = v),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: 'Observaciones de acceso a la sede',
                    controller: _accessObsCtrl,
                    maxLines: 3,
                    hintText: 'Texto libre',
                  ),
                  CustomTextField(
                    label: 'Proyectos ejecutados en los últimos 2 años',
                    controller: _recentProjectsCtrl,
                    maxLines: 4,
                    hintText:
                        'Mencione proyectos de infraestructura, dotación, energía, agua, etc. y la entidad u organización.',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── SECCIÓN 2: COBERTURA ────────────────────────────────
              _buildSectionCard(
                title: 'Cobertura',
                icon: Icons.people_outline,
                children: [
                  _buildNumericRequired(
                    label: 'Estudiantes matriculados en la sede educativa',
                    ctrl: _totalStudentsCtrl,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumericRequired(
                          label: 'Número de niñas',
                          ctrl: _girlsCtrl,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNumericRequired(
                          label: 'Número de niños',
                          ctrl: _boysCtrl,
                        ),
                      ),
                    ],
                  ),
                  _buildNumericRequired(
                    label: 'Estudiantes refugiados o migrantes',
                    ctrl: _refugeeCtrl,
                  ),
                  _buildNumericRequired(
                    label: 'Estudiantes víctimas del conflicto',
                    ctrl: _conflictCtrl,
                  ),
                  _buildNumericRequired(
                    label: 'Estudiantes pertenecientes a una etnia',
                    ctrl: _ethnicCtrl,
                  ),
                  _buildNumericRequired(
                    label: 'Estudiantes con alguna condición de discapacidad',
                    ctrl: _disabledCtrl,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextFormField(
                      controller: _teachersCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Número de docentes',
                        hintText: 'Texto libre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  _buildNumericRequired(
                    label:
                        'Número de personas administrativas, directivos, personal de aseo',
                    ctrl: _adminCtrl,
                  ),
                  const SizedBox(height: 8),
                  _MultiSelectField(
                    label: 'Niveles educativos',
                    subtitle: 'Selección con varias opciones',
                    options: const [
                      'Preescolar',
                      'Básica Primaria',
                      'Básica Secundaria',
                      'Media',
                    ],
                    selected: _state.educationLevels,
                    onChanged: (v) =>
                        setState(() => _state.educationLevels = v),
                  ),
                  const SizedBox(height: 8),
                  _RadioSelectField(
                    label: 'Jornada Académica',
                    subtitle: 'Única opción',
                    options: const [
                      'Jornada Única',
                      'Mañana',
                      'Tarde',
                      'Mañana y Tarde',
                    ],
                    selected: _state.academicSchedule,
                    onChanged: (v) =>
                        setState(() => _state.academicSchedule = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── SECCIÓN 3: REGISTRO FOTOGRÁFICO ────────────────────
              _buildSectionCard(
                title: 'Registro Fotográfico',
                icon: Icons.photo_camera_outlined,
                children: [
                  PhotoCaptureField(
                    label: 'Foto Frente de la sede educativa',
                    imagePath: _state.photoFront,
                    onImageSelected: (p) =>
                        setState(() => _state.photoFront = p),
                  ),
                  PhotoCaptureField(
                    label: 'Foto Aula 1',
                    imagePath: _state.photoClassroom1,
                    onImageSelected: (p) =>
                        setState(() => _state.photoClassroom1 = p),
                  ),
                  PhotoCaptureField(
                    label: 'Foto Aula 2',
                    imagePath: _state.photoClassroom2,
                    onImageSelected: (p) =>
                        setState(() => _state.photoClassroom2 = p),
                  ),
                  PhotoCaptureField(
                    label: 'Foto Cocina (Si aplica)',
                    imagePath: _state.photoKitchen,
                    onImageSelected: (p) =>
                        setState(() => _state.photoKitchen = p),
                  ),
                  PhotoCaptureField(
                    label: 'Foto Comedor',
                    imagePath: _state.photoDiningRoom,
                    onImageSelected: (p) =>
                        setState(() => _state.photoDiningRoom = p),
                  ),
                  PhotoCaptureField(
                    label: 'Foto baño principal de la sede educativa',
                    imagePath: _state.photoBathroom,
                    onImageSelected: (p) =>
                        setState(() => _state.photoBathroom = p),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ─── BOTÓN CONTINUAR (al final del formulario) ──────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _onNext,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text(
                    'Continuar',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.secondaryColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.secondaryColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 12),
              child: Divider(height: 1),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  // Widget helper: dropdown con indicador de requerido
  Widget _buildRequiredDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropdownField(
            label: '$label *',
            value: value,
            items: items,
            onChanged: onChanged,
            hintText: hint,
            prefixIcon: icon,
          ),
          if (_showErrors && value == null)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Text(
                'Campo requerido',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget helper: campo numérico requerido
  Widget _buildNumericRequired({
    required String label,
    required TextEditingController ctrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
        decoration: InputDecoration(
          label: Text.rich(
            TextSpan(
              text: label,
              children: const [
                TextSpan(
                    text: ' *', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          hintText: 'Numérico',
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

// ─── WIDGETS AUXILIARES ───────────────────────────────────────────────────────

/// Encabezado de sección con fondo verde oscuro
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Fila de información de solo lectura (fecha, departamento)
class _InfoDisplayRow extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;

  const _InfoDisplayRow({
    required this.label,
    required this.value,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hint != null ? '$value  ($hint)' : value,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontStyle:
                    hint != null ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grupo de checkboxes para selección múltiple
class _MultiSelectField extends StatelessWidget {
  final String label;
  final String? subtitle;
  final List<String> options;
  final List<String> selected;
  final void Function(List<String>) onChanged;

  const _MultiSelectField({
    required this.label,
    this.subtitle,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 6),
          ...options.map((opt) {
            final checked = selected.contains(opt);
            return CheckboxListTile(
              dense: true,
              title: Text(opt, style: const TextStyle(fontSize: 14)),
              value: checked,
              activeColor: AppTheme.primaryColor,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) {
                final updated = List<String>.from(selected);
                if (v == true) {
                  updated.add(opt);
                } else {
                  updated.remove(opt);
                }
                onChanged(updated);
              },
            );
          }),
        ],
      ),
    );
  }
}

/// Grupo de radio buttons para selección única
class _RadioSelectField extends StatelessWidget {
  final String label;
  final String? subtitle;
  final List<String> options;
  final String? selected;
  final void Function(String?) onChanged;

  const _RadioSelectField({
    required this.label,
    this.subtitle,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 6),
          ...options.map((opt) {
            return RadioListTile<String>(
              dense: true,
              title: Text(opt, style: const TextStyle(fontSize: 14)),
              value: opt,
              groupValue: selected,
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.zero,
              onChanged: onChanged,
            );
          }),
        ],
      ),
    );
  }
}
