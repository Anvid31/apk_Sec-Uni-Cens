// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../models/survey_state.dart';

class CsvExportService {
  /// Genera un archivo CSV con los datos de la encuesta
  static String generateSurveyCsv(SurveyState surveyState) {
    final List<List<dynamic>> rows = [];
    
    // DEBUG: Verificar TODOS los datos del estado
    print('🔍 DEBUG Estado completo en CSV Export:');
    print('   🏢 Institutional Info completo: ${surveyState.institutionalInfo.toJson()}');
    
    // Encabezados
    rows.add([
      'Campo',
      'Valor',
      'Sección'
    ]);
    
    // Información General
    final generalInfo = surveyState.generalInfo;
    rows.add(['Fecha', generalInfo.date?.toIso8601String() ?? '', 'General']);
    rows.add(['Departamento', generalInfo.department ?? '', 'General']);
    rows.add(['Municipio', generalInfo.municipality ?? '', 'General']);
    rows.add(['Corregimiento', generalInfo.district ?? '', 'General']);
    rows.add(['Vereda', generalInfo.village ?? '', 'General']);
    rows.add(['Nombre Entrevistado', generalInfo.intervieweeName ?? '', 'General']);
    rows.add(['Contacto', generalInfo.contact ?? '', 'General']);
    
    // Información Institucional
    final instInfo = surveyState.institutionalInfo;
    
    // DEBUG: Verificar el email específicamente
    print('🔍 DEBUG Email en CSV Export:');
    print('   - Email value: "${instInfo.email}"');
    print('   - Email is null: ${instInfo.email == null}');
    print('   - Email is empty: ${instInfo.email?.isEmpty ?? true}');
    print('   - Todos los campos institucionales:');
    print('     * institutionName: "${instInfo.institutionName}"');
    print('     * principalName: "${instInfo.principalName}"');
    print('     * contact: "${instInfo.contact}"');
    print('     * email: "${instInfo.email}"');
    
    rows.add(['Nombre Institución', instInfo.institutionName ?? '', 'Institucional']);
    rows.add(['Nombre Rector', instInfo.principalName ?? '', 'Institucional']);
    rows.add(['Ubicación', instInfo.location ?? '', 'Institucional']);
    rows.add(['Sede Educativa', instInfo.educationalHeadquarters ?? '', 'Institucional']);
    rows.add(['Contacto Institución', instInfo.contact ?? '', 'Institucional']);
    rows.add(['Email', instInfo.email ?? '', 'Institucional']);
    
    // Información de Cobertura
    final coverageInfo = surveyState.coverageInfo;
    rows.add(['Preescolar', coverageInfo.preescolar == true ? 'Sí' : 'No', 'Cobertura']);
    rows.add(['Primaria', coverageInfo.primaria == true ? 'Sí' : 'No', 'Cobertura']);
    rows.add(['Secundaria', coverageInfo.segundaria == true ? 'Sí' : 'No', 'Cobertura']);
    rows.add(['Total Estudiantes', coverageInfo.totalStudents?.toString() ?? '0', 'Cobertura']);
    rows.add(['Cantidad Niños', coverageInfo.boysCount?.toString() ?? '0', 'Cobertura']);
    rows.add(['Cantidad Niñas', coverageInfo.girlsCount?.toString() ?? '0', 'Cobertura']);
    rows.add(['Cantidad Profesores', coverageInfo.teachersCount?.toString() ?? '0', 'Cobertura']);
    
    // Información de Infraestructura
    final infraInfo = surveyState.infrastructureInfo;
    rows.add(['Tiene Salones', infraInfo.hasSalones ? 'Sí' : 'No', 'Infraestructura']);
    rows.add(['Cantidad Salones', infraInfo.cantidadSalones.toString(), 'Infraestructura']);
    rows.add(['Tiene Comedor', infraInfo.hasComedor ? 'Sí' : 'No', 'Infraestructura']);
    rows.add(['Cantidad Comedor', infraInfo.cantidadComedor.toString(), 'Infraestructura']);
    rows.add(['Tiene Cocina', infraInfo.hasCocina ? 'Sí' : 'No', 'Infraestructura']);
    rows.add(['Cantidad Cocina', infraInfo.cantidadCocina.toString(), 'Infraestructura']);
    rows.add(['Tiene Salón Reuniones', infraInfo.hasSalonReuniones ? 'Sí' : 'No', 'Infraestructura']);
    rows.add(['Cantidad Salón Reuniones', infraInfo.cantidadSalonReuniones.toString(), 'Infraestructura']);
    rows.add(['Tiene Habitaciones', infraInfo.hasHabitaciones ? 'Sí' : 'No', 'Infraestructura']);
    rows.add(['Cantidad Habitaciones', infraInfo.cantidadHabitaciones.toString(), 'Infraestructura']);
    rows.add(['Tiene Baños', infraInfo.hasBanos ? 'Sí' : 'No', 'Infraestructura']);
    rows.add(['Cantidad Baños', infraInfo.cantidadBanos.toString(), 'Infraestructura']);
    rows.add(['Tiene Otros', infraInfo.hasOtros ? 'Sí' : 'No', 'Infraestructura']);
    rows.add(['Cantidad Otros', infraInfo.cantidadOtros.toString(), 'Infraestructura']);
    rows.add(['Descripción Otros Espacios', infraInfo.descripcionOtrosEspacios, 'Infraestructura']);
    rows.add(['Descripción Otro Predio', infraInfo.descripcionOtroPredio, 'Infraestructura']);
    rows.add(['Proyectos Infraestructura', infraInfo.proyectosInfraestructura, 'Infraestructura']);
    rows.add(['Propiedad Predio', infraInfo.propiedadPredio, 'Infraestructura']);
    
    // Información Eléctrica
    final electricInfo = surveyState.electricityInfo;
    rows.add(['Servicio Eléctrico', electricInfo.hasElectricService == true ? 'Sí' : 'No', 'Electricidad']);
    rows.add(['Tipo Servicio Eléctrico', electricInfo.electricServiceType ?? '', 'Electricidad']);
    rows.add(['Descripción Otro Servicio', electricInfo.otherElectricServiceDescription ?? '', 'Electricidad']);
    rows.add(['Observaciones Electricidad', electricInfo.observations ?? '', 'Electricidad']);
    rows.add(['Interés Paneles Solares', electricInfo.interestedInSolarPanels == true ? 'Sí' : 'No', 'Electricidad']);
    
    // Electrodomésticos
    final appliancesInfo = surveyState.appliancesInfo;
    for (var appliance in appliancesInfo.appliances) {
      rows.add(['Electrodoméstico: ${appliance.name}', '${appliance.quantity} (En uso: ${appliance.isInUse ? "Sí" : "No"})', 'Electrodomésticos']);
    }
    if (appliancesInfo.otherAppliances != null && appliancesInfo.otherAppliances!.isNotEmpty) {
      rows.add(['Otros Electrodomésticos', appliancesInfo.otherAppliances!, 'Electrodomésticos']);
    }
    
    // Vías de Acceso
    final accessInfo = surveyState.accessRouteInfo;
    final accessData = accessInfo.toJson();
    accessData.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        rows.add(['Vía de Acceso: $key', value.toString(), 'Vías de Acceso']);
      }
    });
    
    // Observaciones
    final obsInfo = surveyState.observationsInfo;
    if (obsInfo.additionalObservations != null && obsInfo.additionalObservations!.isNotEmpty) {
      rows.add(['Observaciones Adicionales', obsInfo.additionalObservations!, 'Observaciones']);
    }
    
    return const ListToCsvConverter().convert(rows);
  }

  /// Crea un archivo CSV y lo guarda en el dispositivo
  static Future<File?> createCsvFile(SurveyState surveyState) async {
    try {
      // Generar contenido CSV
      final csvContent = generateSurveyCsv(surveyState);
      
      // Obtener directorio de documentos
      final directory = await getApplicationDocumentsDirectory();
      
      // Crear nombre de archivo con timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final institutionName = surveyState.institutionalInfo.institutionName
          ?.replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^\w\-_]'), '') ?? 'sede';
      final fileName = 'caracterizacion_${institutionName}_$timestamp.csv';
      
      // Crear archivo
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvContent);
      
      print('✅ Archivo CSV creado exitosamente: ${file.path}');
      print('📊 Tamaño del archivo: ${_getFileSize(file)}');
      
      return file;
    } catch (e) {
      print('❌ Error creando archivo CSV: $e');
      return null;
    }
  }

  /// Obtiene el tamaño del archivo en formato legible
  static String _getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}