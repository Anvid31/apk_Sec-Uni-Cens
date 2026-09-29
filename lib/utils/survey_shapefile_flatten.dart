import 'dart:convert';

/// Aplana el JSON de una encuesta para atributos de Shapefile (DBF).
///
/// Omite fotos (Base64) y objetos anidados profundos; resume mobiliario ye
/// electrodomésticos en campos de texto compactos.
class SurveyShapefileFlatten {
  static const _reservedKeys = {
    'ID',
    'CREATED_AT',
    'FORM_TYPE',
    'INSTITUTION',
    'DANE_CODE',
    'MUNICIPALITY',
    'DEPARTMENT',
    'LATITUDE',
    'LONGITUDE',
  };

  static const _photoKeys = {
    'photofront',
    'photoclassroom1',
    'photoclassroom2',
    'photokitchen',
    'photodiningroom',
    'photobathroom',
    'fotofachada',
    'fotosalon1',
    'fotosalon2',
    'fotococina',
    'fotocomedor',
    'fotobano',
  };

  /// Campos de tabla + JSON aplanado listos para DBF.
  static Map<String, String> flattenRow({
    required String id,
    required String createdAt,
    required String formType,
    required String institution,
    required String daneCode,
    required String municipality,
    required String department,
    required double latitude,
    required double longitude,
    required Map<String, dynamic> data,
  }) {
    final out = <String, String>{
      'ID': _truncate(id, 50),
      'CREATED_AT': _truncate(createdAt, 20),
      'FORM_TYPE': _truncate(formType, 20),
      'INSTITUTION': _truncate(institution, 100),
      'DANE_CODE': _truncate(daneCode, 20),
      'MUNICIPALITY': _truncate(municipality, 50),
      'DEPARTMENT': _truncate(department, 50),
      'LATITUDE': latitude.toStringAsFixed(8),
      'LONGITUDE': longitude.toStringAsFixed(8),
    };

    final normalized = _normalizeData(data);
    _flattenMap(normalized, out, '');

    final mobiliario = normalized['mobiliario'];
    if (mobiliario is Map) {
      out['MOBILIARIO'] = _truncate(_summarizeMobiliario(mobiliario), 200);
    }

    final electro = normalized['electrodomesticos'];
    if (electro is Map) {
      var summary = _summarizeElectrodomesticos(electro);
      final otros = normalized['otrosElectrodomesticos'];
      if (otros is List && otros.isNotEmpty) {
        final otrosSummary = _summarizeOtrosElectrodomesticos(otros);
        if (otrosSummary.isNotEmpty) {
          summary = summary.isEmpty
              ? 'otros:$otrosSummary'
              : '$summary; otros:$otrosSummary';
        }
      }
      out['ELECTRODOM'] = _truncate(summary, 200);
    } else {
      final otros = normalized['otrosElectrodomesticos'];
      if (otros is List && otros.isNotEmpty) {
        out['ELECTRODOM'] =
            _truncate('otros:${_summarizeOtrosElectrodomesticos(otros)}', 200);
      }
    }

    return out;
  }

  /// Une atributos de varias filas y asigna nombres DBF únicos (máx. 10 chars).
  static List<ShpAttributeField> buildFieldSchema(
    List<Map<String, String>> rows,
  ) {
    final keys = <String>{};
    for (final row in rows) {
      keys.addAll(row.keys);
    }

    const priority = [
      'ID',
      'CREATED_AT',
      'FORM_TYPE',
      'INSTITUTION',
      'DANE_CODE',
      'MUNICIPALITY',
      'DEPARTMENT',
      'LATITUDE',
      'LONGITUDE',
      'PRINCIPALN',
      'PRINCIPALP',
      'PRINCIPALE',
      'SCHOOLNAME',
      'DATE',
      'ZONE',
      'TOTALSTUDE',
      'TEACHERSCO',
      'TIENEENERG',
      'ACCESSTYP',
      'MOBILIARIO',
      'ELECTRODOM',
    ];

    final ordered = <String>[
      ...priority.where(keys.contains),
      ...keys.where((k) => !priority.contains(k)).toList()..sort(),
    ];

    final usedNames = <String>{};
    final fields = <ShpAttributeField>[];
    for (final key in ordered) {
      final dbfName = _uniqueDbfName(key, usedNames);
      final isCoord = key == 'LATITUDE' || key == 'LONGITUDE';
      final isNumeric = isCoord || _isNumericColumn(rows, key);

      if (isNumeric) {
        fields.add(ShpAttributeField(
          sourceKey: key,
          dbfName: dbfName,
          type: 'N',
          length: isCoord ? 18 : 12,
          decimals: isCoord ? 8 : 0,
        ));
      } else {
        final maxLen = _maxValueLength(rows, key).clamp(20, 100);
        fields.add(ShpAttributeField(
          sourceKey: key,
          dbfName: dbfName,
          type: 'C',
          length: maxLen,
        ));
      }
    }
    return fields;
  }

  // ─── Normalización unified / legacy ───────────────────────────────────────

