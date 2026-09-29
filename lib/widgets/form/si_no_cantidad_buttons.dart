import 'package:flutter/material.dart';
import '../../config/tokens.dart';
import 'int_stepper_field.dart';
import 'yes_no_buttons.dart';

/// Electrodoméstico: Sí / No y, si es Sí, cantidad debajo.
///
/// Persistencia compatible: `'si'` | `'no'` | `'numero'` (cuando hay cantidad).
class SiNoCantidadButtons extends StatelessWidget {
  const SiNoCantidadButtons({
    super.key,
    required this.label,
    required this.value,
    required this.cantidadController,
    required this.onChanged,
  });

  final String label;
  /// `'si' | 'no' | 'numero' | null`
  final String? value;
  final TextEditingController cantidadController;
  final ValueChanged<String> onChanged;

  bool? get _yesNo {
    if (value == 'si' || value == 'numero') return true;
    if (value == 'no') return false;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showCantidad = _yesNo == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YesNoButtons(
            label: label,
            value: _yesNo,
            onChanged: (yes) {
              if (yes) {
                onChanged(
                  cantidadController.text.trim().isNotEmpty ? 'numero' : 'si',
                );
              } else {
                cantidadController.clear();
                onChanged('no');
              }
            },
          ),
          if (showCantidad) ...[
            const SizedBox(height: Insets.sm),
            Text(
              'Cantidad',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Insets.sm),
            IntStepperField(
              controller: cantidadController,
              hintText: 'Opcional',
              onChanged: (text) {
                onChanged(text.trim().isNotEmpty ? 'numero' : 'si');
              },
            ),
          ],
        ],
      ),
    );
  }
}
