// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/survey_state.dart';
import 'postgres_service.dart';

/// Exporta una lista de encuestas de caracterización a formato Shapefile
/// (ESRI Shapefile — punto simple, EPSG:4326).
///
/// Genera un archivo ZIP que contiene:
///   nombre.shp  — geometría de puntos
///   nombre.shx  — índice de offsets
///   nombre.dbf  — tabla de atributos (dBASE III+)
///   nombre.prj  — proyección WGS-84
///
/// Atributos exportados:
///   NOMBRE (C/100), DANE (C/20), MUNICIPIO (C/50), DPTO (C/50),
///   RECTOR (C/80), LATITUD (N/18,10), LONGITUD (N/18,10),
///   FECHA (C/20), ESTUDIANT (N/10,0), DOCENTES (N/10,0),
///   SERVICIO_E (C/10), VIA_ACCESO (C/50)
class ShapefileExportService {
  // ─── Punto de entrada público ─────────────────────────────────────────────

  /// Crea y comparte un ZIP con los 4 archivos SHP a partir de [surveys].
  ///
  /// Filtra automáticamente las encuestas sin coordenadas válidas.
  /// Retorna la ruta del ZIP generado (o null si no hay registros válidos).
  static Future<String?> exportAndShare(
    List<SurveyState> surveys, {
    String fileName = 'caracterizacion_sedes',
  }) async {
    final records = _toRecords(surveys);
    if (records.isEmpty) {
      print('⚠️ ShapefileExportService: ningún registro con coordenadas válidas');
      return null;
    }

    try {
      final zipPath = await _buildZip(records, fileName);
      await Share.shareXFiles(
        [XFile(zipPath)],
        subject: 'Shapefile – $fileName',
      );
      return zipPath;
    } catch (e) {
      print('❌ ShapefileExportService: error al exportar: $e');
      rethrow;
    }
  }

  /// Consulta PostgreSQL y exporta todas las sedes con coordenadas como Shapefile.
  ///
  /// Retorna la ruta del ZIP generado (o null si la base de datos está vacía).
  static Future<String?> exportFromDatabase({
    String fileName = 'caracterizacion_sedes',
  }) async {
    final rows = await PostgresService.querySurveysForExport();
    if (rows.isEmpty) {
      print('⚠️ ShapefileExportService: no hay registros en la base de datos');
      return null;
    }

    final records = rows.map((r) => _ShpRecord(
      lat: r['latitude'] as double,
      lon: r['longitude'] as double,
      nombre: r['institution'] as String,
      dane: r['dane_code'] as String,
      municipio: r['municipality'] as String,
      dpto: r['department'] as String,
      rector: r['principal_name'] as String,
      fecha: (r['survey_date'] as String).length >= 10
          ? (r['survey_date'] as String).substring(0, 10)
          : (r['survey_date'] as String),
      estudiantes: r['total_students'] as int,
      docentes: r['teachers_count'] as int,
      servicioE: (r['has_electricity'] as bool) ? 'Si' : 'No',
      viaAcceso: r['access_route'] as String,
    )).toList();

    try {
      final zipPath = await _buildZip(records, fileName);
      await Share.shareXFiles(
        [XFile(zipPath)],
        subject: 'Shapefile CENS – $fileName',
      );
      return zipPath;
    } catch (e) {
      print('❌ ShapefileExportService: error al exportar desde BD: $e');
      rethrow;
    }
  }

  // ─── Conversión de modelos a registros planos ──────────────────────────────

