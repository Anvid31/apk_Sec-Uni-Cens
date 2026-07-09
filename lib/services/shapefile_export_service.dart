// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/survey_shapefile_flatten.dart';
import 'postgres_service.dart';

/// Exporta encuestas de caracterización a Shapefile (punto, EPSG:4326).
///
/// Genera un ZIP con: .shp, .shx, .dbf, .prj
/// Atributos: columnas de tabla + JSON del formulario aplanado (sin fotos).
class ShapefileExportService {
  /// Consulta PostgreSQL y exporta todas las sedes con coordenadas.
  static Future<String?> exportFromDatabase({
    String fileName = 'caracterizacion_sedes',
  }) async {
    final rows = await PostgresService.querySurveysForExport();
    if (rows.isEmpty) {
      print('⚠️ ShapefileExportService: no hay registros en la base de datos');
      return null;
    }

    final attributeRows = <Map<String, String>>[];
    final coords = <(double lat, double lon)>[];

    for (final row in rows) {
      final lat = row['latitude'] as double;
      final lon = row['longitude'] as double;
      attributeRows.add(SurveyShapefileFlatten.flattenRow(
        id: row['id'] as String,
        createdAt: row['created_at'] as String,
        formType: row['form_type'] as String,
        institution: row['institution'] as String,
        daneCode: row['dane_code'] as String,
        municipality: row['municipality'] as String,
        department: row['department'] as String,
        latitude: lat,
        longitude: lon,
        data: row['data'] as Map<String, dynamic>,
      ));
      coords.add((lat, lon));
    }

    return _exportZip(attributeRows, coords, fileName);
  }

  static Future<String?> _exportZip(
    List<Map<String, String>> attributeRows,
    List<(double lat, double lon)> coords,
    String fileName,
  ) async {
    try {
      final fields = SurveyShapefileFlatten.buildFieldSchema(attributeRows);
      final zipPath = await _buildZip(
        attributeRows: attributeRows,
        coords: coords,
        fields: fields,
        name: fileName,
      );
      await Share.shareXFiles(
        [XFile(zipPath)],
        subject: 'Shapefile CENS – $fileName',
      );
      return zipPath;
    } catch (e) {
      print('❌ ShapefileExportService: error al exportar: $e');
      rethrow;
    }
  }

  static Future<String> _buildZip({
    required List<Map<String, String>> attributeRows,
    required List<(double lat, double lon)> coords,
    required List<ShpAttributeField> fields,
    required String name,
  }) async {
    final tmpDir = await getTemporaryDirectory();
    final zipPath = '${tmpDir.path}/$name.zip';

    final archive = Archive();
    archive.addFile(ArchiveFile('$name.shp', -1, _buildShp(coords)));
    archive.addFile(
        ArchiveFile('$name.shx', -1, _buildShx(coords.length)));
    archive.addFile(ArchiveFile(
        '$name.dbf', -1, _buildDbf(attributeRows, fields)));
    archive.addFile(ArchiveFile('$name.prj', -1, _prjBytes()));

    final zipBytes = ZipEncoder().encode(archive);
    await File(zipPath).writeAsBytes(zipBytes!);

    print('✅ ShapefileExportService: ZIP generado en $zipPath '
        '(${coords.length} puntos, ${fields.length} atributos)');
    return zipPath;
  }

  static Uint8List _buildShp(List<(double lat, double lon)> coords) {
    const int recordContentLen = 20;
    const int recordTotalLen = 8 + recordContentLen;
    final int fileBytes = 100 + coords.length * recordTotalLen;
    final bd = ByteData(fileBytes);
    int off = 0;

    double xMin = double.infinity,
        xMax = double.negativeInfinity,
        yMin = double.infinity,
        yMax = double.negativeInfinity;
    for (final c in coords) {
      if (c.$2 < xMin) xMin = c.$2;
      if (c.$2 > xMax) xMax = c.$2;
      if (c.$1 < yMin) yMin = c.$1;
      if (c.$1 > yMax) yMax = c.$1;
    }

    bd.setInt32(0, 9994, Endian.big);
    bd.setInt32(24, fileBytes ~/ 2, Endian.big);
    bd.setInt32(28, 1000, Endian.little);
    bd.setInt32(32, 1, Endian.little);
    bd.setFloat64(36, xMin, Endian.little);
    bd.setFloat64(44, yMin, Endian.little);
    bd.setFloat64(52, xMax, Endian.little);
    bd.setFloat64(60, yMax, Endian.little);
    off = 100;

    for (int i = 0; i < coords.length; i++) {
      final c = coords[i];
      bd.setInt32(off, i + 1, Endian.big);
      bd.setInt32(off + 4, recordContentLen ~/ 2, Endian.big);
      off += 8;
      bd.setInt32(off, 1, Endian.little);
      bd.setFloat64(off + 4, c.$2, Endian.little);
      bd.setFloat64(off + 12, c.$1, Endian.little);
      off += recordContentLen;
    }

    return bd.buffer.asUint8List();
  }

