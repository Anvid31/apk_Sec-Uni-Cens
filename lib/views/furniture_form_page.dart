import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/furniture_item.dart';
import '../data/furniture_catalog.dart';
import '../services/form_submission_service.dart';
import '../widgets/layout/enhanced_form_container.dart';
import '../widgets/form/location_field.dart';
import '../widgets/form/custom_text_field.dart';
import '../widgets/form/custom_dropdown_field.dart';
import '../widgets/form/photo_capture_field.dart';

class FurnitureFormPage extends StatefulWidget {
  const FurnitureFormPage({Key? key}) : super(key: key);

  @override
  State<FurnitureFormPage> createState() => _FurnitureFormPageState();
}

class _FurnitureFormPageState extends State<FurnitureFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _institutionNameController =
      TextEditingController();
  // Nuevos controladores para Información General
  final TextEditingController _dateController = TextEditingController(text: DateTime.now().toString().split(' ')[0]);
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _corregimientoController = TextEditingController();
  final TextEditingController _veredaController = TextEditingController();
  
  final TextEditingController _intervieweeNameController = TextEditingController();
  final TextEditingController _intervieweePositionController = TextEditingController();
  final TextEditingController _intervieweeContactController = TextEditingController();
  
  final TextEditingController _mainInstitutionNameController = TextEditingController();
  // _institutionNameController se usará como "Sede Educativa"
  final TextEditingController _principalNameController = TextEditingController();
  final TextEditingController _principalContactController = TextEditingController();
  final TextEditingController _principalEmailController = TextEditingController();
  
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  
  // Variables para selectores
  String? _selectedAccessType;
  final List<String> _accessTypeOptions = ['Vehicular', 'Fluvial', 'Trocha'];

  String? _selectedJornada;
  final List<String> _jornadaOptions = ['Única', 'Tarde', 'Mañana', 'Completa'];

  bool _riskOfClosure = false;
  final TextEditingController _closureRiskReasonController = TextEditingController();

  // Controladores para Cobertura
  final TextEditingController _numAlumnosController = TextEditingController();
  final TextEditingController _numMujeresController = TextEditingController();
  final TextEditingController _numHombresController = TextEditingController();
  final TextEditingController _numDocentesController = TextEditingController();
  final TextEditingController _aniosFuncionamientoController = TextEditingController();
  final TextEditingController _educationalLevelsController = TextEditingController();
  List<String> _selectedLevels = [];
  final List<String> _availableLevels = ['Preescolar', 'Primaria', 'Secundaria'];

  // Controladores para Diagnóstico de Infraestructura
  final TextEditingController _numAulasController = TextEditingController();
  final TextEditingController _estadoAulasController = TextEditingController();
  final TextEditingController _espaciosFisicosController = TextEditingController();
  final TextEditingController _proyectosEjecucionController = TextEditingController();
  final TextEditingController _serviciosPublicosController = TextEditingController();
  
  bool _hasEnergy = false;
  final TextEditingController _fuenteEnergiaController = TextEditingController();
  
  final TextEditingController _electrodomesticosController = TextEditingController();
  bool _hasInternet = false;

  // Variables para fotos de infraestructura
  String? _aulaPhoto1;
  String? _aulaPhoto2;
  String? _aulaPhoto3;
  String? _aulaPhoto4;

  final TextEditingController _daneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _kitchenNeedsController = TextEditingController();
  final TextEditingController _kitchenUtensilsController = TextEditingController();
  final TextEditingController _emergencyNeedsController = TextEditingController();
  bool _hasKitchen = false;
  bool _needsEmergency = false;

  late List<FurnitureItem> _allItems;
  List<FurnitureItem> _filteredItems = [];
  late TabController _tabController;

  final List<String> _tabs = ['CONJUNTO', 'PRODUCTO', 'DOTACIÓN'];

  Widget _requiredLabel(String text) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _allItems = FurnitureCatalog.getItems();

    _filteredItems = List.from(_allItems);
    _tabController = TabController(length: 3, vsync: this);

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _institutionNameController.dispose();
    _mainInstitutionNameController.dispose();
    _dateController.dispose();
    _departmentController.dispose();
    _municipalityController.dispose();
    _zoneController.dispose();
    _corregimientoController.dispose();
    _veredaController.dispose();
    _intervieweeNameController.dispose();
    _intervieweePositionController.dispose();
    _intervieweeContactController.dispose();
    _principalNameController.dispose();
    _principalContactController.dispose();
    _principalEmailController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _closureRiskReasonController.dispose();

    _numAlumnosController.dispose();
    _numMujeresController.dispose();
    _numHombresController.dispose();
    _numDocentesController.dispose();
    _aniosFuncionamientoController.dispose();
    _educationalLevelsController.dispose();
    
    _numAulasController.dispose();
    _estadoAulasController.dispose();
    _espaciosFisicosController.dispose();
    _proyectosEjecucionController.dispose();
    _serviciosPublicosController.dispose();
    _fuenteEnergiaController.dispose();
    _electrodomesticosController.dispose();

    _daneController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    _kitchenNeedsController.dispose();
    _kitchenUtensilsController.dispose();
    _emergencyNeedsController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      if (query.isEmpty) {
        _filteredItems = List.from(_allItems);
      } else {
        _filteredItems =
            _allItems.where((item) {
              return item.name.toLowerCase().contains(query) ||
                  item.code.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  List<FurnitureItem> _getItemsByType(String type) {
    return _filteredItems.where((item) => item.type == type).toList();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Filtrar solo items con cantidad > 0 o con observaciones
      final filledItems =
          _allItems
              .where(
                (item) => item.quantity > 0 || item.observations.isNotEmpty,
              )
              .toList();

      if (filledItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No ha registrado ningún ítem de mobiliario.'),
          ),
        );
        return;
      }

      final surveyData = {
        'surveyType': 'mobiliario',
        'generalInfo': {
          'date': _dateController.text,
          'department': _departmentController.text,
          'municipality': _municipalityController.text,
          'zone': _zoneController.text,
          'corregimiento': _corregimientoController.text,
          'vereda': _veredaController.text,
          'interviewee': {
            'name': _intervieweeNameController.text,
            'position': _intervieweePositionController.text,
            'contact': _intervieweeContactController.text,
          },
          'institution': {
            'mainName': _mainInstitutionNameController.text,
            'branchName': _institutionNameController.text,
            'principal': {
              'name': _principalNameController.text,
              'contact': _principalContactController.text,
              'email': _principalEmailController.text,
            },
            'riskOfClosure': _riskOfClosure,
            'closureRiskReason': _riskOfClosure ? _closureRiskReasonController.text : '',
            // 'jornada': _selectedJornada, // Moved to cobertura
            'location': {
              'latitude': _latitudeController.text,
              'longitude': _longitudeController.text,
            },
            'accessType': _selectedAccessType,
          },
        },
        'cobertura': {
          'numAlumnos': _numAlumnosController.text,
          'numMujeres': _numMujeresController.text,
          'numHombres': _numHombresController.text,
          'numDocentes': _numDocentesController.text,
          'aniosFuncionamiento': _aniosFuncionamientoController.text,
          'nivelesEducativos': _selectedLevels,
          'jornada': _selectedJornada,
        },
        'infraestructura': {
          'numAulas': _numAulasController.text,
          'estadoAulas': _estadoAulasController.text,
          'espaciosFisicos': _espaciosFisicosController.text,
          'proyectosEjecucion': _proyectosEjecucionController.text,
          'serviciosPublicos': _serviciosPublicosController.text,
          'hasEnergy': _hasEnergy,
          'fuenteEnergia': _hasEnergy ? _fuenteEnergiaController.text : '',
          'electrodomesticos': _electrodomesticosController.text,
          'hasInternet': _hasInternet,
          'fotosAulas': [
            if (_aulaPhoto1 != null) _aulaPhoto1,
            if (_aulaPhoto2 != null) _aulaPhoto2,
            if (_aulaPhoto3 != null) _aulaPhoto3,
            if (_aulaPhoto4 != null) _aulaPhoto4,
          ],
        },
        'institutionName': _institutionNameController.text,
        'dane': _daneController.text,
        'items': filledItems.map((e) => e.toJson()).toList(),
        'kitchenDotation': {
          'hasKitchen': _hasKitchen,
          'furnitureNeeds': _hasKitchen ? _kitchenNeedsController.text : '',
          'utensilsNeeds': _hasKitchen ? _kitchenUtensilsController.text : '',
        },
        'emergencyDotation': {
          'needsEmergency': _needsEmergency,
          'needs': _needsEmergency ? _emergencyNeedsController.text : '',
        },
      };

      await FormSubmissionService.submitSurveyForm(context, surveyData);
    }
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
                    // Update controller text
                    this.setState(() {
                       _educationalLevelsController.text = _selectedLevels.join(', ');
                    });
                    
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
      title: 'Inventario de Mobiliario',
      subtitle: 'Registro de items por categoría',
      currentStep: 1,
      totalSteps: 1,
      showPrevious: true,
      onPrevious: () => Navigator.of(context).pop(),
      customScrolling: true,
      showProgressBar: false,
      showNavigationButtons: false,
      showDragHandle: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24), // Sin padding superior
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitForm,
        label: const Text('Guardar', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.save, color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildGeneralInfoSection(),
                    _buildCoverageSection(),
                    _buildInfrastructureSection(),
                    _buildPhotographicEvidenceSection(),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar ítem (código, nombre)...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              toolbarHeight: 60,
              elevation: 0,
              scrolledUnderElevation: 0,
              titleSpacing: 16,
              title: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  labelColor: Colors.black87,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildItemList('CONJUNTO'),
            _buildItemList('PRODUCTO'),
            _buildSpecialDotationTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList(String type) {
    final items = _getItemsByType(type);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chair_alt, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No hay elementos para "$type"\ncon el filtro actual.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // espacio para FAB
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Si es AMBIENTE o CONJUNTO, mostramos sub-items editables
                if ((item.type == 'AMBIENTE' || item.type == 'CONJUNTO') &&
                    item.subItems != null) ...[
                  const Text(
                    'Componentes:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...item.subItems!.map(
                    (subItem) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          // Control de cantidad +/-
                          Container(
                            height: 36,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                  ),
                                  onPressed:
                                      subItem.quantity > 0
                                          ? () => setState(() {
                                              subItem.quantity--;
                                              item.quantity = item.subItems!.fold(0, (sum, elem) => sum + elem.quantity);
                                            })
                                          : null,
                                ),
                                Text(
                                  '${subItem.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                  ),
                                  onPressed:
                                      () => setState(() {
                                        subItem.quantity++;
                                        item.quantity = item.subItems!.fold(0, (sum, elem) => sum + elem.quantity);
                                      }),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Nombre editable
                          Expanded(
                            child: TextFormField(
                              initialValue: subItem.name,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 8,
                                ),
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(fontSize: 13),
                              onChanged: (val) => subItem.name = val,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Si NO es AMBIENTE ni CONJUNTO, mostramos descripción plana
                  Text(
                    item.description,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],

                const Divider(),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        key: ValueKey('${item.id}_${item.quantity}'),
                        initialValue:
                            item.quantity > 0 ? item.quantity.toString() : '0',
                        keyboardType: TextInputType.number,
                        readOnly: (item.subItems != null && item.subItems!.isNotEmpty),
                        decoration: InputDecoration(
                          labelText: 'Cant. Total',
                          hintText: '0',
                          isDense: true,
                          border: const OutlineInputBorder(),
                          filled: (item.subItems != null && item.subItems!.isNotEmpty),
                          fillColor: Colors.grey.shade200,
                        ),
                        onChanged: (item.subItems != null && item.subItems!.isNotEmpty) 
                          ? null 
                          : (val) {
                              setState(() {
                                item.quantity = int.tryParse(val) ?? 0;
                              });
                            },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        initialValue: item.observations,
                        decoration: const InputDecoration(
                          labelText: 'Observaciones',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          item.observations = val;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecialDotationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                onTap: () async {
                  final Uri url = Uri.parse('https://www.mineducacion.gov.co/1759/articles-355996_archivo_pdf_manual_dotaciones.pdf');
                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No se pudo abrir el enlace')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Ver instructivo Manual de Dotaciones aquí',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
          _buildSectionHeader('Comedor / Cocina', Icons.restaurant),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      '¿Cuenta la sede con comedor-cocina?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: _hasKitchen,
                    onChanged: (val) => setState(() => _hasKitchen = val),
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  if (_hasKitchen) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    // Sección 1: Mobiliario de Cocina
                    const Text(
                      'Mobiliario de Cocina',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '(mesón con azafates, mesón de trabajo cocina, mesa de cafeteria plegable, estufa enana de un quemador, estufa lineal de tres quemadores, etc)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _kitchenNeedsController,
            validator: (v) => _hasKitchen && (v == null || v.isEmpty) ? 'Requerido' : null,
                      maxLines: 3,
                      decoration: InputDecoration(
                        label: _requiredLabel('Mobiliario Requerido'),
                        border: const OutlineInputBorder(),
                        hintText: 'Ingrese mobiliario y cantidades...',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sección 2: Menaje y Utensilios
                    const Text(
                      'Menaje, Equipo y Utensilios de Cocina',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '(Nevera, congelador, licuadora, recipiente plastico, balde plastico, caldero, ollas aluminio recortado, olla a presión, olleta, paila, sartén, jarra plastica, tabla para picar, cucharon, rallador, coladores, asador antiaderente, batidor de chocolate, exprimidor manual, olla arrocera, balanza gramera, cafetera, cucharas, tenedor, cuchillo, plato hondo, plato pando, posillo, vaso, etc)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _kitchenUtensilsController,
            validator: (v) => _hasKitchen && (v == null || v.isEmpty) ? 'Requerido' : null,
                      maxLines: 3,
                      decoration: InputDecoration(
                        label: _requiredLabel('Menaje y Utensilios'),
                        border: const OutlineInputBorder(),
                        hintText: 'Ingrese menaje y cantidades...',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          _buildSectionHeader(
            'Atención de Emergencias',
            Icons.medical_services,
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      '¿Requiere dotación para emergencias?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: _needsEmergency,
                    onChanged: (val) => setState(() => _needsEmergency = val),
                    activeColor: Colors.redAccent,
                  ),
                  if (_needsEmergency) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Indique elementos requeridos (Camilla, Escalinata, Botiquín, Canecas riesgo biológico, Contenedores, etc.)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emergencyNeedsController,
            validator: (v) => _needsEmergency && (v == null || v.isEmpty) ? 'Requerido' : null,
                      maxLines: 5,
                      decoration: InputDecoration(
                        label: _requiredLabel('Elementos de Emergencia'),
                        border: const OutlineInputBorder(),
                        hintText: 'Ej: 1 Camilla fija, 2 Botiquines tipo A...',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverageSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
         title: const Text(
          'Cobertura',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Información de estudiantes y docentes'),
        leading: const Icon(Icons.people_alt_outlined),
        childrenPadding: const EdgeInsets.all(16),
        children: [
            TextFormField(
              controller: _numAlumnosController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                label: _requiredLabel('N° alumnos (SIMAT)'),
                border: OutlineInputBorder(),
                isDense: true,
                prefixIcon: Icon(Icons.groups),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _numMujeresController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: _requiredLabel('N° mujeres'),
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.female),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _numHombresController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: _requiredLabel('N° hombres'),
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.male),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _numDocentesController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: _requiredLabel('N° docentes'),
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.person_pin_outlined),
                    ),
                  ),
                ),
                 const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _aniosFuncionamientoController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: _requiredLabel('Años func.'),
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.history),
                    ),
                  ),
                ),
              ],
            ),
             const SizedBox(height: 12),
             TextFormField(
                controller: _educationalLevelsController,
                decoration: InputDecoration(
                  label: _requiredLabel('Niveles educativos ofertados'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.school_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: _showLevelsDialog,
                  ),
                ),
                readOnly: true,
                onTap: _showLevelsDialog,
             ),
             const SizedBox(height: 12),
             DropdownButtonFormField<String>(
              validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              decoration: InputDecoration(
                label: _requiredLabel('Jornada Escolar'),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.schedule),
              ),
              value: _selectedJornada,
              items: _jornadaOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedJornada = newValue;
                });
              },
            ),
        ],
      )
    );
  }

  Widget _buildInfrastructureSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text(
          'Diagnóstico de Infraestructura',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Estado físico y servicios'),
        leading: const Icon(Icons.foundation),
        childrenPadding: const EdgeInsets.all(16),
        children: [
            const Text(
              'Evalúe el estado físico para garantizar sostenibilidad',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _numAulasController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              label: 'Número de aulas en la sede',
              prefixIcon: Icons.meeting_room,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _estadoAulasController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              label: 'Descripción del estado de las aulas',
              prefixIcon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _espaciosFisicosController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              label: 'Espacios existentes y su estado físico',
              hintText: 'Ej: Comedor escolar (Bueno), Cancha (Regular)...',
              prefixIcon: Icons.place,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _proyectosEjecucionController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              label: 'Proyectos en ejecución y entidad a cargo',
              hintText: 'Remodelaciones, dotaciones...',
              prefixIcon: Icons.engineering,
              maxLines: 2,
            ),
             const SizedBox(height: 12),
            CustomTextField(
              controller: _serviciosPublicosController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              label: 'Servicios públicos con los que cuenta la sede',
              prefixIcon: Icons.water_drop,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('¿La sede cuenta con energía eléctrica?'),
              value: _hasEnergy,
              onChanged: (val) => setState(() => _hasEnergy = val),
              secondary: const Icon(Icons.lightbulb),
            ),
            if (_hasEnergy) ...[
               const SizedBox(height: 8),
               CustomTextField(
                controller: _fuenteEnergiaController,
            validator: (v) => _hasEnergy && (v == null || v.isEmpty) ? 'Requerido' : null,
                label: '¿Mencione de qué manera obtiene la energía?',
                hintText: 'CENS, red artesanal, con/sin medidor...',
                prefixIcon: Icons.electrical_services,
               ),
            ],
            const SizedBox(height: 12),
            CustomTextField(
              controller: _electrodomesticosController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              label: 'Electrodomésticos y equipos actuales',
              prefixIcon: Icons.kitchen,
              maxLines: 2,
            ),
             const SizedBox(height: 12),
             SwitchListTile(
              title: const Text('¿Cuenta con conectividad/internet?'),
              value: _hasInternet,
              onChanged: (val) => setState(() => _hasInternet = val),
              secondary: const Icon(Icons.wifi),
            ),
        ],
      )
    );
  }

  Widget _buildPhotographicEvidenceSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text(
          'Evidencia Fotográfica de Aulas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Registro fotográfico'),
        leading: const Icon(Icons.camera_alt),
        childrenPadding: const EdgeInsets.all(16),
        children: [
            PhotoCaptureField(
                  required: true,
              label: 'Foto Aula 1',
              imagePath: _aulaPhoto1,
              onImageSelected: (path) => setState(() => _aulaPhoto1 = path),
            ),
            const SizedBox(height: 12),
            PhotoCaptureField(
                  required: true,
              label: 'Foto Aula 2',
              imagePath: _aulaPhoto2,
              onImageSelected: (path) => setState(() => _aulaPhoto2 = path),
            ),
            const SizedBox(height: 12),
            PhotoCaptureField(
                  required: true,
              label: 'Foto Aula 3',
              imagePath: _aulaPhoto3,
              onImageSelected: (path) => setState(() => _aulaPhoto3 = path),
            ),
            const SizedBox(height: 12),
            PhotoCaptureField(
                  required: true,
              label: 'Foto Aula 4',
              imagePath: _aulaPhoto4,
              onImageSelected: (path) => setState(() => _aulaPhoto4 = path),
            ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text(
          'Información General',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Ubicación, Contactos e Institución'),
        leading: const Icon(Icons.info_outline),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          // FECHA Y LUGAR
          TextFormField(
            controller: _dateController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
            decoration: InputDecoration(
              label: _requiredLabel('Fecha Diligenciamiento'),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _departmentController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                  decoration: InputDecoration(
                    label: _requiredLabel('Departamento'),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _municipalityController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                  decoration: InputDecoration(
                    label: _requiredLabel('Municipio'),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _zoneController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                  decoration: InputDecoration(
                    label: _requiredLabel('Zona'),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _corregimientoController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                  decoration: InputDecoration(
                    label: _requiredLabel('Corregimiento'),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _veredaController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
            decoration: InputDecoration(
              label: _requiredLabel('Vereda'),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          
          const Divider(height: 32),
          const Text('Datos del Entrevistado', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          TextFormField(
            controller: _intervieweeNameController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
            decoration: InputDecoration(
              label: _requiredLabel('Nombre Entrevistado/a'),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _intervieweePositionController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                  decoration: InputDecoration(
                    label: _requiredLabel('Cargo'),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _intervieweeContactController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    label: _requiredLabel('Contacto'),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 32),
          const Text('Institución Educativa', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          CustomTextField(
            controller: _mainInstitutionNameController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
            label: 'Nombre I.E. Principal',
            prefixIcon: Icons.account_balance,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _institutionNameController,
            label: 'Nombre Sede Educativa',
            prefixIcon: Icons.school,
            validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 12),
            CustomTextField(
              controller: _daneController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              label: 'Código DANE',
              prefixIcon: Icons.numbers,
              keyboardType: TextInputType.number,
            ),
          const SizedBox(height: 12),
          // Moved Jornada to Cobertura section
          Column(
            children: [
              SwitchListTile(
                title: const Text('¿Riesgo de Cierre?'),
                value: _riskOfClosure,
                onChanged: (val) => setState(() => _riskOfClosure = val),
                contentPadding: EdgeInsets.zero,
              ),
              if (_riskOfClosure) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _closureRiskReasonController,
            validator: (v) => _riskOfClosure && (v == null || v.isEmpty) ? 'Requerido' : null,
                  decoration: InputDecoration(
                    label: _requiredLabel('¿Por qué?'),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ],
          ),

          const Divider(height: 32),
          const Text('Datos del Rector', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _principalNameController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
            decoration: InputDecoration(
              label: _requiredLabel('Nombre Rector'),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _principalContactController,
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    label: _requiredLabel('Contacto Rector'),
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.phone),
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
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 32),
          const Text('Ubicación y Acceso', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LocationField(
            label: 'Ubicación Geográfica',
            initialValue: _latitudeController.text.isNotEmpty && _longitudeController.text.isNotEmpty 
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
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
            decoration: InputDecoration(
              label: _requiredLabel('Tipo de Acceso Principal'),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.directions_car),
            ),
            value: _selectedAccessType,
            items: _accessTypeOptions.map((String value) {
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
        ],
      ),
    );
  }
}
