import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/institucion_catalog.dart';

/// Catálogo municipio → zona → institución → sede desde assets.
class InstitucionesCatalogService {
  InstitucionesCatalogService._();

  static const String assetPath = 'assets/data/instituciones.json';

  static List<MunicipioInstituciones>? _cache;
  static Future<List<MunicipioInstituciones>>? _loading;

  /// Alias UI → clave JSON cuando la normalización por tildes no alcanza.
  static const Map<String, String> _municipioAliases = {
    'GRAMALOTE': 'GRMALOTE',
  };

  /// Zona UI → zona JSON.
  static const Map<String, String> _zonaAliases = {
    'URBANO': 'URBANA',
    'URBANA': 'URBANA',
    'RURAL': 'RURAL',
  };

  static Future<List<MunicipioInstituciones>> load() {
    if (_cache != null) {
      return Future.value(_cache);
    }
    _loading ??= _loadFromAsset();
    return _loading!;
  }

  static Future<List<MunicipioInstituciones>> _loadFromAsset() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    _cache = decoded
        .whereType<Map<String, dynamic>>()
        .map(MunicipioInstituciones.fromJson)
        .toList();
    return _cache!;
  }

  /// Normaliza texto para comparar UI ↔ JSON (mayúsculas, sin tildes).
  static String normalizeKey(String value) {
    final upper = value.trim().toUpperCase();
    const accents = {
      'Á': 'A',
      'É': 'E',
      'Í': 'I',
      'Ó': 'O',
      'Ú': 'U',
      'Ü': 'U',
      'Ñ': 'N',
    };
    final buffer = StringBuffer();
    for (final rune in upper.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(accents[char] ?? char);
    }
    return buffer.toString();
  }

  static String normalizeMunicipioKey(String municipioUi) {
    final key = normalizeKey(municipioUi);
    return _municipioAliases[key] ?? key;
  }

  static String normalizeZonaKey(String zonaUi) {
    final key = normalizeKey(zonaUi);
    return _zonaAliases[key] ?? key;
  }

  static MunicipioInstituciones? municipioData(String? municipioUi) {
    if (municipioUi == null || municipioUi.isEmpty || _cache == null) {
      return null;
    }
    final key = normalizeMunicipioKey(municipioUi);
    for (final m in _cache!) {
      if (normalizeKey(m.municipio) == key) return m;
    }
    return null;
  }

  static ZonaInstituciones? zonaData(String? municipioUi, String? zonaUi) {
    final municipio = municipioData(municipioUi);
    if (municipio == null || zonaUi == null || zonaUi.isEmpty) return null;
    final key = normalizeZonaKey(zonaUi);
    for (final z in municipio.zonas) {
      if (normalizeKey(z.zona) == key) return z;
    }
    return null;
  }

  static List<InstitucionEducativa> institucionesPor(
    String? municipioUi,
    String? zonaUi,
  ) {
    final zona = zonaData(municipioUi, zonaUi);
    if (zona == null) return const [];
    final list = List<InstitucionEducativa>.from(zona.instituciones);
    list.sort((a, b) => a.nombre.compareTo(b.nombre));
    return list;
  }

  static InstitucionEducativa? institucionPorCodigo(
    String? municipioUi,
    String? zonaUi,
    String? codigoDane,
  ) {
    if (codigoDane == null || codigoDane.isEmpty) return null;
    for (final inst in institucionesPor(municipioUi, zonaUi)) {
      if (inst.codigoDane == codigoDane) return inst;
    }
    return null;
  }

  /// Solo para borradores antiguos sin código: resuelve por nombre si es único.
  static InstitucionEducativa? institucionUnicaPorNombre(
    String? municipioUi,
    String? zonaUi,
    String? nombre,
  ) {
    final matches = institucionesPor(municipioUi, zonaUi)
        .where((i) => i.nombre == nombre)
        .toList();
    return matches.length == 1 ? matches.first : null;
  }

  static List<SedeEducativa> sedesDe(InstitucionEducativa? institucion) {
    if (institucion == null) return const [];
    final list = List<SedeEducativa>.from(institucion.sedes);
    list.sort((a, b) => a.nombre.compareTo(b.nombre));
    return list;
  }

  static SedeEducativa? sedePorNombre(
    InstitucionEducativa? institucion,
    String? nombre,
  ) {
    if (institucion == null || nombre == null || nombre.isEmpty) return null;
    for (final sede in institucion.sedes) {
      if (sede.nombre == nombre) return sede;
    }
    return null;
  }
}
