import 'package:flutter/foundation.dart';

/// Ítem de mobiliario con cantidad, estado y observaciones.
class MobiliarioItem {
  int? cantidad;
  String? texto;
  String? observaciones;

  MobiliarioItem({this.cantidad, this.texto, this.observaciones});

  Map<String, dynamic> toJson() => {
        'cantidad': cantidad,
        'texto': texto,
        'observaciones': observaciones,
      };

  void reset() {
    cantidad = null;
    texto = null;
    observaciones = null;
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
  String? schoolName; // REQUERIDO
  String? daneCode; // REQUERIDO

  // --- Rector ---
  String? principalName;
  String? principalPhone;
  String? principalEmail;

  // --- Geolocalización y acceso ---
  double? latitude;
  double? longitude;
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

  // Lista de ítems de mobiliario (código → nombre)
  static const List<Map<String, String>> mobiliarioItemsList = [
    {'code': '117', 'name': 'Puesto de trabajo primera infancia'},
    {'code': '118', 'name': 'Puesto de Trabajo Aula Primaria'},
    {'code': '119', 'name': 'Puesto de Trabajo Aula Secundaria'},
    {'code': '121', 'name': 'Puesto de Trabajo Biblioteca'},
    {'code': '126', 'name': 'Puesto de Trabajo Docente'},
    {'code': '131', 'name': 'Puesto de Trabajo Preescolar'},
    {'code': '151', 'name': 'Módulo de biblioteca 1,30 mts.'},
    {'code': '153', 'name': 'Mueble de almacenamiento aulas'},
    {'code': '165', 'name': 'Tablero'},
    {'code': '166', 'name': 'Tablero Alta resistencia humedad'},
    {'code': '167', 'name': 'Tablero móvil'},
    {'code': '172', 'name': 'Papelera'},
    {'code': '174', 'name': 'Tándem 3 canecas aulas'},
  ];

  // --- Servicios Públicos ---
  bool? tieneGas;
  List<String> fuenteGas = [];
  bool? tieneInternet;
  String? empresaInternet;

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
  String? cantidadOtrosEspacios;
  String? estadoOtrosEspacios;
  String? descripcionOtrosEspacios;

  // --- Ítems de Mobiliario ---
  Map<String, MobiliarioItem> mobiliarioItems = {
    for (final item in mobiliarioItemsList) item['code']!: MobiliarioItem()
  };

  // --- Dotación Especial ---
  bool? dotTieneCocina;
  String? dotNecesidadesMobiliarioCocina;
  String? dotNecesidadesUtensiliosCocina;
  bool? dotNecesitaBotiquin;
  String? dotNecesidadesEmergencia;

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

  // --- Electrodomésticos ---
  Map<String, ElectrodomesticoItem> electrodomesticos = {
    for (final item in electrodomesticosList) item['key']!: ElectrodomesticoItem()
  };
  String? otrosElectrodomesticos;

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
  // ESTADO DE ENVÍO
  // ============================================================
  bool isSubmitted = false;
  DateTime? submissionDate;
  String submissionStatus = 'pending';
  String? submissionId;

  // ============================================================
  // MÉTODOS
  // ============================================================

  void notify() => notifyListeners();

  void reset() {
    date = DateTime.now();
    municipality = null;
    zone = null;
    corregimiento = null;
    vereda = null;
    intervieweeName = null;
    intervieweeRole = null;
    intervieweeContact = null;
    principalInstitution = null;
    schoolName = null;
    daneCode = null;
    principalName = null;
    principalPhone = null;
    principalEmail = null;
    latitude = null;
    longitude = null;
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
    // Fase 2 — Infraestructura
    tieneSalones = null; cantidadSalones = null; estadoSalones = null;
    tieneComedor = null; cantidadComedor = null; estadoComedor = null;
    tieneCocinaEspacio = null; cantidadCocina = null; estadoCocina = null;
    tieneSalonReuniones = null; cantidadSalonReuniones = null; estadoSalonReuniones = null;
    tieneHabitaciones = null; cantidadHabitaciones = null; estadoHabitaciones = null;
    tieneBanos = null; cantidadBanos = null; estadoBanos = null;
    tieneOtrosEspacios = null; cantidadOtrosEspacios = null;
    estadoOtrosEspacios = null; descripcionOtrosEspacios = null;
    // Fase 2 — Mobiliario
    for (final item in mobiliarioItems.values) item.reset();
    // Fase 2 — Dotación Especial
    dotTieneCocina = null;
    dotNecesidadesMobiliarioCocina = null;
    dotNecesidadesUtensiliosCocina = null;
    dotNecesitaBotiquin = null;
    dotNecesidadesEmergencia = null;
    // Fase 3 — Energía
    tieneEnergiaElectrica = null;
    fuenteEnergia = null;
    numeroCLientesCENS = null;
    for (final item in electrodomesticos.values) item.reset();
    otrosElectrodomesticos = null;
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
    isSubmitted = false;
    submissionDate = null;
    submissionStatus = 'pending';
    submissionId = null;
    notifyListeners();
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
        'schoolName': schoolName,
        'daneCode': daneCode,
        'principalName': principalName,
        'principalPhone': principalPhone,
        'principalEmail': principalEmail,
        'latitude': latitude,
        'longitude': longitude,
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
        'cantidadOtrosEspacios': cantidadOtrosEspacios,
        'estadoOtrosEspacios': estadoOtrosEspacios,
        'descripcionOtrosEspacios': descripcionOtrosEspacios,
        // Fase 2 — Mobiliario
        'mobiliario': {
          for (final e in mobiliarioItems.entries) e.key: e.value.toJson()
        },
        // Fase 2 — Dotación Especial
        'dotTieneCocina': dotTieneCocina,
        'dotNecesidadesMobiliarioCocina': dotNecesidadesMobiliarioCocina,
        'dotNecesidadesUtensiliosCocina': dotNecesidadesUtensiliosCocina,
        'dotNecesitaBotiquin': dotNecesitaBotiquin,
        'dotNecesidadesEmergencia': dotNecesidadesEmergencia,
        // Fase 3 — Energía
        'tieneEnergiaElectrica': tieneEnergiaElectrica,
        'fuenteEnergia': fuenteEnergia,
        'numeroCLientesCENS': numeroCLientesCENS,
        'electrodomesticos': {
          for (final e in electrodomesticos.entries) e.key: e.value.toJson()
        },
        'otrosElectrodomesticos': otrosElectrodomesticos,
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
      };
}
