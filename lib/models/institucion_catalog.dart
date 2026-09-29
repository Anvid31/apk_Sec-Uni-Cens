class SedeEducativa {
  final String consSede;
  final String nombre;

  const SedeEducativa({
    required this.consSede,
    required this.nombre,
  });

  factory SedeEducativa.fromJson(Map<String, dynamic> json) {
    return SedeEducativa(
      consSede: json['consSede'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
    );
  }
}

class InstitucionEducativa {
  final String codigoDane;
  final String nombre;
  final List<SedeEducativa> sedes;

  const InstitucionEducativa({
    required this.codigoDane,
    required this.nombre,
    required this.sedes,
  });

  factory InstitucionEducativa.fromJson(Map<String, dynamic> json) {
    final sedesJson = json['sedes'] as List<dynamic>? ?? const [];
    return InstitucionEducativa(
      codigoDane: json['codigoDane'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      sedes: sedesJson
          .whereType<Map<String, dynamic>>()
          .map(SedeEducativa.fromJson)
          .toList(),
    );
  }
}

class ZonaInstituciones {
  final String zona;
  final List<InstitucionEducativa> instituciones;

  const ZonaInstituciones({
    required this.zona,
    required this.instituciones,
  });

  factory ZonaInstituciones.fromJson(Map<String, dynamic> json) {
    final institucionesJson =
        json['instituciones'] as List<dynamic>? ?? const [];
    return ZonaInstituciones(
      zona: json['zona'] as String? ?? '',
      instituciones: institucionesJson
          .whereType<Map<String, dynamic>>()
          .map(InstitucionEducativa.fromJson)
          .toList(),
    );
  }
}

class MunicipioInstituciones {
  final String municipio;
  final List<ZonaInstituciones> zonas;

  const MunicipioInstituciones({
    required this.municipio,
    required this.zonas,
  });

  factory MunicipioInstituciones.fromJson(Map<String, dynamic> json) {
    final zonasJson = json['zonas'] as List<dynamic>? ?? const [];
    return MunicipioInstituciones(
      municipio: json['municipio'] as String? ?? '',
      zonas: zonasJson
          .whereType<Map<String, dynamic>>()
          .map(ZonaInstituciones.fromJson)
          .toList(),
    );
  }
}