  static List<_ShpRecord> _toRecords(List<SurveyState> surveys) {
    final result = <_ShpRecord>[];
    for (final s in surveys) {
      final coords = _parseCoords(s.institutionalInfo.locationCoordinates);
      if (coords == null) continue; // descartamos sin coords

      result.add(_ShpRecord(
        lat: coords.$1,
        lon: coords.$2,
        nombre: s.institutionalInfo.institutionName ?? '',
        dane: s.institutionalInfo.dane ?? '',
        municipio: s.generalInfo.municipality ?? '',
        dpto: s.generalInfo.department ?? '',
        rector: s.institutionalInfo.principalName ?? '',
        fecha: s.generalInfo.date?.toIso8601String().substring(0, 10) ?? '',
        estudiantes: s.coverageInfo.totalStudents ?? 0,
        docentes: s.coverageInfo.teachersCount ?? 0,
        servicioE: (s.electricityInfo.hasElectricService ?? false) ? 'Si' : 'No',
        viaAcceso: s.accessRouteInfo.principalRoute ?? '',
      ));
    }
    return result;
  }

  /// Parsea "lat,lon" o "lat, lon". Retorna null si no es válido.
  static (double lat, double lon)? _parseCoords(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.split(',');
    if (parts.length < 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lon = double.tryParse(parts[1].trim());
    if (lat == null || lon == null) return null;
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) return null;
    return (lat, lon);
  }

  // ─── Construcción del ZIP ─────────────────────────────────────────────────

  static Future<String> _buildZip(
    List<_ShpRecord> records,
    String name,
  ) async {
    final tmpDir = await getTemporaryDirectory();
    final zipPath = '${tmpDir.path}/$name.zip';

    final archive = Archive();

    archive.addFile(
        ArchiveFile('$name.shp', -1, _buildShp(records)));
    archive.addFile(
        ArchiveFile('$name.shx', -1, _buildShx(records.length)));
    archive.addFile(
        ArchiveFile('$name.dbf', -1, _buildDbf(records)));
    archive.addFile(
        ArchiveFile('$name.prj', -1, _prjBytes()));

    final zipBytes = ZipEncoder().encode(archive);
    await File(zipPath).writeAsBytes(zipBytes!);

    print('✅ ShapefileExportService: ZIP generado en $zipPath');
    return zipPath;
  }

  // ─── .SHP ─────────────────────────────────────────────────────────────────

  static Uint8List _buildShp(List<_ShpRecord> records) {
    const int recordContentLen = 20; // 4 (type) + 8 (X) + 8 (Y)
    const int recordTotalLen = 8 + recordContentLen; // header + content
    final int fileBytes = 100 + records.length * recordTotalLen;
    final bd = ByteData(fileBytes);
    int off = 0;

    // ── Bounding box ──────────────────────────────────────────────────────
    double xMin = double.infinity,
        xMax = double.negativeInfinity,
        yMin = double.infinity,
        yMax = double.negativeInfinity;
    for (final r in records) {
      if (r.lon < xMin) xMin = r.lon;
      if (r.lon > xMax) xMax = r.lon;
      if (r.lat < yMin) yMin = r.lat;
      if (r.lat > yMax) yMax = r.lat;
    }

    // ── File header (100 bytes) ───────────────────────────────────────────
    bd.setInt32(0, 9994, Endian.big); // file code
    // bytes 4-23: unused (zeros)
    bd.setInt32(24, fileBytes ~/ 2, Endian.big); // file length (words)
    bd.setInt32(28, 1000, Endian.little); // version
    bd.setInt32(32, 1, Endian.little); // shape type = Point
    bd.setFloat64(36, xMin, Endian.little); // Xmin
    bd.setFloat64(44, yMin, Endian.little); // Ymin
    bd.setFloat64(52, xMax, Endian.little); // Xmax
    bd.setFloat64(60, yMax, Endian.little); // Ymax
    // Z and M ranges: bytes 68-99 remain 0
    off = 100;

    // ── Records ───────────────────────────────────────────────────────────
    for (int i = 0; i < records.length; i++) {
      final r = records[i];
      // Record header
      bd.setInt32(off, i + 1, Endian.big); // record number (1-based)
      bd.setInt32(off + 4, recordContentLen ~/ 2, Endian.big); // content length (words)
      off += 8;
      // Record content
      bd.setInt32(off, 1, Endian.little); // shape type = Point
      bd.setFloat64(off + 4, r.lon, Endian.little); // X = longitude
      bd.setFloat64(off + 12, r.lat, Endian.little); // Y = latitude
      off += recordContentLen;
    }

    return bd.buffer.asUint8List();
  }

