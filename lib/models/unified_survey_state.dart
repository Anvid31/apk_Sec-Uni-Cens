import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

/// Ítem de mobiliario: total que tienen y cantidad en cada estado.
class MobiliarioItem {
  int? cantTotal;
  int? cantBueno;
  int? cantRegular;
  int? cantMalo;

  MobiliarioItem({this.cantTotal, this.cantBueno, this.cantRegular, this.cantMalo});

  Map<String, dynamic> toJson() => {
        'cantTotal': cantTotal,
        'cantBueno': cantBueno,
        'cantRegular': cantRegular,
        'cantMalo': cantMalo,
      };

  void reset() {
    cantTotal = null;
    cantBueno = null;
    cantRegular = null;
    cantMalo = null;
  }
}

/// Ítem de electrodoméstico con estado (si/numero/no) y cantidad opcional.
class ElectrodomesticoItem {
  String? tiene; // 'si', 'numero', 'no'
  int? cantidad;

  ElectrodomesticoItem({this.tiene, this.cantidad});

  Map<String, dynamic> toJson() => {'tiene': tiene, 'cantidad': cantidad};

  void reset() {
    tiene = null;
    cantidad = null;
  }
}

/// Espacio adicional (lista dinámica: descripción + cantidad + estado).
class OtroEspacioItem {
  String descripcion;
  int? cantidad;
  String? estado; // 'Bueno' | 'Regular' | 'Malo'

  OtroEspacioItem({this.descripcion = '', this.cantidad, this.estado});

  Map<String, dynamic> toJson() => {
        'descripcion': descripcion,
        'cantidad': cantidad,
        'estado': estado,
      };

  factory OtroEspacioItem.fromJson(Map<String, dynamic> json) {
    return OtroEspacioItem(
      descripcion: (json['descripcion'] as String?) ?? '',
      cantidad: json['cantidad'] is int
          ? json['cantidad'] as int
          : int.tryParse('${json['cantidad'] ?? ''}'),
      estado: json['estado'] as String?,
    );
  }
}

/// Electrodoméstico adicional (lista dinámica: nombre + cantidad).
class OtroElectrodomesticoItem {
  String nombre;
  int? cantidad;

  OtroElectrodomesticoItem({this.nombre = '', this.cantidad});

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'cantidad': cantidad,
      };

  factory OtroElectrodomesticoItem.fromJson(Map<String, dynamic> json) {
    return OtroElectrodomesticoItem(
      nombre: (json['nombre'] as String?) ?? '',
      cantidad: json['cantidad'] is int
          ? json['cantidad'] as int
          : int.tryParse('${json['cantidad'] ?? ''}'),
    );
  }
}

/// Modelo unificado para el formulario único de caracterización de sedes.
/// Contiene los 4 fases: Información General, Dotación, Energía, Agua.
class UnifiedSurveyState extends ChangeNotifier {
  // ============================================================
  // FASE 1: INFORMACIÓN GENERAL
  // ============================================================

  // --- Datos básicos ---
  DateTime date = DateTime.now();
  final String department = 'Norte de Santander';
  String? municipality; // REQUERIDO
  String? zone; // Urbano / Rural  REQUERIDO
  String? corregimiento;
  String? vereda;
  String? intervieweeName;
  String? intervieweeRole;
  String? intervieweeContact;

  // --- Institución y sede ---
  String? principalInstitution; // REQUERIDO
  /// Código DANE de la institución: el nombre se repite en el catálogo.
  String? principalInstitutionDane;
  String? schoolName; // REQUERIDO
  String? daneCode; // REQUERIDO

  // --- Rector ---
  String? principalName;
  String? principalPhone;
  String? principalEmail;

  // --- Geolocalización y acceso ---
  double? latitude;
  double? longitude;
  /// true cuando el dispositivo no pudo obtener la ubicación GPS.
  bool locationUnavailable = false;
  List<String> accessTypes = []; // multi-select
  String? accessObservations;
  String? recentProjects;

  // ============================================================
  // COBERTURA (parte de Fase 1)
  // ============================================================
  int? totalStudents; // REQUERIDO
  int? girlsCount; // REQUERIDO
  int? boysCount; // REQUERIDO
  int? refugeeStudents; // REQUERIDO
  int? conflictVictims; // REQUERIDO
  int? ethnicStudents; // REQUERIDO
  int? disabledStudents; // REQUERIDO
  int? teachersCount;
  int? adminStaff; // REQUERIDO
  List<String> educationLevels = []; // multi-select
  String? academicSchedule; // única opción

  // ============================================================
  // REGISTRO FOTOGRÁFICO (parte de Fase 1)
  // ============================================================
  String? photoFront;
  String? photoClassroom1;
  String? photoClassroom2;
  String? photoKitchen;
  String? photoDiningRoom;
  String? photoBathroom;

  // ============================================================
  // FASE 2: DOTACIÓN
  // ============================================================

