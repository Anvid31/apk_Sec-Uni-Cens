import 'package:flutter/material.dart';
import '../../services/location_service.dart';


class LocationField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final void Function(String) onChanged;

  const LocationField({
    super.key,
    required this.label,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<LocationField> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        final coordinates = LocationService.formatCoordinates(position);
        _controller.text = coordinates;
        widget.onChanged(coordinates);
        setState(() {
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'No se pudo obtener la ubicación. Verifique que el GPS esté activado y que haya concedido permisos de ubicación.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al obtener la ubicación: $e. Por favor, ingrese las coordenadas manualmente.';
      });
      print('Error detallado de ubicación: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: RichText(
              text: TextSpan(
                text: widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF424242),
                  fontFamily: 'Roboto',
                ),
                children: const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.my_location, color: Color(0xFF4CAF50)),
                      onPressed: _getCurrentLocation,
                    ),
              helperText: 'Formato: latitud, longitud (ej: 12.345678, -98.765432)',
              errorText: _errorMessage,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es requerido';
              }

              final parts = value.split(',');
              if (parts.length != 2) {
                return 'Formato inválido. Use: latitud, longitud';
              }

              try {
                final lat = double.parse(parts[0].trim());
                final lon = double.parse(parts[1].trim());

                if (lat < -90 || lat > 90) {
                  return 'Latitud debe estar entre -90 y 90';
                }
                if (lon < -180 || lon > 180) {
                  return 'Longitud debe estar entre -180 y 180';
                }
              } catch (e) {
                return 'Las coordenadas deben ser números válidos';
              }

              return null;
            },
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
