import 'package:flutter/foundation.dart';
import 'furniture_item.dart';
import '../data/furniture_catalog.dart';
import '../services/auto_sync_service.dart';

class FurnitureSurveyState extends ChangeNotifier {
  // --- Información General ---
  DateTime fecha = DateTime.now();
  String departamento = '';
  String municipio = '';
  String? zona; // 'Urbano' o 'Rural'
  String corregimiento = '';
  String vereda = '';
  
  String nombreEntrevistado = '';
  String cargoEntrevistado = '';
  String contactoEntrevistado = '';

  String nombreRector = '';
  String contactoRector = '';
  String emailRector = '';
  String nombreInstitucionPrincipal = '';
  String nombreSedeEducativa = '';
  String codigoDane = '';

  String latitud = '';
  String longitud = '';
  String? tipoAcceso;

  bool riesgoCierre = false;
  String motivoCierre = '';

  // --- Información Cobertura ---
  String numAlumnos = '';
  String numMujeres = '';
  String numHombres = '';
  String numDocentes = '';
  String aniosFuncionamiento = '';
  List<String> nivelesEducativos = [];
  String? jornada;

  // --- Diagnóstico Infraestructura ---
  // Cantidades y estados
  bool hasSalones = false;
  int cantidadSalones = 0;
  String estadoSalones = '';

  bool hasComedor = false;
  int cantidadComedor = 0;
  String estadoComedor = '';

  bool hasCocina = false;
  int cantidadCocina = 0;
  String estadoCocina = '';

  bool hasSalonReuniones = false;
  int cantidadSalonReuniones = 0;
  String estadoSalonReuniones = '';

  bool hasHabitaciones = false;
  int cantidadHabitaciones = 0;
  String estadoHabitaciones = '';

  bool hasBanos = false;
  int cantidadBanos = 0;
  String estadoBanos = '';

  bool hasOtros = false;
  int cantidadOtros = 0;
  String estadoOtros = '';
  String descripcionOtrosEspacios = '';

  String proyectosEjecucion = '';
  String serviciosPublicos = ''; // Quizás deprecated o 'otros servicios'
  
  bool tieneEnergia = false;
  String fuenteEnergia = '';
  
  bool tieneAgua = false;
  String fuenteAgua = '';

  bool tieneGas = false;
  String fuenteGas = '';

  // Electrodomésticos
  bool hasNevera = false;
  int cantidadNevera = 0;

  bool hasTelevisor = false;
  int cantidadTelevisor = 0;

  bool hasComputador = false;
  int cantidadComputador = 0;

  bool hasVentilador = false;
  int cantidadVentilador = 0;

  bool hasVideoBeam = false;
  int cantidadVideoBeam = 0;

  bool hasImpresora = false;
  int cantidadImpresora = 0;
  bool hasEquipoSonido = false;
  int cantidadEquipoSonido = 0;

  List<Map<String, dynamic>> otrosElectrodomesticos = [];

  // Deprecated or kept for compatibility if needed, but we will ignore it in UI
  String electrodomesticos = ''; 
  bool tieneInternet = false;

  // --- Evidencia Fotográfica ---
  String? photoPanoramica;
  String? photoTablero;
  String? photoCocina;
  String? photoComedor;
  String? photoInterna;

  // --- Items Mobiliario ---
  late List<FurnitureItem> items;
  
  // --- Dotación Especial ---
  bool tieneCocina = false;
  String necesidadesMobiliarioCocina = '';
  String necesidadesUtensiliosCocina = '';

  bool necesitaBotiquin = false;
  String necesidadesEmergencia = '';

  FurnitureSurveyState() {
    items = FurnitureCatalog.getItems();
  }

  void updateGeneralInfo({
    DateTime? fecha,
    String? departamento,
    String? municipio,
    String? zona,
    String? corregimiento,
    String? vereda,
    String? nombreEntrevistado,
    String? cargoEntrevistado,
    String? contactoEntrevistado,
    String? nombreRector,
    String? contactoRector,
    String? emailRector,
    String? nombreInstitucionPrincipal,
    String? nombreSedeEducativa,
    String? codigoDane,
    String? latitud,
    String? longitud,
    String? tipoAcceso,
    bool? riesgoCierre,
    String? motivoCierre,
  }) {
    if (fecha != null) this.fecha = fecha;
    if (departamento != null) this.departamento = departamento;
    if (municipio != null) this.municipio = municipio;
    if (zona != null) this.zona = zona;
    if (corregimiento != null) this.corregimiento = corregimiento;
    if (vereda != null) this.vereda = vereda;
    if (nombreEntrevistado != null) this.nombreEntrevistado = nombreEntrevistado;
    if (cargoEntrevistado != null) this.cargoEntrevistado = cargoEntrevistado;
    if (contactoEntrevistado != null) this.contactoEntrevistado = contactoEntrevistado;
    if (nombreRector != null) this.nombreRector = nombreRector;
    if (contactoRector != null) this.contactoRector = contactoRector;
    if (emailRector != null) this.emailRector = emailRector;
    if (nombreInstitucionPrincipal != null) this.nombreInstitucionPrincipal = nombreInstitucionPrincipal;
    if (nombreSedeEducativa != null) this.nombreSedeEducativa = nombreSedeEducativa;
    if (codigoDane != null) this.codigoDane = codigoDane;
    if (latitud != null) this.latitud = latitud;
    if (longitud != null) this.longitud = longitud;
    if (tipoAcceso != null) this.tipoAcceso = tipoAcceso;
    if (riesgoCierre != null) this.riesgoCierre = riesgoCierre;
    if (motivoCierre != null) this.motivoCierre = motivoCierre;
    notifyListeners();
  }

