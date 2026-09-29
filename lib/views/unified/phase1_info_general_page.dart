import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/institucion_catalog.dart';
import '../../models/unified_survey_state.dart';
import '../../utils/draft_autosave.dart';
import '../../widgets/form/custom_text_field.dart';
import '../../widgets/form/custom_dropdown_field.dart';
import '../../widgets/form/photo_capture_field.dart';
import '../../widgets/layout/enhanced_form_container.dart';
import '../../utils/form_navigator.dart';
import '../../utils/location_data.dart';
import '../../config/theme.dart';
import '../../services/instituciones_catalog_service.dart';
import '../../services/location_service.dart';
import 'phase2_dotacion_page.dart';

class Phase1InfoGeneralPage extends StatefulWidget {
  const Phase1InfoGeneralPage({super.key});

  @override
  State<Phase1InfoGeneralPage> createState() => _Phase1InfoGeneralPageState();
}

class _Phase1InfoGeneralPageState extends State<Phase1InfoGeneralPage>
    with DraftAutosave<Phase1InfoGeneralPage> {
  @override
  UnifiedSurveyState get draftState => _state;

  @override
  void syncDraftToState() => _saveToState();

  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late UnifiedSurveyState _state;
  bool _showErrors = false;
  bool _isLoadingLocation = false;
  bool _catalogLoaded = false;

  // Text controllers — Información General
  final _corregimientoCtrl = TextEditingController();
  final _veredaCtrl = TextEditingController();
  final _intervieweeNameCtrl = TextEditingController();
  final _intervieweeRoleCtrl = TextEditingController();
  final _intervieweeContactCtrl = TextEditingController();
  final _daneCodeCtrl = TextEditingController();
  final _principalNameCtrl = TextEditingController();
  final _principalPhoneCtrl = TextEditingController();
  final _principalEmailCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lonCtrl = TextEditingController();
  final _accessObsCtrl = TextEditingController();
  final _recentProjectsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _state = Provider.of<UnifiedSurveyState>(context, listen: false);
    startDraftAutosave();
    _corregimientoCtrl.text = _state.corregimiento ?? '';
    _veredaCtrl.text = _state.vereda ?? '';
    _intervieweeNameCtrl.text = _state.intervieweeName ?? '';
    _intervieweeRoleCtrl.text = _state.intervieweeRole ?? '';
    _intervieweeContactCtrl.text = _state.intervieweeContact ?? '';
    _daneCodeCtrl.text = _state.daneCode ?? '';
    _principalNameCtrl.text = _state.principalName ?? '';
    _principalPhoneCtrl.text = _state.principalPhone ?? '';
    _principalEmailCtrl.text = _state.principalEmail ?? '';
    _latCtrl.text = _state.latitude?.toString() ?? '';
    _lonCtrl.text = _state.longitude?.toString() ?? '';
    _accessObsCtrl.text = _state.accessObservations ?? '';
    _recentProjectsCtrl.text = _state.recentProjects ?? '';
    _loadInstitucionesCatalog();
  }

  Future<void> _loadInstitucionesCatalog() async {
    try {
      await InstitucionesCatalogService.load();
      _syncCatalogSelectionFromState();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo cargar el catálogo de instituciones: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _catalogLoaded = true);
    }
  }

  /// Descarta institución/sede/DANE que no existan en el catálogo filtrado.
  void _syncCatalogSelectionFromState() {
    // Borradores antiguos guardaban solo el nombre de la institución.
    if (_state.principalInstitutionDane == null &&
        _state.principalInstitution != null) {
      _state.principalInstitutionDane =
          InstitucionesCatalogService.institucionUnicaPorNombre(
        _state.municipality,
        _state.zone,
        _state.principalInstitution,
      )?.codigoDane;
    }

    final institucion = _institucionSeleccionada;
    if (institucion == null) {
      if (_state.principalInstitution != null ||
          _state.principalInstitutionDane != null) {
        _clearInstitutionCascade();
      }
      return;
    }

    final sede = InstitucionesCatalogService.sedePorNombre(
      institucion,
      _state.schoolName,
    );
    if (_state.schoolName != null && sede == null) {
      _clearInstitutionCascade(clearInstitution: false);
      return;
    }
    if (sede != null) {
      _state.daneCode = sede.consSede;
      _daneCodeCtrl.text = sede.consSede;
    }
  }

  List<InstitucionEducativa> get _institucionesFiltradas =>
      InstitucionesCatalogService.institucionesPor(
        _state.municipality,
        _state.zone,
      );

  InstitucionEducativa? get _institucionSeleccionada =>
      InstitucionesCatalogService.institucionPorCodigo(
        _state.municipality,
        _state.zone,
        _state.principalInstitutionDane,
      );

  /// Nombre visible; si el nombre se repite en el municipio/zona se agrega
  /// la sede principal y el código DANE para distinguirlas.
  String _institucionLabel(String codigoDane) {
    final lista = _institucionesFiltradas;
    final inst = lista.firstWhere((i) => i.codigoDane == codigoDane);
    final repetido = lista.where((i) => i.nombre == inst.nombre).length > 1;
    if (!repetido) return inst.nombre;
    final otras = inst.sedes
        .map((s) => s.nombre)
        .where((n) => n != inst.nombre)
        .take(1);
    final detalle = otras.isEmpty ? '' : ' · ${otras.first}';
    return '${inst.nombre} (DANE $codigoDane$detalle)';
  }

  List<SedeEducativa> get _sedesFiltradas =>
      InstitucionesCatalogService.sedesDe(_institucionSeleccionada);

  void _clearInstitutionCascade({
    bool clearZone = false,
    bool clearInstitution = true,
    bool clearSede = true,
  }) {
    if (clearZone) _state.zone = null;
    if (clearInstitution) {
      _state.principalInstitution = null;
      _state.principalInstitutionDane = null;
    }
    if (clearSede) {
      _state.schoolName = null;
      _state.daneCode = null;
      _daneCodeCtrl.clear();
    }
  }

  void _onMunicipalityChanged(String? value) {
    setState(() {
      _state.municipality = value;
      _clearInstitutionCascade(clearZone: true);
    });
  }

  void _onZoneChanged(String? value) {
    setState(() {
      _state.zone = value;
      _clearInstitutionCascade(clearInstitution: true, clearSede: true);
      if (value == 'Urbano') {
        _corregimientoCtrl.clear();
        _veredaCtrl.clear();
        _state.corregimiento = null;
        _state.vereda = null;
      }
    });
  }

  bool get _showCorregimientoVereda => _state.zone == 'Rural';

  void _onInstitutionChanged(String? codigoDane) {
    setState(() {
      _state.principalInstitutionDane = codigoDane;
      _state.principalInstitution = _institucionSeleccionada?.nombre;
      _clearInstitutionCascade(clearInstitution: false, clearSede: true);
    });
  }

  void _onSedeChanged(String? value) {
    setState(() {
      _state.schoolName = value;
      final sede = InstitucionesCatalogService.sedePorNombre(
        _institucionSeleccionada,
        value,
      );
      _state.daneCode = sede?.consSede;
      _daneCodeCtrl.text = sede?.consSede ?? '';
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _corregimientoCtrl.dispose();
    _veredaCtrl.dispose();
    _intervieweeNameCtrl.dispose();
    _intervieweeRoleCtrl.dispose();
    _intervieweeContactCtrl.dispose();
    _daneCodeCtrl.dispose();
    _principalNameCtrl.dispose();
    _principalPhoneCtrl.dispose();
    _principalEmailCtrl.dispose();
    _latCtrl.dispose();
    _lonCtrl.dispose();
    _accessObsCtrl.dispose();
    _recentProjectsCtrl.dispose();
    super.dispose();
  }

  // Guarda todos los valores de los controllers al state
  void _saveToState() {
    if (_showCorregimientoVereda) {
      _state.corregimiento =
          _corregimientoCtrl.text.isEmpty ? null : _corregimientoCtrl.text;
      _state.vereda = _veredaCtrl.text.isEmpty ? null : _veredaCtrl.text;
    } else {
      _state.corregimiento = null;
      _state.vereda = null;
    }
    _state.intervieweeName =
        _intervieweeNameCtrl.text.isEmpty ? null : _intervieweeNameCtrl.text;
    _state.intervieweeRole =
        _intervieweeRoleCtrl.text.isEmpty ? null : _intervieweeRoleCtrl.text;
    _state.intervieweeContact = _intervieweeContactCtrl.text.isEmpty
        ? null
        : _intervieweeContactCtrl.text;
    // principalInstitution, schoolName y daneCode se actualizan en los dropdowns
    _state.daneCode =
        _daneCodeCtrl.text.isEmpty ? null : _daneCodeCtrl.text;
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
    // Sin notify(): el autoguardado la llama en deactivate (durante build).
  }

  Future<void> _getLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final position = await LocationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _state.locationUnavailable = false;
        _latCtrl.text = position.latitude.toStringAsFixed(6);
        _lonCtrl.text = position.longitude.toStringAsFixed(6);
      });
    } on LocationFailure catch (e) {
      if (!mounted) return;
      if (e.definitive) {
        setState(() {
          _state.locationUnavailable = true;
          _latCtrl.clear();
          _lonCtrl.clear();
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.definitive
              ? '${e.message} La ubicación quedará como "No disponible".'
              : e.message),
          backgroundColor: Colors.orange,
        ),
      );
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

  /// Valida latitud/longitud: obligatorias salvo que la ubicación
  /// esté marcada como "No disponible".
  String? _validateCoord(String? value, double limit) {
    if (_state.locationUnavailable) return null;
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Requerido. Use el botón GPS';
    final n = double.tryParse(text);
    if (n == null || n < -limit || n > limit) {
      return 'Valor inválido (±${limit.toInt()})';
    }
    return null;
  }

  // Escribir coordenadas a mano anula el estado "No disponible".
  void _onCoordEdited(String _) {
    if (_state.locationUnavailable) {
      setState(() => _state.locationUnavailable = false);
    }
  }

  void _onNext() {
    _saveToState();
    _state.notify();

    // Validar campos de texto con Form
    final formValid = _formKey.currentState?.validate() ?? false;

    // Validar dropdowns requeridos manualmente
    final List<String> missing = [];
    if (_state.municipality == null) missing.add('Municipio');
    if (_state.zone == null) missing.add('Zona');
    if (_state.principalInstitution == null) {
      missing.add('Institución Educativa');
    }
    if (_state.schoolName == null) missing.add('Sede');
    if (_state.daneCode == null || _state.daneCode!.isEmpty) {
      missing.add('Código DANE');
    }
    if (!_state.locationUnavailable &&
        (_state.latitude == null || _state.longitude == null)) {
      missing.add('Ubicación GPS');
    }
    if (_state.educationLevels.isEmpty) missing.add('Niveles educativos');
    if (_state.photoFront == null || _state.photoFront!.isEmpty) missing.add('Foto frente de la sede');
    if (_state.photoClassroom1 == null || _state.photoClassroom1!.isEmpty) missing.add('Foto Aula 1');
    if (_state.photoClassroom2 == null || _state.photoClassroom2!.isEmpty) missing.add('Foto Aula 2');
    if (_state.photoBathroom == null || _state.photoBathroom!.isEmpty) missing.add('Foto baño');

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

    FormNavigator.pushForm(
      context,
      const Phase2DotacionPage(),
      stepNumber: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPad = (screenWidth * 0.03).clamp(8.0, 20.0);
    final vPad = screenWidth > 600 ? 24.0 : 16.0;
    return EnhancedFormContainer(
      title: 'Información General',
      subtitle: 'Datos de identificación, cobertura y registro fotográfico',
      currentStep: 1,
      totalSteps: 5,
      showPrevious: false,
      showNavigationButtons: false,
      customScrolling: true,
      child: Form(
        key: _formKey,
        autovalidateMode:
            _showErrors ? AutovalidateMode.always : AutovalidateMode.disabled,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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

              // ─── SECCIÓN 1c: SEDE EDUCATIVA (ubicación + institución) ─
              _buildSectionCard(
                title: 'Sede Educativa',
                icon: Icons.school_outlined,
                children: [
                  _buildRequiredDropdown(
                    label: 'Municipio',
                    value: _state.municipality,
                    items: LocationData.getMunicipalities('Norte de Santander'),
                    hint: 'Seleccione el municipio',
                    icon: Icons.location_city,
                    onChanged: _onMunicipalityChanged,
                  ),
                  _buildRequiredDropdown(
                    label: 'Zona',
                    value: _state.zone,
                    items: const ['Urbano', 'Rural'],
                    hint: 'Seleccione zona',
                    icon: Icons.map_outlined,
                    onChanged: _onZoneChanged,
                    enabled: _state.municipality != null,
                  ),
                  if (_showCorregimientoVereda) ...[
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
                  if (!_catalogLoaded)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else ...[
                    _buildRequiredDropdown(
                      label: 'Institución Educativa Principal',
                      value: _state.principalInstitutionDane,
                      items: _institucionesFiltradas
                          .map((i) => i.codigoDane)
                          .toList(),
                      itemLabel: _institucionLabel,
                      searchable: true,
                      hint: _state.municipality == null || _state.zone == null
                          ? 'Seleccione municipio y zona'
                          : (_institucionesFiltradas.isEmpty
                              ? 'Sin instituciones para este municipio/zona'
                              : 'Seleccione la institución'),
                      icon: Icons.school,
                      onChanged: _onInstitutionChanged,
                      enabled: _state.municipality != null &&
                          _state.zone != null &&
                          _institucionesFiltradas.isNotEmpty,
                    ),
                    _buildRequiredDropdown(
                      label: 'Nombre de la sede',
                      value: _state.schoolName,
                      items: _sedesFiltradas.map((s) => s.nombre).toList(),
                      hint: _state.principalInstitution == null
                          ? 'Seleccione primero la institución'
                          : (_sedesFiltradas.isEmpty
                              ? 'Sin sedes para esta institución'
                              : 'Seleccione la sede'),
                      icon: Icons.apartment_outlined,
                      onChanged: _onSedeChanged,
                      enabled: _state.principalInstitution != null &&
                          _sedesFiltradas.isNotEmpty,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: TextFormField(
                        controller: _daneCodeCtrl,
                        readOnly: true,
                        enableInteractiveSelection: true,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Campo requerido' : null,
                        decoration: InputDecoration(
                          label: const Text(
                            'Código DANE de la sede *',
                            style: TextStyle(color: Colors.black87),
                          ),
                          hintText: _state.schoolName == null
                              ? 'Se completa al elegir la sede'
                              : null,
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),
                    ),
                  ],
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
                    // Opcional: solo valida el formato si se escribe algo.
                    validator: (v) {
                      final text = v?.trim() ?? '';
                      if (text.isEmpty) return null;
                      return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)
                          ? null
                          : 'Correo no válido (ej: rector@colegio.edu.co)';
                    },
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
                            onChanged: _onCoordEdited,
                            validator: (v) => _validateCoord(v, 90),
                            decoration: InputDecoration(
                              labelText: 'Latitud *',
                              hintText: _state.locationUnavailable
                                  ? 'No disponible'
                                  : 'Numérico',
                              // Sin prefixIcon: campo angosto, cortaba etiqueta y error.
                              errorMaxLines: 3,
                              border: const OutlineInputBorder(),
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
                            onChanged: _onCoordEdited,
                            validator: (v) => _validateCoord(v, 180),
                            decoration: InputDecoration(
                              labelText: 'Longitud *',
                              hintText: _state.locationUnavailable
                                  ? 'No disponible'
                                  : 'Numérico',
                              // Sin prefixIcon: campo angosto, cortaba etiqueta y error.
                              errorMaxLines: 3,
                              border: const OutlineInputBorder(),
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
                  if (_state.locationUnavailable)
                    Semantics(
                      liveRegion: true,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.location_off,
                                size: 18, color: Colors.orange.shade800),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Ubicación no disponible: el dispositivo no pudo obtenerla. '
                                'Puede reintentar con el botón GPS o escribir las coordenadas.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                    helperText:
                        '(Ej: Desde el casco urbano del corregimiento preguntar por el billar del Sr. Edgar. Sigue el camino hasta llegar a la sede educativa Riecito (La Vega) aprox. 40 minutos en moto o carro)',
                    helperMaxLines: 5,
                  ),
                  CustomTextField(
                    label: 'En los últimos 2 años mencione qué proyectos se han ejecutado (proyectos de infraestructura, dotación, energía, agua, etc) y nombre la entidad u organización',
                    controller: _recentProjectsCtrl,
                    maxLines: 4,
                    hintText:
                        'Ej: Gobierno Nacional, Gobierno Departamental, Gobierno Local, Comunidad / JAC, ONG, Organización privada',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── SECCIÓN 2: COBERTURA ────────────────────────────────
              _buildSectionCard(
                title: 'Cobertura',
                icon: Icons.people_outline,
                children: [
                  _MultiSelectField(
                    label: 'Niveles educativos *',
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
                  if (_showErrors && _state.educationLevels.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Text(
                        'Seleccione al menos un nivel educativo',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
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
                    required: true,
                    showError: _showErrors && (_state.photoFront == null || _state.photoFront!.isEmpty),
                    onImageSelected: (p) =>
                        setState(() => _state.photoFront = p),
                  ),
                  PhotoCaptureField(
                    label: 'Foto Aula 1',
                    imagePath: _state.photoClassroom1,
                    required: true,
                    showError: _showErrors && (_state.photoClassroom1 == null || _state.photoClassroom1!.isEmpty),
                    onImageSelected: (p) =>
                        setState(() => _state.photoClassroom1 = p),
                  ),
                  PhotoCaptureField(
                    label: 'Foto Aula 2',
                    imagePath: _state.photoClassroom2,
                    required: true,
                    showError: _showErrors && (_state.photoClassroom2 == null || _state.photoClassroom2!.isEmpty),
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
                    label: 'Foto Comedor (Si aplica)',
                    imagePath: _state.photoDiningRoom,
                    onImageSelected: (p) =>
                        setState(() => _state.photoDiningRoom = p),
                  ),
                  PhotoCaptureField(
                    label: 'Foto baño principal de la sede educativa',
                    imagePath: _state.photoBathroom,
                    required: true,
                    showError: _showErrors && (_state.photoBathroom == null || _state.photoBathroom!.isEmpty),
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
                  key: const ValueKey('btn_next'),
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
                    style: const TextStyle(
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
    bool enabled = true,
    String Function(String item)? itemLabel,
    bool searchable = false,
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
            enabled: enabled,
            itemLabel: itemLabel,
            searchable: searchable,
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
}

// ─── WIDGETS AUXILIARES ───────────────────────────────────────────────────────


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
              tileColor: Colors.transparent,
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

