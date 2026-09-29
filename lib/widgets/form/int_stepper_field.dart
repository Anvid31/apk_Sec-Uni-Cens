import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo numérico con botones − y + embebidos dentro del borde del campo.
class IntStepperField extends StatefulWidget {
  const IntStepperField({
    super.key,
    required this.controller,
    this.accentColor,
    this.onChanged,
    this.hintText = '0',
    this.min = 0,
    this.max = 9999,
  });

  final TextEditingController controller;
  final Color? accentColor;
  /// Se llama tanto al escribir desde teclado como al pulsar los botones.
  final void Function(String)? onChanged;
  final String hintText;
  final int min;
  final int max;

  @override
  State<IntStepperField> createState() => _IntStepperFieldState();
}

class _IntStepperFieldState extends State<IntStepperField> {
  int get _value => int.tryParse(widget.controller.text.trim()) ?? 0;

  void _step(int delta) {
    final next = (_value + delta).clamp(widget.min, widget.max);
    final nextStr = next.toString();
    setState(() {
      widget.controller.text = nextStr;
    });
    widget.onChanged?.call(nextStr);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = widget.accentColor ?? scheme.primary;
    final fill = widget.accentColor != null
        ? widget.accentColor!.withValues(alpha: 0.07)
        : scheme.surfaceContainerLowest;

    final idleBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: widget.accentColor?.withValues(alpha: 0.4) ??
            scheme.outline.withValues(alpha: 0.5),
      ),
    );
    final focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: 2),
    );

    Widget field({Widget? prefix, Widget? suffix}) => TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: color, fontSize: 15),
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: fill,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            prefixIcon: prefix,
            suffixIcon: suffix,
            enabledBorder: idleBorder,
            focusedBorder: focusBorder,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

    Widget button(IconData icon, int delta, String tooltip) => IconButton(
          icon: Icon(icon, size: 20, color: color),
          onPressed: () => _step(delta),
          visualDensity: VisualDensity.compact,
          tooltip: tooltip,
        );

    return LayoutBuilder(builder: (context, constraints) {
      // Cada IconButton ocupa ≥48dp: en celdas angostas (B/R/M) no quedaba
      // espacio para el número. Ahí se ponen los botones debajo del campo.
      if (constraints.maxWidth >= 150) {
        return field(
          prefix: button(Icons.remove_rounded, -1, 'Disminuir'),
          suffix: button(Icons.add_rounded, 1, 'Aumentar'),
        );
      }
      final buttonStyle = OutlinedButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(0, 40),
        padding: EdgeInsets.zero,
        side: BorderSide(color: idleBorder.borderSide.color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
      return Column(
        children: [
          field(),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: 'Disminuir',
                  child: OutlinedButton(
                    style: buttonStyle,
                    onPressed: () => _step(-1),
                    child: const Icon(Icons.remove_rounded, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Tooltip(
                  message: 'Aumentar',
                  child: OutlinedButton(
                    style: buttonStyle,
                    onPressed: () => _step(1),
                    child: const Icon(Icons.add_rounded, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