  void updateCoverage({
    String? numAlumnos,
    String? numMujeres,
    String? numHombres,
    String? numDocentes,
    String? aniosFuncionamiento,
    List<String>? nivelesEducativos,
    String? jornada,
  }) {
    if (numAlumnos != null) this.numAlumnos = numAlumnos;
    if (numMujeres != null) this.numMujeres = numMujeres;
    if (numHombres != null) this.numHombres = numHombres;
    if (numDocentes != null) this.numDocentes = numDocentes;
    if (aniosFuncionamiento != null) this.aniosFuncionamiento = aniosFuncionamiento;
    if (nivelesEducativos != null) this.nivelesEducativos = nivelesEducativos;
    if (jornada != null) this.jornada = jornada;
    notifyListeners();
  }

  void updateInfrastructure({
    bool? hasSalones, int? cantidadSalones, String? estadoSalones,
    bool? hasComedor, int? cantidadComedor, String? estadoComedor,
    bool? hasCocina, int? cantidadCocina, String? estadoCocina,
    bool? hasSalonReuniones, int? cantidadSalonReuniones, String? estadoSalonReuniones,
    bool? hasHabitaciones, int? cantidadHabitaciones, String? estadoHabitaciones,
    bool? hasBanos, int? cantidadBanos, String? estadoBanos,
    bool? hasOtros, int? cantidadOtros, String? estadoOtros, String? descripcionOtrosEspacios,
    String? proyectosEjecucion,
    String? serviciosPublicos,
    bool? tieneEnergia,
    String? fuenteEnergia,
    bool? tieneAgua,
    String? fuenteAgua,
    bool? tieneGas,
    String? fuenteGas,
    
    // Electrodomésticos replacements
    bool? hasNevera, int? cantidadNevera,
    bool? hasTelevisor, int? cantidadTelevisor,
    bool? hasComputador, int? cantidadComputador,
    bool? hasVentilador, int? cantidadVentilador,
    bool? hasVideoBeam, int? cantidadVideoBeam,
    bool? hasImpresora, int? cantidadImpresora,
    bool? hasEquipoSonido, int? cantidadEquipoSonido,
    
    List<Map<String, dynamic>>? otrosElectrodomesticos,
    
    String? electrodomesticos, // Kept for minimal breakage
    bool? tieneInternet,
  }) {
    if (hasSalones != null) this.hasSalones = hasSalones;
    if (cantidadSalones != null) this.cantidadSalones = cantidadSalones;
    if (estadoSalones != null) this.estadoSalones = estadoSalones;
    
    if (hasComedor != null) this.hasComedor = hasComedor;
    if (cantidadComedor != null) this.cantidadComedor = cantidadComedor;
    if (estadoComedor != null) this.estadoComedor = estadoComedor;

    if (hasCocina != null) this.hasCocina = hasCocina;
    if (cantidadCocina != null) this.cantidadCocina = cantidadCocina;
    if (estadoCocina != null) this.estadoCocina = estadoCocina;

    if (hasSalonReuniones != null) this.hasSalonReuniones = hasSalonReuniones;
    if (cantidadSalonReuniones != null) this.cantidadSalonReuniones = cantidadSalonReuniones;
    if (estadoSalonReuniones != null) this.estadoSalonReuniones = estadoSalonReuniones;

    if (hasHabitaciones != null) this.hasHabitaciones = hasHabitaciones;
    if (cantidadHabitaciones != null) this.cantidadHabitaciones = cantidadHabitaciones;
    if (estadoHabitaciones != null) this.estadoHabitaciones = estadoHabitaciones;

    if (hasBanos != null) this.hasBanos = hasBanos;
    if (cantidadBanos != null) this.cantidadBanos = cantidadBanos;
    if (estadoBanos != null) this.estadoBanos = estadoBanos;

    if (hasOtros != null) this.hasOtros = hasOtros;
    if (cantidadOtros != null) this.cantidadOtros = cantidadOtros;
    if (estadoOtros != null) this.estadoOtros = estadoOtros;
    if (descripcionOtrosEspacios != null) this.descripcionOtrosEspacios = descripcionOtrosEspacios;

    if (proyectosEjecucion != null) this.proyectosEjecucion = proyectosEjecucion;
    if (serviciosPublicos != null) this.serviciosPublicos = serviciosPublicos;
    if (tieneEnergia != null) this.tieneEnergia = tieneEnergia;
    if (fuenteEnergia != null) this.fuenteEnergia = fuenteEnergia;
    if (tieneAgua != null) this.tieneAgua = tieneAgua;
    if (fuenteAgua != null) this.fuenteAgua = fuenteAgua;
    if (tieneGas != null) this.tieneGas = tieneGas;
    if (fuenteGas != null) this.fuenteGas = fuenteGas;

    if (hasNevera != null) this.hasNevera = hasNevera;
    if (cantidadNevera != null) this.cantidadNevera = cantidadNevera;

    if (hasTelevisor != null) this.hasTelevisor = hasTelevisor;
    if (cantidadTelevisor != null) this.cantidadTelevisor = cantidadTelevisor;

    if (hasComputador != null) this.hasComputador = hasComputador;
    if (cantidadComputador != null) this.cantidadComputador = cantidadComputador;

    if (hasVentilador != null) this.hasVentilador = hasVentilador;
    if (cantidadVentilador != null) this.cantidadVentilador = cantidadVentilador;
    
    if (hasVideoBeam != null) this.hasVideoBeam = hasVideoBeam;
    if (cantidadVideoBeam != null) this.cantidadVideoBeam = cantidadVideoBeam;

    if (hasImpresora != null) this.hasImpresora = hasImpresora;
    if (cantidadImpresora != null) this.cantidadImpresora = cantidadImpresora;
    
    if (hasEquipoSonido != null) this.hasEquipoSonido = hasEquipoSonido;
    if (cantidadEquipoSonido != null) this.cantidadEquipoSonido = cantidadEquipoSonido;

    if (otrosElectrodomesticos != null) this.otrosElectrodomesticos = otrosElectrodomesticos;

    if (electrodomesticos != null) this.electrodomesticos = electrodomesticos;
    if (tieneInternet != null) this.tieneInternet = tieneInternet;
    
    notifyListeners();
  }

