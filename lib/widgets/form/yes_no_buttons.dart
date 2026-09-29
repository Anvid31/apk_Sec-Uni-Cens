import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/tokens.dart';

/// Par de botones Sí / No con estilo segmentado (targets ≥ 48dp).
class YesNoButtons extends StatelessWidget {
  const YesNoButtons({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool? value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: Insets.sm),
          Row(
            children: [
              Expanded(
                child: _YesNoOption(
                  label: 'Sí',
                  icon: Icons.check_rounded,
                  selected: value == true,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(true);
                  },
                ),
              ),
              const SizedBox(width: Insets.sm),
              Expanded(
                child: _YesNoOption(
                  label: 'No',
                  icon: Icons.close_rounded,
                  selected: value == false,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(false);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _YesNoOption extends StatelessWidget {
  const _YesNoOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final bg = selected
        ? scheme.primary
        : scheme.surfaceContainerLowest;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    final border = selected
        ? scheme.primary
        : scheme.outlineVariant;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.card,
        side: BorderSide(color: border, width: selected ? 1.5 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.card,
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.md,
            vertical: Insets.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: Insets.sm),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
