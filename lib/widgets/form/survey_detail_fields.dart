import 'package:flutter/material.dart';
import '../../config/tokens.dart';
import 'int_stepper_field.dart';

/// Contenedor suave para campos que aparecen tras un Sí.
class FollowUpFields extends StatelessWidget {
  const FollowUpFields({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: Insets.sm),
      padding: const EdgeInsets.all(Insets.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: Radii.card,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: Insets.md),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Campo numérico de cantidad con etiqueta e ícono.
class QuantityField extends StatelessWidget {
  const QuantityField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      child: IntStepperField(controller: controller),
    );
  }
}

/// Campo de estado / condición.
class StatusField extends StatelessWidget {
  const StatusField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      child: TextFormField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
        decoration: _inputDecoration(
          context,
          hint: hint ?? 'Bueno, regular, malo…',
          icon: Icons.health_and_safety_outlined,
        ),
      ),
    );
  }
}

/// Campo de observaciones / notas multilínea.
class ObservationsField extends StatelessWidget {
  const ObservationsField({
    super.key,
    required this.controller,
    this.label = 'Observaciones',
    this.hint,
    this.maxLines = 2,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
        decoration: _inputDecoration(
          context,
          hint: hint ?? 'Detalle adicional (opcional)',
          icon: Icons.notes_rounded,
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }
}

/// Par cantidad + estado en infraestructura.
class QuantityStatusRow extends StatelessWidget {
  const QuantityStatusRow({
    super.key,
    required this.quantityController,
    required this.statusController,
    required this.quantityLabel,
    required this.statusLabel,
  });

  final TextEditingController quantityController;
  final TextEditingController statusController;
  final String quantityLabel;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return FollowUpFields(
      children: [
        QuantityField(
          controller: quantityController,
          label: quantityLabel,
        ),
        StatusField(
          controller: statusController,
          label: statusLabel,
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Insets.sm),
        child,
      ],
    );
  }
}

/// Flujo de inventario: total → estado → cantidad en ese estado.
class InventoryItemFields extends StatelessWidget {
  const InventoryItemFields({
    super.key,
    required this.totalController,
    required this.cantEstadoController,
    required this.estado,
    required this.onEstadoChanged,
  });

  final TextEditingController totalController;
  final TextEditingController cantEstadoController;
  final String? estado;
  final void Function(String) onEstadoChanged;

  static const _estados = [
    ('Bueno',   Color(0xFF2E7D32)),
    ('Regular', Color(0xFFE65100)),
    ('Malo',    Color(0xFFC62828)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;
    final selectedColor = estado == null
        ? scheme.primary
        : _estados.firstWhere((e) => e.$1 == estado).$2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Cuántas tienen ──────────────────────────────────────
        _LabeledField(
          label: '¿Cuántas tienen?',
          child: IntStepperField(controller: totalController),
        ),
        const SizedBox(height: Insets.md),

        // ── Selector de estado ──────────────────────────────────
        Text('Estado predominante', style: theme.textTheme.titleSmall?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: Insets.sm),
        Row(
          children: _estados.map((e) {
            final selected = estado == e.$1;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: selected ? e.$2 : scheme.surfaceContainerLowest,
                    foregroundColor: selected ? Colors.white : scheme.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: selected ? e.$2 : scheme.outlineVariant),
                    ),
                  ),
                  onPressed: () => onEstadoChanged(e.$1),
                  child: Text(e.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            );
          }).toList(),
        ),

        // ── Cantidad en ese estado ─────────────────────────────
        if (estado != null) ...[
          const SizedBox(height: Insets.md),
          _LabeledField(
            label: '¿Cuántas en estado $estado?',
            child: IntStepperField(
              controller: cantEstadoController,
              accentColor: selectedColor,
            ),
          ),
        ],
      ],
    );
  }
}

/// Selector de estado Bueno / Regular / Malo (botones de opción única).
class EstadoSelector extends StatelessWidget {
  const EstadoSelector({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final void Function(String) onChanged;

  static const _options = ['Bueno', 'Regular', 'Malo'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: Insets.sm),
        Row(
          children: _options.map((opt) {
            final selected = value == opt;
            final color = switch (opt) {
              'Bueno' => const Color(0xFF2E7D32),
              'Regular' => const Color(0xFFE65100),
              _ => const Color(0xFFC62828),
            };
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: selected ? color : scheme.surfaceContainerLowest,
                    foregroundColor: selected ? Colors.white : scheme.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: selected ? color : scheme.outlineVariant),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => onChanged(opt),
                  child: Text(opt, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

InputDecoration _inputDecoration(
  BuildContext context, {
  String? hint,
  IconData? icon,
  bool alignLabelWithHint = false,
  Color? accentColor,
}) {
  final scheme = Theme.of(context).colorScheme;
  final iconColor = accentColor ?? scheme.onSurfaceVariant;

  return InputDecoration(
    hintText: hint,
    alignLabelWithHint: alignLabelWithHint,
    prefixIcon: icon != null
        ? Icon(icon, size: 20, color: iconColor)
        : null,
    filled: true,
    fillColor: accentColor != null
        ? accentColor.withValues(alpha: 0.06)
        : scheme.surfaceContainerLowest,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: Insets.lg,
      vertical: Insets.md,
    ),
    enabledBorder: accentColor != null
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: accentColor.withValues(alpha: 0.5)),
          )
        : null,
    focusedBorder: accentColor != null
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: accentColor, width: 2),
          )
        : null,
  );
}