  void updatePhotos({
    String? photoPanoramica,
    String? photoTablero,
    String? photoCocina,
    String? photoComedor,
    String? photoInterna,
  }) {
    if (photoPanoramica != null) this.photoPanoramica = photoPanoramica;
    if (photoTablero != null) this.photoTablero = photoTablero;
    if (photoCocina != null) this.photoCocina = photoCocina;
    if (photoComedor != null) this.photoComedor = photoComedor;
    if (photoInterna != null) this.photoInterna = photoInterna;
    notifyListeners();
  }

  void updateDotation({
     bool? tieneCocina,
     String? necesidadesMobiliarioCocina,
     String? necesidadesUtensiliosCocina,
     bool? necesitaBotiquin,
     String? necesidadesEmergencia,
  }) {
    if (tieneCocina != null) this.tieneCocina = tieneCocina;
    if (necesidadesMobiliarioCocina != null) this.necesidadesMobiliarioCocina = necesidadesMobiliarioCocina;
    if (necesidadesUtensiliosCocina != null) this.necesidadesUtensiliosCocina = necesidadesUtensiliosCocina;
    if (necesitaBotiquin != null) this.necesitaBotiquin = necesitaBotiquin;
    if (necesidadesEmergencia != null) this.necesidadesEmergencia = necesidadesEmergencia;
    notifyListeners();
  }
  
  void updateItems(List<FurnitureItem> newItems) {
    items = newItems;
    notifyListeners();
  }

  void reset() {
    // Implementar reseteo de variables
    fecha = DateTime.now();
    departamento = '';
    municipio = '';
    zona = null;
    corregimiento = '';
    vereda = '';
    
    // ... resetear el resto ...
    items = FurnitureCatalog.getItems();
    notifyListeners();
  }

