import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// Error al obtener la ubicación.
/// [definitive] = true cuando reintentar no servirá (sin señal GPS,
/// permiso denegado permanentemente); la ubicación se marca "No disponible".
class LocationFailure implements Exception {
  final String message;
  final bool definitive;
  const LocationFailure(this.message, {this.definitive = false});

  @override
  String toString() => message;
}

class LocationService {
  static const _timeout = Duration(seconds: 30);

  /// Comprueba y solicita los permisos de ubicación. Lanza [LocationFailure].
  static Future<void> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationFailure(
          'El GPS está desactivado. Actívelo e intente de nuevo.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationFailure(
            'Permiso de ubicación denegado. Concédalo e intente de nuevo.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(
        'Permiso de ubicación denegado permanentemente. '
        'Habilítelo en los ajustes del dispositivo.',
        definitive: true,
      );
    }
  }

  /// Obtiene la ubicación actual del dispositivo. Lanza [LocationFailure].
  /// Si no hay señal en [_timeout], usa la última posición conocida.
  static Future<Position> getCurrentLocation() async {
    await _ensurePermission();
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: _timeout,
        ),
      );
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition()
          .catchError((_) => null);
      if (last != null) return last;
      throw const LocationFailure(
        'El dispositivo no pudo determinar la ubicación.',
        definitive: true,
      );
    }
  }

  /// Formatea una posición en un string de coordenadas
  static String formatCoordinates(Position position) {
    return '${position.latitude}, ${position.longitude}';
  }

  /// Valida un string de coordenadas
  static bool validateCoordinates(String coordinates) {
    try {
      final parts = coordinates.split(',');
      if (parts.length != 2) return false;

      final lat = double.parse(parts[0].trim());
      final lon = double.parse(parts[1].trim());

      return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
    } catch (e) {
      return false;
    }
  }
}
