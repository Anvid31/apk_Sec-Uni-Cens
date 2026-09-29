import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageHelper {
  /// Procesa una imagen local para subirla a Storage:
  /// redimensiona a máx. 1024px de ancho y comprime a JPG calidad 70%.
  /// Corre en un isolate para no congelar la UI.
  /// Retorna null si el archivo no existe o no es una imagen.
  static Future<Uint8List?> compressForUpload(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();

    return Isolate.run(() {
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      final resized =
          image.width > 1024 ? img.copyResize(image, width: 1024) : image;
      return img.encodeJpg(resized, quality: 70);
    });
  }
}