  static Uint8List _buildShx(int n) {
    final int fileBytes = 100 + n * 8;
    final bd = ByteData(fileBytes);

    bd.setInt32(0, 9994, Endian.big);
    bd.setInt32(24, fileBytes ~/ 2, Endian.big);
    bd.setInt32(28, 1000, Endian.little);
    bd.setInt32(32, 1, Endian.little);
    int off = 100;

    for (int i = 0; i < n; i++) {
      final offsetWords = 50 + i * 14;
      bd.setInt32(off, offsetWords, Endian.big);
      bd.setInt32(off + 4, 10, Endian.big);
      off += 8;
    }

    return bd.buffer.asUint8List();
  }

  static Uint8List _buildDbf(
    List<Map<String, String>> rows,
    List<ShpAttributeField> fields,
  ) {
    final now = DateTime.now();
    final int numFields = fields.length;
    final int headerSize = 32 + 32 * numFields + 1;
    final int recordSize =
        1 + fields.fold<int>(0, (s, f) => s + f.length);
    final int fileSize = headerSize + rows.length * recordSize + 1;

    final bd = ByteData(fileSize);
    int off = 0;

    bd.setUint8(off++, 0x03);
    bd.setUint8(off++, now.year - 1900);
    bd.setUint8(off++, now.month);
    bd.setUint8(off++, now.day);
    bd.setInt32(off, rows.length, Endian.little);
    off += 4;
    bd.setInt16(off, headerSize, Endian.little);
    off += 2;
    bd.setInt16(off, recordSize, Endian.little);
    off += 2;
    off += 20;

    for (final field in fields) {
      final nameBytes = _padRight(field.dbfName, 11);
      for (int i = 0; i < 11; i++) {
        bd.setUint8(off + i, nameBytes[i]);
      }
      off += 11;
      bd.setUint8(off++, field.type.codeUnitAt(0));
      off += 4;
      bd.setUint8(off++, field.length);
      bd.setUint8(off++, field.decimals);
      off += 14;
    }
    bd.setUint8(off++, 0x0D);

    for (final row in rows) {
      bd.setUint8(off++, 0x20);
      for (final field in fields) {
        final raw = row[field.sourceKey] ?? '';
        final bytes = field.type == 'N'
            ? (field.decimals > 0
                ? _fmtN(double.tryParse(raw) ?? 0, field.length, field.decimals)
                : _fmtNInt(int.tryParse(raw) ?? 0, field.length))
            : _fmtC(raw, field.length);
        for (int b = 0; b < bytes.length; b++) {
          bd.setUint8(off++, bytes[b]);
        }
      }
    }

    bd.setUint8(off, 0x1A);
    return bd.buffer.asUint8List();
  }

  static Uint8List _prjBytes() {
    const wkt = 'GEOGCS["GCS_WGS_1984",'
        'DATUM["D_WGS_1984",'
        'SPHEROID["WGS_1984",6378137.0,298.257223563]],'
        'PRIMEM["Greenwich",0.0],'
        'UNIT["Degree",0.0174532925199433]]';
    return Uint8List.fromList(wkt.codeUnits);
  }

  static List<int> _fmtC(String value, int len) {
    final bytes = _toLatin1(value, len);
    if (bytes.length < len) {
      return [...bytes, ...List.filled(len - bytes.length, 0x20)];
    }
    return bytes.sublist(0, len);
  }

  static List<int> _fmtN(double value, int len, int decimals) {
    return _padLeft(value.toStringAsFixed(decimals), len);
  }

  static List<int> _fmtNInt(int value, int len) {
    return _padLeft(value.toString(), len);
  }

  static List<int> _toLatin1(String s, int maxLen) {
    final result = <int>[];
    for (final cp in s.runes) {
      if (result.length >= maxLen) break;
      result.add(cp <= 0xFF ? cp : 0x3F);
    }
    return result;
  }

  static List<int> _padRight(String s, int len) {
    final bytes = s.codeUnits.take(len).toList();
    while (bytes.length < len) {
      bytes.add(0x00);
    }
    return bytes;
  }

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
