import 'package:geolocator/geolocator.dart';

class LocationService {  /// Comprueba y solicita los permisos de ubicación
  static Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Los servicios de ubicación están deshabilitados');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Los permisos de ubicación fueron denegados');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Los permisos de ubicación están permanentemente denegados');
      return false;
    }

    print('Permisos de ubicación concedidos');
    return true;
  }

  /// Obtiene la ubicación actual del dispositivo
  static Future<Position?> getCurrentLocation() async {
    if (!await _handleLocationPermission()) {
      return null;
    }    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
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
