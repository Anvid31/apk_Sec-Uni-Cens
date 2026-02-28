import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/furniture_survey_state.dart';
import '../../widgets/layout/enhanced_form_container.dart';
import '../../utils/form_navigator.dart';
import '../../utils/location_data.dart';
import '../../widgets/form/location_dropdown.dart';
import '../../widgets/form/location_field.dart';
import '../../widgets/form/custom_text_field.dart';
import 'furniture_coverage_page.dart';

class FurnitureGeneralPage extends StatefulWidget {
  const FurnitureGeneralPage({Key? key}) : super(key: key);

  @override
  State<FurnitureGeneralPage> createState() => _FurnitureGeneralPageState();
}

class _FurnitureGeneralPageState extends State<FurnitureGeneralPage> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  late FurnitureSurveyState _surveyState;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController();
  final TextEditingController _corregimientoController =
      TextEditingController();
  final TextEditingController _veredaController = TextEditingController();

  final TextEditingController _intervieweeNameController =
      TextEditingController();
  final TextEditingController _intervieweePositionController =
      TextEditingController();
  final TextEditingController _intervieweeContactController =
      TextEditingController();

  final TextEditingController _mainInstitutionNameController =
      TextEditingController();
  final TextEditingController _institutionNameController =
      TextEditingController();
  final TextEditingController _principalNameController =
      TextEditingController();
  final TextEditingController _principalContactController =
      TextEditingController();
  final TextEditingController _principalEmailController =
      TextEditingController();
  final TextEditingController _daneController = TextEditingController();

  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _accessObservationsController =
      TextEditingController();
  final TextEditingController _closureRiskReasonController =
      TextEditingController();

  // Keys para hacer scroll al primer campo inválido
  final _departmentKey = GlobalKey();
  final _municipalityKey = GlobalKey();
  final _zoneKey = GlobalKey();
  final _intervieweeNameKey = GlobalKey();
  final _intervieweePositionKey = GlobalKey();
  final _intervieweeContactKey = GlobalKey();
  final _mainInstitutionKey = GlobalKey();
  final _institutionNameKey = GlobalKey();
  final _closureReasonKey = GlobalKey();
  final _principalNameKey = GlobalKey();
  final _principalContactKey = GlobalKey();
  final _accessTypeKey = GlobalKey();
  final _accessObsKey = GlobalKey();

  List<String> _municipalities = [];
  String? _selectedZone;
  String? _selectedAccessType;
  bool _riskOfClosure = false;

  final List<String> _accessTypeOptions = [
    'Vehicular (Carretera)',
    'Fluvial (Rio)',
    'Camino Herradura (Trocha)',
  ];
  final List<String> _zoneOptions = ['Urbano', 'Rural'];

  // Listas filtradas para Mobiliario
  final List<String> _allowedDepartments = const [
    'Norte de Santander',
    'Cesar',
    'Bolívar',
  ];

  final Map<String, List<String>> _allowedMunicipalities = const {
    'Norte de Santander': [
      'Bucarasica',
      'Convención',
      'El Carmen',
      'El Tarra',
      'Cúcuta',
      'El Zulia',
      'Hacarí',
      'La Playa',
      'San Calixto',
      'Santiago',
      'Sardinata',
      'Teorama',
      'Tibú',
    ],
    'Bolívar': ['Morales'],
    'Cesar': ['Aguachica', 'La Gloria', 'Pelaya'],
  };

  @override
  void initState() {
    super.initState();
    _surveyState = Provider.of<FurnitureSurveyState>(context, listen: false);
    _loadData();
    _dateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    _departmentController.text = _surveyState.departamento;
    _municipalityController.text = _surveyState.municipio;
    _selectedZone = _surveyState.zona;
    _corregimientoController.text = _surveyState.corregimiento;
    _veredaController.text = _surveyState.vereda;

    _intervieweeNameController.text = _surveyState.nombreEntrevistado;
    _intervieweePositionController.text = _surveyState.cargoEntrevistado;
    _intervieweeContactController.text = _surveyState.contactoEntrevistado;

    _mainInstitutionNameController.text =
        _surveyState.nombreInstitucionPrincipal;
    _institutionNameController.text = _surveyState.nombreSedeEducativa;
    _principalNameController.text = _surveyState.nombreRector;
    _principalContactController.text = _surveyState.contactoRector;
    _principalEmailController.text = _surveyState.emailRector;

    _latitudeController.text = _surveyState.latitud;
    _longitudeController.text = _surveyState.longitud;
    _selectedAccessType = _surveyState.tipoAcceso;
    _accessObservationsController.text = _surveyState.observacionesAcceso;

    _riskOfClosure = _surveyState.riesgoCierre;
    _closureRiskReasonController.text = _surveyState.motivoCierre;

    if (_departmentController.text.isNotEmpty) {
      _municipalities =
          _allowedMunicipalities[_departmentController.text] ?? [];
    }
  }

  void _updateMunicipalities(String? department) {
    if (department == null) return;
    setState(() {
      _municipalities = _allowedMunicipalities[department] ?? [];
      if (_municipalityController.text.isNotEmpty &&
          !_municipalities.contains(_municipalityController.text)) {
        _municipalityController.clear();
      }
    });
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      _surveyState.updateGeneralInfo(
        fecha: DateTime.parse(_dateController.text),
        departamento: _departmentController.text,
        municipio: _municipalityController.text,
        zona: _selectedZone,
        corregimiento: _corregimientoController.text,
        vereda: _veredaController.text,
        nombreEntrevistado: _intervieweeNameController.text,
        cargoEntrevistado: _intervieweePositionController.text,
        contactoEntrevistado: _intervieweeContactController.text,
        nombreInstitucionPrincipal: _mainInstitutionNameController.text,
        nombreSedeEducativa: _institutionNameController.text,
        nombreRector: _principalNameController.text,
        contactoRector: _principalContactController.text,
        emailRector: _principalEmailController.text,
        latitud: _latitudeController.text,
        longitud: _longitudeController.text,
        tipoAcceso: _selectedAccessType,
        observacionesAcceso: _accessObservationsController.text,
        riesgoCierre: _riskOfClosure,
        motivoCierre: _closureRiskReasonController.text,
      );

      FormNavigator.pushForm(
        context,
        const FurnitureCoveragePage(),
        stepNumber: 2,
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFirstError();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor diligencie todos los campos obligatorios'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToFirstError() {
    final checks = <MapEntry<GlobalKey, bool>>[
      MapEntry(_departmentKey, _departmentController.text.isEmpty),
      MapEntry(_municipalityKey, _municipalityController.text.isEmpty),
      MapEntry(_zoneKey, _selectedZone == null || _selectedZone!.isEmpty),
      MapEntry(_intervieweeNameKey, _intervieweeNameController.text.isEmpty),
      MapEntry(
        _intervieweePositionKey,
        _intervieweePositionController.text.isEmpty,
      ),
      MapEntry(
        _intervieweeContactKey,
        _intervieweeContactController.text.isEmpty,
      ),
      MapEntry(
        _mainInstitutionKey,
        _mainInstitutionNameController.text.isEmpty,
      ),
      MapEntry(_institutionNameKey, _institutionNameController.text.isEmpty),
      if (_riskOfClosure)
        MapEntry(_closureReasonKey, _closureRiskReasonController.text.isEmpty),
      MapEntry(_principalNameKey, _principalNameController.text.isEmpty),
      MapEntry(_principalContactKey, _principalContactController.text.isEmpty),
      MapEntry(
        _accessTypeKey,
        _selectedAccessType == null || _selectedAccessType!.isEmpty,
      ),
      MapEntry(_accessObsKey, _accessObservationsController.text.isEmpty),
    ];
    for (final entry in checks) {
      if (entry.value) {
        final ctx = entry.key.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            alignment: 0.15,
          );
        }
        break;
      }
    }
  }

  Widget _requiredLabel(String text) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text),
          const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EnhancedFormContainer(
      title: 'Información General',
      subtitle: 'Ubicación, Contactos e Institución',
      currentStep: 1,
      totalSteps: 5,
      showPrevious: true,
      onPrevious: () => Navigator.of(context).pop(),
      onNext: _onNext,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Fecha
              TextFormField(
                controller: _dateController,
                enabled: false,
                decoration: InputDecoration(
                  label: _requiredLabel('Fecha Diligenciamiento'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 12),

              // Ubicación
              LocationDropdown(
                key: _departmentKey,
                label: 'Departamento',
                value:
                    _departmentController.text.isNotEmpty
                        ? _departmentController.text
                        : null,
                placeholder: 'Seleccionar departamento',
                items: _allowedDepartments,
                prefixIcon: Icons.location_on_outlined,
                onChanged: (String? newValue) {
                  setState(() {
                    _departmentController.text = newValue ?? '';
                    _updateMunicipalities(newValue);
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Seleccione un departamento' : null,
              ),
              const SizedBox(height: 12),
              LocationDropdown(
                key: _municipalityKey,
                label: 'Municipio',
                value:
                    _municipalityController.text.isNotEmpty
                        ? _municipalityController.text
                        : null,
                placeholder: 'Seleccionar municipio',
                items: _municipalities,
                prefixIcon: Icons.location_city_outlined,
                enabled: _departmentController.text.isNotEmpty,
                parentSelection:
                    _departmentController.text.isNotEmpty
                        ? _departmentController.text
                        : null,
                onChanged: (String? newValue) {
                  setState(() {
                    _municipalityController.text = newValue ?? '';
                  });
                },
                validator:
                    (value) => value == null ? 'Seleccione un municipio' : null,
              ),
              const SizedBox(height: 12),

              // Zona y Corregimiento
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: _zoneKey,
                      validator:
                          (v) =>
                              v == null || v.isEmpty ? 'Campo requerido' : null,
                      decoration: InputDecoration(
                        label: _requiredLabel('Zona'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                      ),
                      value: _selectedZone,
                      items:
                          _zoneOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedZone = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _corregimientoController,
                      decoration: const InputDecoration(
                        labelText: 'Corregimiento',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Vereda
              TextFormField(
                controller: _veredaController,
                decoration: const InputDecoration(
                  labelText: 'Vereda',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),

              const Divider(height: 32),
              const Text(
                'Datos del Entrevistado',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextFormField(
                key: _intervieweeNameKey,
                controller: _intervieweeNameController,
                validator:
                    (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                decoration: InputDecoration(
                  label: _requiredLabel('Nombre Entrevistado/a'),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: _intervieweePositionKey,
                      controller: _intervieweePositionController,
                      validator:
                          (v) =>
                              v == null || v.isEmpty ? 'Campo requerido' : null,
                      decoration: InputDecoration(
                        label: _requiredLabel('Cargo'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      key: _intervieweeContactKey,
                      controller: _intervieweeContactController,
                      validator:
                          (v) =>
                              v == null || v.isEmpty ? 'Campo requerido' : null,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        label: _requiredLabel('Contacto'),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),
              const Text(
                'Institución Educativa',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              CustomTextField(
                key: _mainInstitutionKey,
                controller: _mainInstitutionNameController,
                validator:
                    (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                label: 'Nombre I.E. Principal',
                prefixIcon: Icons.account_balance,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                key: _institutionNameKey,
                controller: _institutionNameController,
                label: 'Nombre Sede Educativa',
                prefixIcon: Icons.school,
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),

              Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      '¿Riesgo de Cierre de la Sede Educativa?',
                    ),
                    value: _riskOfClosure,
                    onChanged: (val) => setState(() => _riskOfClosure = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_riskOfClosure) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      key: _closureReasonKey,
                      controller: _closureRiskReasonController,
                      validator:
                          (v) =>
                              _riskOfClosure && (v == null || v.isEmpty)
                                  ? 'Requerido'
                                  : null,
                      decoration: InputDecoration(
                        label: _requiredLabel('¿Por qué?'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ],
              ),

              const Divider(height: 32),
              const Text(
                'Datos del Rector',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: _principalNameKey,
                controller: _principalNameController,
                validator:
                    (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                decoration: InputDecoration(
                  label: _requiredLabel('Nombre Rector'),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: _principalContactKey,
                      controller: _principalContactController,
                      validator:
                          (v) =>
                              v == null || v.isEmpty ? 'Campo requerido' : null,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        label: _requiredLabel('Contacto Rector'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: const Icon(Icons.phone),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _principalEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: const Icon(Icons.email),
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),
              const Text(
                'Ubicación y Acceso',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              LocationField(
                label: 'Ubicación Geográfica',
                initialValue:
                    _latitudeController.text.isNotEmpty &&
                            _longitudeController.text.isNotEmpty
                        ? '${_latitudeController.text}, ${_longitudeController.text}'
                        : null,
                onChanged: (value) {
                  final parts = value.split(',');
                  if (parts.length >= 2) {
                    _latitudeController.text = parts[0].trim();
                    _longitudeController.text = parts[1].trim();
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: _accessTypeKey,
                validator:
                    (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                decoration: InputDecoration(
                  label: _requiredLabel('Tipo de Acceso Principal'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.directions_car),
                ),
                value: _selectedAccessType,
                items:
                    _accessTypeOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedAccessType = newValue;
                  });
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                key: _accessObsKey,
                controller: _accessObservationsController,
                maxLines: 2,
                validator:
                    (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                decoration: InputDecoration(
                  label: _requiredLabel('Observaciones de Como llegar'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      'Indique el casco urbano más cercano a la sede, cuánto tiempo tarda y qué medios de transporte utiliza para llegar a esa sede desde el casco urbano.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
