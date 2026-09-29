import 'package:flutter/material.dart';
import '../../config/tokens.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final String? helperText;
  final int helperMaxLines;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final String? initialValue;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool obscureText;
  final bool enabled;
  final bool? showRequiredIndicator;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.helperText,
    this.helperMaxLines = 4,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.initialValue,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.obscureText = false,
    this.enabled = true,
    this.showRequiredIndicator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final focused = _focusNode.hasFocus;
    if (focused != _isFocused) {
      setState(() => _isFocused = focused);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final focusColor = scheme.primary;
    final iconColor = _isFocused ? focusColor : scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: Insets.xs, bottom: 6),
            child: RichText(
              text: TextSpan(
                text: widget.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _isFocused ? focusColor : scheme.onSurface,
                ),
                children: [
                  // Sin validator propio aplica el de "requerido" (ver abajo).
                  if (widget.showRequiredIndicator ?? widget.validator == null)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: scheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
          TextFormField(
            controller: widget.controller,
            initialValue:
                widget.controller == null ? widget.initialValue : null,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            focusNode: _focusNode,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText:
                  widget.hintText ?? 'Ingrese ${widget.label.toLowerCase()}',
              helperText: widget.helperText,
              helperMaxLines: widget.helperMaxLines,
              helperStyle: theme.textTheme.bodySmall,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: iconColor, size: 22)
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconButton(
                      icon: Icon(widget.suffixIcon, color: iconColor, size: 22),
                      onPressed: widget.onSuffixIconPressed,
                    )
                  : null,
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.prefixIcon != null ? Insets.md : Insets.xl,
                vertical: (widget.maxLines ?? 1) > 1 ? Insets.lg : 14,
              ),
              filled: true,
              fillColor: widget.enabled
                  ? (_isFocused
                      ? scheme.surfaceContainerLowest
                      : scheme.surfaceContainerHighest.withValues(alpha: 0.45))
                  : scheme.surfaceContainer,
            ),
            validator: widget.validator ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
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
