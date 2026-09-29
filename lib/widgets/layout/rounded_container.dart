import 'package:flutter/material.dart';
import '../../config/tokens.dart';

class RoundedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const RoundedContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = borderRadius != null
        ? BorderRadius.circular(borderRadius!)
        : Radii.card;

    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(Insets.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.surfaceContainerLowest,
        borderRadius: radius,
        border: border ?? Border.all(color: scheme.outlineVariant),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