  // ─── .SHX ─────────────────────────────────────────────────────────────────

  static Uint8List _buildShx(int n) {
    final int fileBytes = 100 + n * 8;
    final bd = ByteData(fileBytes);

    // File header
    bd.setInt32(0, 9994, Endian.big);
    bd.setInt32(24, fileBytes ~/ 2, Endian.big);
    bd.setInt32(28, 1000, Endian.little);
    bd.setInt32(32, 1, Endian.little); // shape type = Point
    // bbox and Z/M ranges = 0 (already initialized)
    int off = 100;

    for (int i = 0; i < n; i++) {
      // Offset of SHP record header in 16-bit words:
      //   100 bytes header / 2 = 50 words
      //   each SHP record = 28 bytes = 14 words
      final offsetWords = 50 + i * 14;
      bd.setInt32(off, offsetWords, Endian.big);
      bd.setInt32(off + 4, 10, Endian.big); // content length = 10 words (20 bytes)
      off += 8;
    }

    return bd.buffer.asUint8List();
  }

  // ─── .DBF ─────────────────────────────────────────────────────────────────

  static final List<_DbfField> _fields = [
    _DbfField('NOMBRE', 'C', 100),
    _DbfField('DANE', 'C', 20),
    _DbfField('MUNICIPIO', 'C', 50),
    _DbfField('DPTO', 'C', 50),
    _DbfField('RECTOR', 'C', 80),
    _DbfField('LATITUD', 'N', 18, decimals: 10),
    _DbfField('LONGITUD', 'N', 18, decimals: 10),
    _DbfField('FECHA', 'C', 20),
    _DbfField('ESTUDIANT', 'N', 10),
    _DbfField('DOCENTES', 'N', 10),
    _DbfField('SERVICIO_E', 'C', 10),
    _DbfField('VIA_ACCESO', 'C', 50),
  ];

  static Uint8List _buildDbf(List<_ShpRecord> records) {
    final now = DateTime.now();
    final int numFields = _fields.length;
    final int headerSize = 32 + 32 * numFields + 1; // +1 for terminator 0x0D
    final int recordSize = 1 + _fields.fold<int>(0, (s, f) => s + f.length);
    final int fileSize = headerSize + records.length * recordSize + 1; // +1 for EOF 0x1A

    final bd = ByteData(fileSize);
    int off = 0;

    // ── DBF header ────────────────────────────────────────────────────────
    bd.setUint8(off++, 0x03); // version
    bd.setUint8(off++, now.year - 1900); // YY
    bd.setUint8(off++, now.month); // MM
    bd.setUint8(off++, now.day); // DD
    bd.setInt32(off, records.length, Endian.little); off += 4; // num records
    bd.setInt16(off, headerSize, Endian.little); off += 2; // header size
    bd.setInt16(off, recordSize, Endian.little); off += 2; // record size
    off += 20; // reserved

    // ── Field descriptors ────────────────────────────────────────────────
    for (final field in _fields) {
      final nameBytes = _padRight(field.name, 11); // null-padded to 11 bytes
      for (int i = 0; i < 11; i++) {
        bd.setUint8(off + i, nameBytes[i]);
      }
      off += 11;
      bd.setUint8(off++, field.type.codeUnitAt(0)); // field type
      off += 4; // reserved
      bd.setUint8(off++, field.length); // field length
      bd.setUint8(off++, field.decimals); // decimal count
      off += 14; // reserved
    }
    bd.setUint8(off++, 0x0D); // header terminator

    // ── Records ───────────────────────────────────────────────────────────
    for (final r in records) {
      bd.setUint8(off++, 0x20); // deletion flag (space = not deleted)

      final values = [
        _fmtC(r.nombre, 100),
        _fmtC(r.dane, 20),
        _fmtC(r.municipio, 50),
        _fmtC(r.dpto, 50),
        _fmtC(r.rector, 80),
        _fmtN(r.lat, 18, 10),
        _fmtN(r.lon, 18, 10),
        _fmtC(r.fecha, 20),
        _fmtNInt(r.estudiantes, 10),
        _fmtNInt(r.docentes, 10),
        _fmtC(r.servicioE, 10),
        _fmtC(r.viaAcceso, 50),
      ];

      for (int fi = 0; fi < _fields.length; fi++) {
        final bytes = values[fi];
        for (int b = 0; b < bytes.length; b++) {
          bd.setUint8(off++, bytes[b]);
        }
      }
    }

    bd.setUint8(off, 0x1A); // EOF marker
    return bd.buffer.asUint8List();
  }

