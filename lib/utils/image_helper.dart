import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;

class ImageHelper {
  /// Procesa una imagen local:
  /// 1. Lee el archivo
  /// 2. Lo redimensiona a un máximo de 1024px de ancho (mantiene aspect ratio)
  /// 3. Lo comprime a JPG con calidad 70%
  /// 4. Retorna la cadena Base64
  static Future<String?> processImageForDb(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;

      // Leer bytes del archivo
      final bytes = await file.readAsBytes();
      
      // Decodificar imagen
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // Redimensionar si es muy grande (ej. fotos de cámara de 12MP)
      // Usamos 1024px que es suficiente para ver en pantalla y web
      img.Image resized = image;
      if (image.width > 1024) {
        resized = img.copyResize(image, width: 1024);
      }

      // Comprimir a JPG (reduce significativamente el tamaño vs PNG o Raw)
      final jpgBytes = img.encodeJpg(resized, quality: 70);

      // Retornar Base64
      return base64Encode(jpgBytes);
    } catch (e) {
      print('Error procesando imagen $path: $e');
      return null;
    }
  }
}