  // ── Ítems de Mobiliario general (117-174) ─────────────────────────────────
  static const List<Map<String, String>> mobiliarioItemsList = [
    {'code': '118', 'name': 'Puesto de Trabajo Aula Primaria'},
    {'code': '119', 'name': 'Puesto de Trabajo Aula Secundaria'},
    {'code': '121', 'name': 'Puesto de Trabajo Biblioteca'},
    {'code': '126', 'name': 'Puesto de Trabajo Docente'},
    {'code': '131', 'name': 'Puesto de Trabajo Preescolar'},
    // Sin código de catálogo: clave propia.
    {'code': 'PI', 'name': 'Puesto de Trabajo Primera Infancia'},
    {'code': '151', 'name': 'Módulo de biblioteca 1,30 mts.'},
    {'code': '153', 'name': 'Mueble de almacenamiento aulas'},
    {'code': '165', 'name': 'Tablero'},
    {'code': '166', 'name': 'Tablero Alta resistencia humedad'},
    {'code': '167', 'name': 'Tablero móvil'},
    {'code': '172', 'name': 'Papelera'},
    {'code': '174', 'name': 'Tándem 3 canecas aulas'},
  ];

  // ── Dotación Especial — Cocina/Comedor (206-473) ───────────────────────────
  static const List<Map<String, String>> dotacionCocinaItemsList = [
    {'code': '206', 'name': 'Mesón con azafates'},
    {'code': '208', 'name': 'Mesón de trabajo cocina'},
    {'code': '209', 'name': 'Mesa cafetería plegable'},
    {'code': '210', 'name': 'Estufa enana de un (1) quemador'},
    {'code': '211', 'name': 'Estufa lineal de tres (3) quemadores'},
    {'code': '400', 'name': 'Nevera no frost 300-340 litros o 12-14 pies'},
    {'code': '402', 'name': 'Congelador horizontal 300-400 litros'},
    {'code': '406', 'name': 'Licuadora industrial 15 litros'},
    {'code': '408', 'name': 'Recipiente plástico de 70-75 litros'},
    {'code': '410', 'name': 'Balde plástico 10-14 litros'},
    {'code': '414', 'name': 'Calderos 97-100 litros'},
    {'code': '422', 'name': 'Ollas (aluminio recortado) 22,5-23,5 litros'},
    {'code': '426', 'name': 'Olla a presión 8 litros'},
    {'code': '431', 'name': 'Olleta de 3 litros'},
    {'code': '433', 'name': 'Paila diámetro 35-40 centímetros'},
    {'code': '437', 'name': 'Sartén diámetro 30-35 centímetros'},
    {'code': '441', 'name': 'Jarra plástica 3 litros'},
    {'code': '443', 'name': 'Tabla para picar grande'},
    {'code': '448', 'name': 'Cucharon en acero inoxidable'},
    {'code': '450', 'name': 'Rallador'},
    {'code': '451', 'name': 'Colador de verduras'},
    {'code': '455', 'name': 'Asador antiadherente'},
    {'code': '456', 'name': 'Batidor de chocolate'},
    {'code': '460', 'name': 'Exprimidor manual'},
    {'code': '463', 'name': 'Olla arrocera'},
    {'code': '464', 'name': 'Balanza gramera'},
    {'code': '465', 'name': 'Cafetera greca institucional'},
    {'code': '466', 'name': 'Cuchara (cubierto de mesa)'},
    {'code': '467', 'name': 'Tenedor (cubierto de mesa)'},
    {'code': '468', 'name': 'Cuchillo (cubierto de mesa)'},
    {'code': '469', 'name': 'Plato hondo (plato de mesa)'},
    {'code': '470', 'name': 'Plato pando grande (plato de mesa)'},
    {'code': '472', 'name': 'Posillo'},
    {'code': '473', 'name': 'Vaso'},
  ];

  // ── Dotación Especial — Emergencias (724-731) ──────────────────────────────
  static const List<Map<String, String>> dotacionEmergenciaItemsList = [
    {'code': '724', 'name': 'Camilla'},
    {'code': '725', 'name': 'Escalinata 2 peldaños'},
    {'code': '727', 'name': 'Botiquín Gavinete fijo'},
    {'code': '728', 'name': 'Caneca Riesgo Biológico'},
    {'code': '729', 'name': 'Contenedor Punzantes'},
    {'code': '731', 'name': 'Báscula con Tallímetro'},
  ];

  // --- Servicios Públicos ---
  bool? tieneGas;
  List<String> fuenteGas = [];
  bool? tieneInternet;
  String? empresaInternet;
  String? observacionesInternet;

  // --- Infraestructura — Espacios ---
  bool? tieneSalones;
  String? cantidadSalones;
  String? estadoSalones;
  bool? tieneComedor;
  String? cantidadComedor;
  String? estadoComedor;
  bool? tieneCocinaEspacio;
  String? cantidadCocina;
  String? estadoCocina;
  bool? tieneSalonReuniones;
  String? cantidadSalonReuniones;
  String? estadoSalonReuniones;
  bool? tieneHabitaciones;
  String? cantidadHabitaciones;
  String? estadoHabitaciones;
  bool? tieneBanos;
  String? cantidadBanos;
  String? estadoBanos;
  bool? tieneOtrosEspacios;
  List<OtroEspacioItem> otrosEspaciosList = [];

  // --- Ítems de Mobiliario general ---
  Map<String, MobiliarioItem> mobiliarioItems = {
    for (final item in mobiliarioItemsList) item['code']!: MobiliarioItem()
  };

