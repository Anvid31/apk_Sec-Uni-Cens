import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/tokens.dart';

/// Botones de navegación para formularios multipaso.
class EnhancedFormNavigationButtons extends StatefulWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String nextLabel;
  final String previousLabel;
  final bool showPrevious;
  final bool isLoading;
  final bool isLastStep;
  final int currentStep;
  final int totalSteps;
  final IconData? nextIcon;
  final IconData? previousIcon;

  const EnhancedFormNavigationButtons({
    super.key,
    this.onPrevious,
    this.onNext,
    this.nextLabel = 'Continuar',
    this.previousLabel = 'Anterior',
    this.showPrevious = true,
    this.isLoading = false,
    this.isLastStep = false,
    this.currentStep = 1,
    this.totalSteps = 4,
    this.nextIcon,
    this.previousIcon,
  });

  @override
  State<EnhancedFormNavigationButtons> createState() =>
      _EnhancedFormNavigationButtonsState();
}

class _EnhancedFormNavigationButtonsState
    extends State<EnhancedFormNavigationButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: Motion.fast,
      vsync: this,
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _pressFeedback(VoidCallback? action) async {
    if (action == null) return;
    HapticFeedback.lightImpact();
    await _buttonController.forward();
    await _buttonController.reverse();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(Insets.xl, Insets.lg, Insets.xl, Insets.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: Radii.sheetSm,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _buttonScale,
          builder: (context, child) {
            return Transform.scale(
              scale: _buttonScale.value,
              child: child,
            );
          },
          child: Row(
            children: [
              if (widget.showPrevious) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onPrevious == null || widget.isLoading
                        ? null
                        : () => _pressFeedback(widget.onPrevious),
                    icon: Icon(
                      widget.previousIcon ?? Icons.arrow_back_ios_new_rounded,
                      size: 16,
                    ),
                    // Botón angosto (flex 1): se reduce en vez de partir la palabra.
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(widget.previousLabel, maxLines: 1),
                    ),
                  ),
                ),
                const SizedBox(width: Insets.lg),
              ],
              Expanded(
                flex: widget.showPrevious ? 2 : 1,
                child: FilledButton.icon(
                  key: const ValueKey('btn_next'),
                  onPressed: widget.onNext == null || widget.isLoading
                      ? null
                      : () => _pressFeedback(widget.onNext),
                  icon: widget.isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.onPrimary,
                          ),
                        )
                      : Icon(
                          widget.nextIcon ??
                              (widget.isLastStep
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_ios_rounded),
                          size: 16,
                        ),
                  label: Text(
                    widget.isLoading ? 'Procesando...' : widget.nextLabel,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Versión simplificada para casos específicos.
class QuickFormButtons extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final String nextLabel;
  final bool showPrevious;
  final bool isLoading;

  const QuickFormButtons({
    super.key,
    this.onNext,
    this.onPrevious,
    this.nextLabel = 'Continuar',
    this.showPrevious = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Insets.lg),
      child: Row(
        children: [
          if (showPrevious) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPrevious,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                label: const Text('Anterior'),
              ),
            ),
            const SizedBox(width: Insets.lg),
          ],
          Expanded(
            flex: showPrevious ? 2 : 1,
            child: FilledButton.icon(
              onPressed: isLoading ? null : onNext,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              label: Text(isLoading ? 'Procesando...' : nextLabel),
            ),
          ),
        ],
      ),
    );
  }
}