  Future<void> submit() async {
      // Filtrar items
      final filledItems = items.where((item) => item.quantity > 0 || item.observations.isNotEmpty).toList();

      final photosMap = <String, String>{};
      if (photoPanoramica != null) photosMap['panoramica_sede'] = photoPanoramica!;
      if (photoTablero != null) photosMap['tablero_general'] = photoTablero!;
      if (photoCocina != null) photosMap['cocina'] = photoCocina!;
      if (photoComedor != null) photosMap['comedor'] = photoComedor!;
      if (photoInterna != null) photosMap['interna_sede'] = photoInterna!;

      final surveyId = DateTime.now().millisecondsSinceEpoch.toString();

      final surveyData = {
        'id': surveyId,
        'tipoFormulario': 'mobiliario',
        'timestamp': DateTime.now().toIso8601String(),
        'tipoEncuesta': 'mobiliario',
        'datos': {
          'informacionGeneral': {
            'fecha': fecha.toString().split(' ')[0],
            'departamento': departamento,
            'municipio': municipio,
            'zona': zona,
            'corregimiento': corregimiento,
            'vereda': vereda,
            'entrevistado': {
              'nombre': nombreEntrevistado,
              'cargo': cargoEntrevistado,
              'contacto': contactoEntrevistado,
            },
            'institucion': {
               'nombreRector': nombreRector,
               'contactoRector': contactoRector,
               'emailRector': emailRector,
               'nombreInstitucionPrincipal': nombreInstitucionPrincipal,
               'nombreSedeEducativa': nombreSedeEducativa,
            },
            'ubicacion': {
              'latitud': latitud,
              'longitud': longitud,
              'tipoAcceso': tipoAcceso,
            },
           'riesgos': {
              'riesgoCierre': riesgoCierre,
              'motivo': motivoCierre,
            },
          },
          'informacionCobertura': {
             'numAlumnos': numAlumnos,
             'numMujeres': numMujeres,
             'numHombres': numHombres,
             'numDocentes': numDocentes,
             'aniosFuncionamiento': aniosFuncionamiento,
             'nivelesEducativos': nivelesEducativos,
          },
          'diagnosticoInfraestructura': {
            'hasSalones': hasSalones, 'cantidadSalones': cantidadSalones, 'estadoSalones': estadoSalones,
            'hasComedor': hasComedor, 'cantidadComedor': cantidadComedor, 'estadoComedor': estadoComedor,
            'hasCocina': hasCocina, 'cantidadCocina': cantidadCocina, 'estadoCocina': estadoCocina,
            'hasSalonReuniones': hasSalonReuniones, 'cantidadSalonReuniones': cantidadSalonReuniones, 'estadoSalonReuniones': estadoSalonReuniones,
            'hasHabitaciones': hasHabitaciones, 'cantidadHabitaciones': cantidadHabitaciones, 'estadoHabitaciones': estadoHabitaciones,
            'hasBanos': hasBanos, 'cantidadBanos': cantidadBanos, 'estadoBanos': estadoBanos,
            'hasOtros': hasOtros, 'cantidadOtros': cantidadOtros, 'estadoOtros': estadoOtros,
            'descripcionOtrosEspacios': descripcionOtrosEspacios,
            'proyectosEjecucion': proyectosEjecucion,
            'serviciosPublicos': serviciosPublicos,
            'tieneEnergia': tieneEnergia,
            'fuenteEnergia': fuenteEnergia,
            'tieneAgua': tieneAgua,
            'fuenteAgua': fuenteAgua,
            'tieneGas': tieneGas,
            'fuenteGas': fuenteGas,
            
            // Electrodomésticos mapping
            'hasNevera': hasNevera, 'cantidadNevera': cantidadNevera,
            'hasTelevisor': hasTelevisor, 'cantidadTelevisor': cantidadTelevisor,
            'hasComputador': hasComputador, 'cantidadComputador': cantidadComputador,
            'hasVentilador': hasVentilador, 'cantidadVentilador': cantidadVentilador,
            'hasVideoBeam': hasVideoBeam, 'cantidadVideoBeam': cantidadVideoBeam,
            'hasImpresora': hasImpresora, 'cantidadImpresora': cantidadImpresora,
            'hasEquipoSonido': hasEquipoSonido, 'cantidadEquipoSonido': cantidadEquipoSonido,
            'otrosElectrodomesticos': otrosElectrodomesticos,
            
            'electrodomesticos': electrodomesticos, // Legacy
            'tieneInternet': tieneInternet,
          },
          'dane': codigoDane,
          'items': filledItems.map((e) => e.toJson()).toList(),
          'dotacionCocina': {
            'tieneCocina': tieneCocina,
            'necesidadesMobiliario': necesidadesMobiliarioCocina,
            'necesidadesUtensilios': necesidadesUtensiliosCocina,
          },
          'dotacionEmergencia': {
            'necesitaBotiquin': necesitaBotiquin,
            'necesidades': necesidadesEmergencia,
          },
          'fotos': photosMap,
        },
        'nombreInstitucion': nombreSedeEducativa,
        'codigoDane': codigoDane,
      };

      await AutoSyncService.scheduleImmediateSync(surveyData);
  }
}