  // ─── .PRJ ─────────────────────────────────────────────────────────────────

  static Uint8List _prjBytes() {
    const wkt = 'GEOGCS["GCS_WGS_1984",'
        'DATUM["D_WGS_1984",'
        'SPHEROID["WGS_1984",6378137.0,298.257223563]],'
        'PRIMEM["Greenwich",0.0],'
        'UNIT["Degree",0.0174532925199433]]';
    return Uint8List.fromList(wkt.codeUnits);
  }

  // ─── Formateadores de campos DBF ──────────────────────────────────────────

  /// Campo Character: truncado/rellenado a [len] bytes, encoding Latin-1.
  static List<int> _fmtC(String value, int len) {
    final bytes = _toLatin1(value, len);
    // Rellenar con espacios hasta len
    if (bytes.length < len) {
      return [...bytes, ...List.filled(len - bytes.length, 0x20)];
    }
    return bytes.sublist(0, len);
  }

  /// Campo Numeric (decimal): string ASCII alineada a la derecha en [len] bytes.
  static List<int> _fmtN(double value, int len, int decimals) {
    final s = value.toStringAsFixed(decimals);
    return _padLeft(s, len);
  }

  /// Campo Numeric (entero): string ASCII alineada a la derecha en [len] bytes.
  static List<int> _fmtNInt(int value, int len) {
    final s = value.toString();
    return _padLeft(s, len);
  }

  /// Convierte String a bytes Latin-1 (ISO-8859-1), truncando a [maxLen].
  static List<int> _toLatin1(String s, int maxLen) {
    final result = <int>[];
    for (final cp in s.runes) {
      if (result.length >= maxLen) break;
      result.add(cp <= 0xFF ? cp : 0x3F); // '?' para caracteres fuera de Latin-1
    }
    return result;
  }

  /// Nombre de campo DBF: null-padded a exactamente [len] bytes.
  static List<int> _padRight(String s, int len) {
    final bytes = s.codeUnits.take(len).toList();
    while (bytes.length < len) {
      bytes.add(0x00);
    }
    return bytes;
  }

  /// Valor numérico: space-padded a la izquierda hasta [len] bytes.
  static List<int> _padLeft(String s, int len) {
    final bytes = s.codeUnits.take(len).toList();
    final padded = List<int>.filled(len, 0x20);
    final start = len - bytes.length;
    for (int i = 0; i < bytes.length; i++) {
      padded[start + i] = bytes[i];
    }
    return padded;
  }
}

// ─── Clases auxiliares ────────────────────────────────────────────────────────

class _ShpRecord {
  final double lat;
  final double lon;
  final String nombre;
  final String dane;
  final String municipio;
  final String dpto;
  final String rector;
  final String fecha;
  final int estudiantes;
  final int docentes;
  final String servicioE;
  final String viaAcceso;

  const _ShpRecord({
    required this.lat,
    required this.lon,
    required this.nombre,
    required this.dane,
    required this.municipio,
    required this.dpto,
    required this.rector,
    required this.fecha,
    required this.estudiantes,
    required this.docentes,
    required this.servicioE,
    required this.viaAcceso,
  });
}

class _DbfField {
  final String name;
  final String type; // 'C' | 'N'
  final int length;
  final int decimals;

  const _DbfField(this.name, this.type, this.length, {this.decimals = 0});
}