  static Map<String, dynamic> _normalizeData(Map<String, dynamic> data) {
    if (data['formType'] == 'unified' || data.containsKey('schoolName')) {
      return Map<String, dynamic>.from(data);
    }

    final out = <String, dynamic>{};
    final sections = {
      'generalInfo': 'GEN',
      'informacionGeneral': 'GEN',
      'institutionalInfo': 'INST',
      'informacionInstitucional': 'INST',
      'coverageInfo': 'COV',
      'informacionCobertura': 'COV',
      'infrastructureInfo': 'INFRA',
      'informacionInfraestructura': 'INFRA',
      'electricityInfo': 'ELEC',
      'informacionElectricidad': 'ELEC',
      'appliancesInfo': 'APPL',
      'accessRouteInfo': 'ACCESS',
      'observationsInfo': 'OBS',
      'photographicRecordInfo': 'PHOTO',
    };

    for (final entry in data.entries) {
      final prefix = sections[entry.key];
      if (prefix != null && entry.value is Map) {
        for (final inner in (entry.value as Map).entries) {
          out['${prefix}_${inner.key}'] = inner.value;
        }
      } else {
        out[entry.key] = entry.value;
      }
    }
    return out;
  }

  static void _flattenMap(
    Map<String, dynamic> source,
    Map<String, String> out,
    String prefix,
  ) {
    for (final entry in source.entries) {
      final rawKey = entry.key;
      if (_isPhotoKey(rawKey)) continue;
      if (rawKey == 'mobiliario' ||
          rawKey == 'electrodomesticos' ||
          rawKey == 'otrosElectrodomesticos') {
        continue;
      }

      final key = prefix.isEmpty ? _logicalKey(rawKey) : '${prefix}_$rawKey';
      if (_reservedKeys.contains(key)) continue;

      final value = entry.value;
      if (value == null) continue;

      if (value is Map) {
        if (value.length <= 4 && value.values.every((v) => v is! Map)) {
          for (final inner in value.entries) {
            final subKey = '${key}_${inner.key}';
            out[_logicalKey(subKey)] = _valueToString(inner.value);
          }
        }
        continue;
      }

      final str = _valueToString(value);
      if (str.isEmpty) continue;
      out[_logicalKey(key)] = _truncate(str, 100);
    }
  }

  static String _logicalKey(String key) {
    return key
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m.group(1)}_${m.group(2)}',
        )
        .replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_')
        .toUpperCase();
  }

  static String _uniqueDbfName(String key, Set<String> used) {
    var base = key.length <= 10 ? key : key.substring(0, 10);
    if (!used.contains(base)) {
      used.add(base);
      return base;
    }
    for (var i = 1; i < 100; i++) {
      final suffix = i.toString();
      final trimmed = key.substring(0, 10 - suffix.length);
      final candidate = '$trimmed$suffix';
      if (!used.contains(candidate)) {
        used.add(candidate);
        return candidate;
      }
    }
    return base;
  }

  static bool _isPhotoKey(String key) =>
      _photoKeys.contains(key.toLowerCase()) ||
      key.toLowerCase().startsWith('photo');

  static String _valueToString(dynamic value) {
    if (value == null) return '';
    if (value is bool) return value ? 'Si' : 'No';
    if (value is num) return value.toString();
    if (value is List) {
      return value.map(_valueToString).where((s) => s.isNotEmpty).join(', ');
    }
    if (value is Map) return jsonEncode(value);
    return value.toString();
  }

  static String _summarizeMobiliario(Map mobiliario) {
    final parts = <String>[];
    for (final entry in mobiliario.entries) {
      if (entry.value is! Map) continue;
      final item = entry.value as Map;
      final b = item['cantBueno'];
      final r = item['cantRegular'];
      final m = item['cantMalo'];
      if (b == null && r == null && m == null) continue;
      parts.add('${entry.key}:B${b ?? 0}/R${r ?? 0}/M${m ?? 0}');
    }
    return parts.join('; ');
  }

  static String _summarizeElectrodomesticos(Map electro) {
    final parts = <String>[];
    for (final entry in electro.entries) {
      if (entry.value is! Map) continue;
      final item = entry.value as Map;
      final tiene = item['tiene'] ?? '';
      final cant = item['cantidad'];
      parts.add('${entry.key}:$tiene${cant != null ? "($cant)" : ""}');
    }
    return parts.join('; ');
  }

  static String _summarizeOtrosElectrodomesticos(List otros) {
    final parts = <String>[];
    for (final item in otros) {
      if (item is! Map) continue;
      final nombre = '${item['nombre'] ?? ''}'.trim();
      if (nombre.isEmpty) continue;
      final cant = item['cantidad'];
      parts.add(cant != null ? '$nombre($cant)' : nombre);
    }
    return parts.join('; ');
  }

  static bool _isNumericColumn(List<Map<String, String>> rows, String key) {
    for (final row in rows) {
      final v = row[key];
      if (v == null || v.isEmpty) continue;
      if (double.tryParse(v) == null) return false;
    }
    return rows.any((r) => (r[key] ?? '').isNotEmpty);
  }

  static int _maxValueLength(List<Map<String, String>> rows, String key) {
    var maxLen = 20;
    for (final row in rows) {
      final len = (row[key] ?? '').length;
      if (len > maxLen) maxLen = len;
    }
    return maxLen;
  }

  static String _truncate(String value, int maxLen) {
    if (value.length <= maxLen) return value;
    return value.substring(0, maxLen);
  }
}

class ShpAttributeField {
  final String sourceKey;
  final String dbfName;
  final String type;
  final int length;
  final int decimals;

  const ShpAttributeField({
    required this.sourceKey,
    required this.dbfName,
    required this.type,
    required this.length,
    this.decimals = 0,
  });
}