  // --- Dotación Especial ---
  bool? dotTieneCocina;
  String? dotEstadoCocina; // Bueno / Regular / Malo
  bool? dotTieneComedor;
  String? dotEstadoComedor; // Bueno / Regular / Malo
  bool? dotTieneEmergencia;

  Map<String, MobiliarioItem> dotCocinaItems = {
    for (final item in dotacionCocinaItemsList) item['code']!: MobiliarioItem()
  };
  Map<String, MobiliarioItem> dotEmergenciaItems = {
    for (final item in dotacionEmergenciaItemsList) item['code']!: MobiliarioItem()
  };

  // ============================================================
  // FASE 3: ENERGÍA
  // ============================================================

  static const List<Map<String, String>> electrodomesticosList = [
    {'key': 'nevera', 'name': 'Nevera'},
    {'key': 'televisor', 'name': 'Televisor'},
    {'key': 'computador', 'name': 'Computador'},
    {'key': 'ventilador', 'name': 'Ventilador'},
    {'key': 'videoBeam', 'name': 'Video Beam'},
    {'key': 'impresora', 'name': 'Impresora'},
    {'key': 'equipoSonido', 'name': 'Equipo de Sonido'},
    {'key': 'bombillos', 'name': 'Bombillos'},
    {'key': 'tablet', 'name': 'Tablet'},
    {'key': 'celular', 'name': 'Celular'},
    {'key': 'licuadora', 'name': 'Licuadora'},
    {'key': 'lavadora', 'name': 'Lavadora'},
  ];

  // --- Servicios Públicos ---
  bool? tieneEnergiaElectrica;
  String? fuenteEnergia;
  String? numeroCLientesCENS;
  /// Solo aplica si la fuente es Red CENS: Bueno / Regular / Malo.
  String? calidadServicioCENS;
  /// Motivo de la calificación del servicio CENS.
  String? motivoCalidadServicioCENS;
  /// Solo aplica si no tiene energía eléctrica.
  bool? interesSolucionesSolares;

  // --- Electrodomésticos ---
  Map<String, ElectrodomesticoItem> electrodomesticos = {
    for (final item in electrodomesticosList) item['key']!: ElectrodomesticoItem()
  };
  List<OtroElectrodomesticoItem> otrosElectrodomesticos = [];
  bool? cuentaSalonHerramientasTIC;
  bool? instalacionesElectricasAdecuadas;
  String? photoInstalacionesElectricas;

  // ============================================================
  // FASE 4: AGUA
  // ============================================================

  // --- Agua ---
  bool? tieneAccesoAgua;
  List<String> fuenteAbastecimiento = []; // max 2
  String? frecuenciaAgua;
  String? calidadAgua;
  bool? tieneTanqueAlmacenamiento;
  List<String> materialTanques = [];
  String? capacidadTanques;
  String? estadoRedAcueducto;
  String? tieneAguaPotable; // 'si' | 'no' | 'no_sabe'
  List<String> tratamientoAgua = [];
  bool? tienePuntosHidratacion;
  String? cantidadPuntosHidratacion;

  // --- Saneamiento ---
  String? dispositivoSaneamiento; // 'si' | 'no_campo_abierto' | 'no_gratuito' | 'no_pago'
  List<String> tipoSistSaneamiento = [];
  String? estadoRedDesague;
  String? totalSanitariosOrinales;
  bool? sanitariosSeparados;
  String? cantSanitariosNinas;
  String? cantSanitariosNinos;
  String? totalSanitariosFuncionan;
  bool? instalacionesDiscapacidad;
  String? cantInstalacionesDiscapacidad;
  bool? instalacionesPrimeraInfancia;
  String? cantInstalacionesPrimeraInfancia;
  List<String> condicionesSanitarios = [];
  List<String> gestionDesechos = [];

  // --- Higiene ---
  List<String> sistemaLavadoManos = [];
  String? totalLlavesLavamanos;
  String? frecuenciaInsumos;
  bool? infoVisualHigiene;
  bool? tieneComiteASH;
  String? capacitacionComite;
  List<String> actividadesPromocionASH = [];
  List<String> quienPromocionASH = [];
  String? frecuenciaActividadesASH;
  List<String> riesgosExperimentados = [];
  String? otroRiesgo;
  String? observacionesASH;

  // ============================================================
  // FASE 5: RIESGO
  // ============================================================

  // --- Continuidad del servicio educativo ---
  String? r1SuspendioClases; // 'si' | 'no' | 'no_sabe'
  String? r11DiassinServicio;
  List<String> r12CausaSuspension = [];
  String? r12OtraCausa;

  // --- Amenazas reconocidas por la sede ---
  List<String> r2Amenazas = [];
  List<String> r21AmenazasPrioritarias = []; // máx 3

  // --- Trayectos y transporte escolar ---
  List<String> r3FormasLlegada = [];
  String? r31DuracionTrayecto;
  List<String> r32RiesgosTrayecto = [];
  String? r32OtraCondicion;
  String? r33TrayectoSuspendido; // 'si' | 'no' | 'no_sabe' | 'prefiere_no_responder'

  // --- Efectividad de la ruta de aviso ---
  String? r4QuienAvisa;
  String? r4QuienAvisaOtro;
  List<String> r41MedioAviso = [];
  String? r41MedioAvisoOtro;
  String? r42ObtuvoRespuesta;

  // --- Actualización de la información ---
  String? r5CargoResponsable;
  String? r51FrecuenciaActualizacion;

  // --- Observaciones generales (cierre del formulario) ---
  String? observacionesGenerales;

  // ============================================================
  // ESTADO DE ENVÍO
  // ============================================================
  bool isSubmitted = false;
  DateTime? submissionDate;
  String submissionStatus = 'pending';
  String? submissionId;

  /// Sube en cada [reset]. Las páginas abiertas antes del reset dejan de
  /// autoguardar (sus controllers tienen datos de la encuesta ya enviada).
  int draftEpoch = 0;

  // ============================================================
  // MÉTODOS
  // ============================================================

  void notify() {
    notifyListeners();
    StorageService.saveDraft(toJson());
  }

  void reset() {
    draftEpoch++;
    date = DateTime.now();
    municipality = null;
    zone = null;
    corregimiento = null;
    vereda = null;
    intervieweeName = null;
    intervieweeRole = null;
    intervieweeContact = null;
    principalInstitution = null;
    principalInstitutionDane = null;
    schoolName = null;
    daneCode = null;
    principalName = null;
    principalPhone = null;
    principalEmail = null;
    latitude = null;
    longitude = null;
    locationUnavailable = false;
    accessTypes = [];
    accessObservations = null;
    recentProjects = null;
    totalStudents = null;
    girlsCount = null;
    boysCount = null;
    refugeeStudents = null;
    conflictVictims = null;
    ethnicStudents = null;
    disabledStudents = null;
    teachersCount = null;
    adminStaff = null;
    educationLevels = [];
    academicSchedule = null;
    photoFront = null;
    photoClassroom1 = null;
    photoClassroom2 = null;
    photoKitchen = null;
    photoDiningRoom = null;
    photoBathroom = null;
    // Fase 2 — Servicios Públicos
    tieneGas = null;
    fuenteGas = [];
    tieneInternet = null;
    empresaInternet = null;
    observacionesInternet = null;
    // Fase 2 — Infraestructura
    tieneSalones = null; cantidadSalones = null; estadoSalones = null;
    tieneComedor = null; cantidadComedor = null; estadoComedor = null;
    tieneCocinaEspacio = null; cantidadCocina = null; estadoCocina = null;
    tieneSalonReuniones = null; cantidadSalonReuniones = null; estadoSalonReuniones = null;
    tieneHabitaciones = null; cantidadHabitaciones = null; estadoHabitaciones = null;
    tieneBanos = null; cantidadBanos = null; estadoBanos = null;
    tieneOtrosEspacios = null;
    otrosEspaciosList = [];
    // Fase 2 — Mobiliario
    for (final item in mobiliarioItems.values) {
      item.reset();
    }
    // Fase 2 — Dotación Especial
    dotTieneCocina = null;
    dotEstadoCocina = null;
    dotTieneComedor = null;
    dotEstadoComedor = null;
    dotTieneEmergencia = null;
    for (final item in dotCocinaItems.values) {
      item.reset();
    }
    for (final item in dotEmergenciaItems.values) {
      item.reset();
    }
    // Fase 3 — Energía
    tieneEnergiaElectrica = null;
    fuenteEnergia = null;
    numeroCLientesCENS = null;
    calidadServicioCENS = null;
    motivoCalidadServicioCENS = null;
    interesSolucionesSolares = null;
    for (final item in electrodomesticos.values) {
      item.reset();
    }
    otrosElectrodomesticos = [];
    cuentaSalonHerramientasTIC = null;
    instalacionesElectricasAdecuadas = null;
    photoInstalacionesElectricas = null;
    // Fase 4 — Agua
    tieneAccesoAgua = null;
    fuenteAbastecimiento = [];
    frecuenciaAgua = null;
    calidadAgua = null;
    tieneTanqueAlmacenamiento = null;
    materialTanques = [];
    capacidadTanques = null;
    estadoRedAcueducto = null;
    tieneAguaPotable = null;
    tratamientoAgua = [];
    tienePuntosHidratacion = null;
    cantidadPuntosHidratacion = null;
    // Fase 4 — Saneamiento
    dispositivoSaneamiento = null;
    tipoSistSaneamiento = [];
    estadoRedDesague = null;
    totalSanitariosOrinales = null;
    sanitariosSeparados = null;
    cantSanitariosNinas = null;
    cantSanitariosNinos = null;
    totalSanitariosFuncionan = null;
    instalacionesDiscapacidad = null;
    cantInstalacionesDiscapacidad = null;
    instalacionesPrimeraInfancia = null;
    cantInstalacionesPrimeraInfancia = null;
    condicionesSanitarios = [];
    gestionDesechos = [];
    // Fase 4 — Higiene
    sistemaLavadoManos = [];
    totalLlavesLavamanos = null;
    frecuenciaInsumos = null;
    infoVisualHigiene = null;
    tieneComiteASH = null;
    capacitacionComite = null;
    actividadesPromocionASH = [];
    quienPromocionASH = [];
    frecuenciaActividadesASH = null;
    riesgosExperimentados = [];
    otroRiesgo = null;
    observacionesASH = null;
    // Fase 5 — Riesgo
    r1SuspendioClases = null;
    r11DiassinServicio = null;
    r12CausaSuspension = [];
    r12OtraCausa = null;
    r2Amenazas = [];
    r21AmenazasPrioritarias = [];
    r3FormasLlegada = [];
    r31DuracionTrayecto = null;
    r32RiesgosTrayecto = [];
    r32OtraCondicion = null;
    r33TrayectoSuspendido = null;
    r4QuienAvisa = null;
    r4QuienAvisaOtro = null;
    r41MedioAviso = [];
    r41MedioAvisoOtro = null;
    r42ObtuvoRespuesta = null;
    r5CargoResponsable = null;
    r51FrecuenciaActualizacion = null;
    observacionesGenerales = null;
    isSubmitted = false;
    submissionDate = null;
    submissionStatus = 'pending';
    submissionId = null;
    notifyListeners();
    // Encuesta nueva: el borrador en disco no debe conservar la anterior.
    StorageService.clearDraft();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Carga borrador guardado localmente
  // ──────────────────────────────────────────────────────────────────────────

  void loadFromJson(Map<String, dynamic> j) {
    if (j['date'] != null) {
      try { date = DateTime.parse(j['date'] as String); } catch (_) {}
    }
    municipality             = j['municipality'] as String?;
    zone                     = j['zone'] as String?;
    corregimiento            = j['corregimiento'] as String?;
    vereda                   = j['vereda'] as String?;
    intervieweeName          = j['intervieweeName'] as String?;
    intervieweeRole          = j['intervieweeRole'] as String?;
    intervieweeContact       = j['intervieweeContact'] as String?;
    principalInstitution     = j['principalInstitution'] as String?;
    principalInstitutionDane = j['principalInstitutionDane'] as String?;
    schoolName               = j['schoolName'] as String?;
    daneCode                 = j['daneCode'] as String?;
    principalName            = j['principalName'] as String?;
    principalPhone           = j['principalPhone'] as String?;
    principalEmail           = j['principalEmail'] as String?;
    latitude                 = (j['latitude'] as num?)?.toDouble();
    longitude                = (j['longitude'] as num?)?.toDouble();
    locationUnavailable      = j['locationUnavailable'] as bool? ?? false;
    accessTypes              = _jList(j['accessTypes']);
    accessObservations       = j['accessObservations'] as String?;
    recentProjects           = j['recentProjects'] as String?;
    totalStudents            = _jInt(j['totalStudents']);
    girlsCount               = _jInt(j['girlsCount']);
    boysCount                = _jInt(j['boysCount']);
    refugeeStudents          = _jInt(j['refugeeStudents']);
    conflictVictims          = _jInt(j['conflictVictims']);
    ethnicStudents           = _jInt(j['ethnicStudents']);
    disabledStudents         = _jInt(j['disabledStudents']);
    teachersCount            = _jInt(j['teachersCount']);
    adminStaff               = _jInt(j['adminStaff']);
    educationLevels          = _jList(j['educationLevels']);
    academicSchedule         = j['academicSchedule'] as String?;
    photoFront               = j['photoFront'] as String?;
    photoClassroom1          = j['photoClassroom1'] as String?;
    photoClassroom2          = j['photoClassroom2'] as String?;
    photoKitchen             = j['photoKitchen'] as String?;
    photoDiningRoom          = j['photoDiningRoom'] as String?;
    photoBathroom            = j['photoBathroom'] as String?;
    tieneGas                 = j['tieneGas'] as bool?;
    fuenteGas                = _jList(j['fuenteGas']);
    tieneInternet            = j['tieneInternet'] as bool?;
    empresaInternet          = j['empresaInternet'] as String?;
    observacionesInternet    = j['observacionesInternet'] as String?;
    tieneSalones             = j['tieneSalones'] as bool?;
    cantidadSalones          = j['cantidadSalones'] as String?;
    estadoSalones            = j['estadoSalones'] as String?;
    tieneComedor             = j['tieneComedor'] as bool?;
    cantidadComedor          = j['cantidadComedor'] as String?;
    estadoComedor            = j['estadoComedor'] as String?;
    tieneCocinaEspacio       = j['tieneCocinaEspacio'] as bool?;
    cantidadCocina           = j['cantidadCocina'] as String?;
    estadoCocina             = j['estadoCocina'] as String?;
    tieneSalonReuniones      = j['tieneSalonReuniones'] as bool?;
    cantidadSalonReuniones   = j['cantidadSalonReuniones'] as String?;
    estadoSalonReuniones     = j['estadoSalonReuniones'] as String?;
    tieneHabitaciones        = j['tieneHabitaciones'] as bool?;
    cantidadHabitaciones     = j['cantidadHabitaciones'] as String?;
    estadoHabitaciones       = j['estadoHabitaciones'] as String?;
    tieneBanos               = j['tieneBanos'] as bool?;
    cantidadBanos            = j['cantidadBanos'] as String?;
    estadoBanos              = j['estadoBanos'] as String?;
    tieneOtrosEspacios = j['tieneOtrosEspacios'] as bool?;
    final otrosEspaciosJson = j['otrosEspaciosList'] as List?;
    if (otrosEspaciosJson != null) {
      otrosEspaciosList = otrosEspaciosJson
          .whereType<Map<String, dynamic>>()
          .map(OtroEspacioItem.fromJson)
          .toList();
    }
    _jItemMap(j['mobiliario'], mobiliarioItems);
    dotTieneCocina           = j['dotTieneCocina'] as bool?;
    dotEstadoCocina          = j['dotEstadoCocina'] as String?;
    dotTieneComedor          = j['dotTieneComedor'] as bool?;
    dotEstadoComedor         = j['dotEstadoComedor'] as String?;
    dotTieneEmergencia       = j['dotTieneEmergencia'] as bool?;
    _jItemMap(j['dotCocinaItems'], dotCocinaItems);
    _jItemMap(j['dotEmergenciaItems'], dotEmergenciaItems);
    tieneEnergiaElectrica        = j['tieneEnergiaElectrica'] as bool?;
    fuenteEnergia                = j['fuenteEnergia'] as String?;
    numeroCLientesCENS           = j['numeroCLientesCENS'] as String?;
    calidadServicioCENS          = j['calidadServicioCENS'] as String?;
    motivoCalidadServicioCENS    = j['motivoCalidadServicioCENS'] as String?;
    interesSolucionesSolares     = j['interesSolucionesSolares'] as bool?;
    cuentaSalonHerramientasTIC   = j['cuentaSalonHerramientasTIC'] as bool?;
    instalacionesElectricasAdecuadas = j['instalacionesElectricasAdecuadas'] as bool?;
    photoInstalacionesElectricas = j['photoInstalacionesElectricas'] as String?;
    final eJson = j['electrodomesticos'] as Map?;
    if (eJson != null) {
      for (final e in eJson.entries) {
        final item = electrodomesticos[e.key as String];
        if (item != null && e.value is Map) {
          item.tiene    = (e.value as Map)['tiene'] as String?;
          item.cantidad = _jInt((e.value as Map)['cantidad']);
        }
      }
    }
    final otrosJson = j['otrosElectrodomesticos'] as List?;
    if (otrosJson != null) {
      otrosElectrodomesticos = otrosJson
          .whereType<Map<String, dynamic>>()
          .map(OtroElectrodomesticoItem.fromJson)
          .toList();
    }
    tieneAccesoAgua              = j['tieneAccesoAgua'] as bool?;
    fuenteAbastecimiento         = _jList(j['fuenteAbastecimiento']);
    frecuenciaAgua               = j['frecuenciaAgua'] as String?;
    calidadAgua                  = j['calidadAgua'] as String?;
    tieneTanqueAlmacenamiento    = j['tieneTanqueAlmacenamiento'] as bool?;
    materialTanques              = _jList(j['materialTanques']);
    capacidadTanques             = j['capacidadTanques'] as String?;
    estadoRedAcueducto           = j['estadoRedAcueducto'] as String?;
    tieneAguaPotable             = j['tieneAguaPotable'] as String?;
    tratamientoAgua              = _jList(j['tratamientoAgua']);
    tienePuntosHidratacion       = j['tienePuntosHidratacion'] as bool?;
    cantidadPuntosHidratacion    = j['cantidadPuntosHidratacion'] as String?;
    dispositivoSaneamiento         = j['dispositivoSaneamiento'] as String?;
    tipoSistSaneamiento            = _jList(j['tipoSistSaneamiento']);
    estadoRedDesague               = j['estadoRedDesague'] as String?;
    totalSanitariosOrinales        = j['totalSanitariosOrinales'] as String?;
    sanitariosSeparados            = j['sanitariosSeparados'] as bool?;
    cantSanitariosNinas            = j['cantSanitariosNinas'] as String?;
    cantSanitariosNinos            = j['cantSanitariosNinos'] as String?;
    totalSanitariosFuncionan       = j['totalSanitariosFuncionan'] as String?;
    instalacionesDiscapacidad      = j['instalacionesDiscapacidad'] as bool?;
    cantInstalacionesDiscapacidad  = j['cantInstalacionesDiscapacidad'] as String?;
    instalacionesPrimeraInfancia   = j['instalacionesPrimeraInfancia'] as bool?;
    cantInstalacionesPrimeraInfancia = j['cantInstalacionesPrimeraInfancia'] as String?;
    condicionesSanitarios          = _jList(j['condicionesSanitarios']);
    gestionDesechos                = _jList(j['gestionDesechos']);
    sistemaLavadoManos             = _jList(j['sistemaLavadoManos']);
    totalLlavesLavamanos           = j['totalLlavesLavamanos'] as String?;
    frecuenciaInsumos              = j['frecuenciaInsumos'] as String?;
    infoVisualHigiene              = j['infoVisualHigiene'] as bool?;
    tieneComiteASH                 = j['tieneComiteASH'] as bool?;
    capacitacionComite             = j['capacitacionComite'] as String?;
    actividadesPromocionASH        = _jList(j['actividadesPromocionASH']);
    quienPromocionASH              = _jList(j['quienPromocionASH']);
    frecuenciaActividadesASH       = j['frecuenciaActividadesASH'] as String?;
    riesgosExperimentados          = _jList(j['riesgosExperimentados']);
    otroRiesgo                     = j['otroRiesgo'] as String?;
    observacionesASH               = j['observacionesASH'] as String?;
    r1SuspendioClases              = j['r1SuspendioClases'] as String?;
    r11DiassinServicio             = j['r11DiassinServicio'] as String?;
    r12CausaSuspension             = _jList(j['r12CausaSuspension']);
    r12OtraCausa                   = j['r12OtraCausa'] as String?;
    r2Amenazas                     = _jList(j['r2Amenazas']);
    r21AmenazasPrioritarias        = _jList(j['r21AmenazasPrioritarias']);
    r3FormasLlegada                = _jList(j['r3FormasLlegada']);
    r31DuracionTrayecto            = j['r31DuracionTrayecto'] as String?;
    r32RiesgosTrayecto             = _jList(j['r32RiesgosTrayecto']);
    r32OtraCondicion               = j['r32OtraCondicion'] as String?;
    r33TrayectoSuspendido          = j['r33TrayectoSuspendido'] as String?;
    r4QuienAvisa                   = j['r4QuienAvisa'] as String?;
    r4QuienAvisaOtro               = j['r4QuienAvisaOtro'] as String?;
    r41MedioAviso                  = _jList(j['r41MedioAviso']);
    r41MedioAvisoOtro              = j['r41MedioAvisoOtro'] as String?;
    r42ObtuvoRespuesta             = j['r42ObtuvoRespuesta'] as String?;
    r5CargoResponsable             = j['r5CargoResponsable'] as String?;
    r51FrecuenciaActualizacion     = j['r51FrecuenciaActualizacion'] as String?;
    observacionesGenerales         = j['observacionesGenerales'] as String?;
  }

  static int? _jInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static List<String> _jList(dynamic v) {
    if (v is List) return v.whereType<String>().toList();
    return [];
  }

  static void _jItemMap(dynamic json, Map<String, MobiliarioItem> items) {
    if (json is! Map) return;
    for (final e in json.entries) {
      final item = items[e.key as String];
      if (item != null && e.value is Map) {
        final m = e.value as Map;
        item.cantTotal   = _jInt(m['cantTotal']);
        item.cantBueno   = _jInt(m['cantBueno']);
        item.cantRegular = _jInt(m['cantRegular']);
        item.cantMalo    = _jInt(m['cantMalo']);
      }
    }
  }

  Map<String, dynamic> toJson() => {
        'formType': 'unified',
        'date': date.toIso8601String(),
        'department': department,
        'municipality': municipality,
        'zone': zone,
        'corregimiento': corregimiento,
        'vereda': vereda,
        'intervieweeName': intervieweeName,
        'intervieweeRole': intervieweeRole,
        'intervieweeContact': intervieweeContact,
        'principalInstitution': principalInstitution,
        'principalInstitutionDane': principalInstitutionDane,
        'schoolName': schoolName,
        'daneCode': daneCode,
        'principalName': principalName,
        'principalPhone': principalPhone,
        'principalEmail': principalEmail,
        'latitude': latitude,
        'longitude': longitude,
        'locationUnavailable': locationUnavailable,
        'accessTypes': accessTypes,
        'accessObservations': accessObservations,
        'recentProjects': recentProjects,
        'totalStudents': totalStudents,
        'girlsCount': girlsCount,
        'boysCount': boysCount,
        'refugeeStudents': refugeeStudents,
        'conflictVictims': conflictVictims,
        'ethnicStudents': ethnicStudents,
        'disabledStudents': disabledStudents,
        'teachersCount': teachersCount,
        'adminStaff': adminStaff,
        'educationLevels': educationLevels,
        'academicSchedule': academicSchedule,
        'photoFront': photoFront,
        'photoClassroom1': photoClassroom1,
        'photoClassroom2': photoClassroom2,
        'photoKitchen': photoKitchen,
        'photoDiningRoom': photoDiningRoom,
        'photoBathroom': photoBathroom,
        // Fase 2 — Servicios Públicos
        'tieneGas': tieneGas,
        'fuenteGas': fuenteGas,
        'tieneInternet': tieneInternet,
        'empresaInternet': empresaInternet,
        'observacionesInternet': observacionesInternet,
        // Fase 2 — Infraestructura
        'tieneSalones': tieneSalones,
        'cantidadSalones': cantidadSalones,
        'estadoSalones': estadoSalones,
        'tieneComedor': tieneComedor,
        'cantidadComedor': cantidadComedor,
        'estadoComedor': estadoComedor,
        'tieneCocinaEspacio': tieneCocinaEspacio,
        'cantidadCocina': cantidadCocina,
        'estadoCocina': estadoCocina,
        'tieneSalonReuniones': tieneSalonReuniones,
        'cantidadSalonReuniones': cantidadSalonReuniones,
        'estadoSalonReuniones': estadoSalonReuniones,
        'tieneHabitaciones': tieneHabitaciones,
        'cantidadHabitaciones': cantidadHabitaciones,
        'estadoHabitaciones': estadoHabitaciones,
        'tieneBanos': tieneBanos,
        'cantidadBanos': cantidadBanos,
        'estadoBanos': estadoBanos,
        'tieneOtrosEspacios': tieneOtrosEspacios,
        'otrosEspaciosList': otrosEspaciosList.map((e) => e.toJson()).toList(),
        // Fase 2 — Mobiliario
        'mobiliario': {
          for (final e in mobiliarioItems.entries) e.key: e.value.toJson()
        },
        // Fase 2 — Dotación Especial
        'dotTieneCocina': dotTieneCocina,
        'dotEstadoCocina': dotEstadoCocina,
        'dotTieneComedor': dotTieneComedor,
        'dotEstadoComedor': dotEstadoComedor,
        'dotTieneEmergencia': dotTieneEmergencia,
        'dotCocinaItems': {
          for (final e in dotCocinaItems.entries) e.key: e.value.toJson()
        },
        'dotEmergenciaItems': {
          for (final e in dotEmergenciaItems.entries) e.key: e.value.toJson()
        },
        // Fase 3 — Energía
        'tieneEnergiaElectrica': tieneEnergiaElectrica,
        'fuenteEnergia': fuenteEnergia,
        'numeroCLientesCENS': numeroCLientesCENS,
        'calidadServicioCENS': calidadServicioCENS,
        'motivoCalidadServicioCENS': motivoCalidadServicioCENS,
        'interesSolucionesSolares': interesSolucionesSolares,
        'electrodomesticos': {
          for (final e in electrodomesticos.entries) e.key: e.value.toJson()
        },
        'otrosElectrodomesticos':
            otrosElectrodomesticos.map((e) => e.toJson()).toList(),
        'cuentaSalonHerramientasTIC': cuentaSalonHerramientasTIC,
        'instalacionesElectricasAdecuadas': instalacionesElectricasAdecuadas,
        'photoInstalacionesElectricas': photoInstalacionesElectricas,
        // Fase 4 — Agua
        'tieneAccesoAgua': tieneAccesoAgua,
        'fuenteAbastecimiento': fuenteAbastecimiento,
        'frecuenciaAgua': frecuenciaAgua,
        'calidadAgua': calidadAgua,
        'tieneTanqueAlmacenamiento': tieneTanqueAlmacenamiento,
        'materialTanques': materialTanques,
        'capacidadTanques': capacidadTanques,
        'estadoRedAcueducto': estadoRedAcueducto,
        'tieneAguaPotable': tieneAguaPotable,
        'tratamientoAgua': tratamientoAgua,
        'tienePuntosHidratacion': tienePuntosHidratacion,
        'cantidadPuntosHidratacion': cantidadPuntosHidratacion,
        // Fase 4 — Saneamiento
        'dispositivoSaneamiento': dispositivoSaneamiento,
        'tipoSistSaneamiento': tipoSistSaneamiento,
        'estadoRedDesague': estadoRedDesague,
        'totalSanitariosOrinales': totalSanitariosOrinales,
        'sanitariosSeparados': sanitariosSeparados,
        'cantSanitariosNinas': cantSanitariosNinas,
        'cantSanitariosNinos': cantSanitariosNinos,
        'totalSanitariosFuncionan': totalSanitariosFuncionan,
        'instalacionesDiscapacidad': instalacionesDiscapacidad,
        'cantInstalacionesDiscapacidad': cantInstalacionesDiscapacidad,
        'instalacionesPrimeraInfancia': instalacionesPrimeraInfancia,
        'cantInstalacionesPrimeraInfancia': cantInstalacionesPrimeraInfancia,
        'condicionesSanitarios': condicionesSanitarios,
        'gestionDesechos': gestionDesechos,
        // Fase 4 — Higiene
        'sistemaLavadoManos': sistemaLavadoManos,
        'totalLlavesLavamanos': totalLlavesLavamanos,
        'frecuenciaInsumos': frecuenciaInsumos,
        'infoVisualHigiene': infoVisualHigiene,
        'tieneComiteASH': tieneComiteASH,
        'capacitacionComite': capacitacionComite,
        'actividadesPromocionASH': actividadesPromocionASH,
        'quienPromocionASH': quienPromocionASH,
        'frecuenciaActividadesASH': frecuenciaActividadesASH,
        'riesgosExperimentados': riesgosExperimentados,
        'otroRiesgo': otroRiesgo,
        'observacionesASH': observacionesASH,
        // Fase 5 — Riesgo
        'r1SuspendioClases': r1SuspendioClases,
        'r11DiassinServicio': r11DiassinServicio,
        'r12CausaSuspension': r12CausaSuspension,
        'r12OtraCausa': r12OtraCausa,
        'r2Amenazas': r2Amenazas,
        'r21AmenazasPrioritarias': r21AmenazasPrioritarias,
        'r3FormasLlegada': r3FormasLlegada,
        'r31DuracionTrayecto': r31DuracionTrayecto,
        'r32RiesgosTrayecto': r32RiesgosTrayecto,
        'r32OtraCondicion': r32OtraCondicion,
        'r33TrayectoSuspendido': r33TrayectoSuspendido,
        'r4QuienAvisa': r4QuienAvisa,
        'r4QuienAvisaOtro': r4QuienAvisaOtro,
        'r41MedioAviso': r41MedioAviso,
        'r41MedioAvisoOtro': r41MedioAvisoOtro,
        'r42ObtuvoRespuesta': r42ObtuvoRespuesta,
        'r5CargoResponsable': r5CargoResponsable,
        'r51FrecuenciaActualizacion': r51FrecuenciaActualizacion,
        'observacionesGenerales': observacionesGenerales,
      };
}
