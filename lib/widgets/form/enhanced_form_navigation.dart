import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Botones de navegación mejorados para formularios
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
    with TickerProviderStateMixin {
  
  late AnimationController _buttonController;
  late AnimationController _progressController;
  late Animation<double> _buttonScale;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonScale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Animar la aparición del widget
    _progressController.forward();
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _onNextPressed() async {
    if (widget.isLoading || widget.onNext == null) return;
    
    // Feedback háptico
    HapticFeedback.mediumImpact();
    
    // Animación del botón
    await _buttonController.forward();
    _buttonController.reverse();
    
    // Ejecutar callback
    widget.onNext!();
  }

  void _onPreviousPressed() async {
    if (widget.isLoading || widget.onPrevious == null) return;
    
    // Feedback háptico
    HapticFeedback.lightImpact();
    
    // Animación del botón
    await _buttonController.forward();
    _buttonController.reverse();
    
    // Ejecutar callback
    widget.onPrevious!();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _progressAnimation.value)),
          child: Opacity(
            opacity: _progressAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,                child: Row(
                  children: [
                    // Botón anterior
                    if (widget.showPrevious) ...[
                      Expanded(
                        flex: 1,
                        child: _buildPreviousButton(),
                      ),
                      const SizedBox(width: 16),
                    ],
                    
                    // Botón siguiente
                    Expanded(
                      flex: widget.showPrevious ? 2 : 1,
                      child: _buildNextButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildPreviousButton() {
    return AnimatedBuilder(
      animation: _buttonScale,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.onPrevious != null ? _buttonScale.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPrevious != null ? _onPreviousPressed : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.previousIcon ?? Icons.arrow_back_ios,
                        color: widget.onPrevious != null
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade400,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.previousLabel,
                        style: TextStyle(
                          color: widget.onPrevious != null
                              ? const Color(0xFF4CAF50)
                              : Colors.grey.shade400,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextButton() {
    final isEnabled = widget.onNext != null && !widget.isLoading;
    
    return AnimatedBuilder(
      animation: _buttonScale,
      builder: (context, child) {
        return Transform.scale(
          scale: isEnabled ? _buttonScale.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isEnabled
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF4CAF50),
                        Color(0xFF45A049),
                      ],
                    )
                  : null,
              color: isEnabled ? null : Colors.grey.shade300,
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isEnabled ? _onNextPressed : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading) ...[
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isEnabled ? Colors.white : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      
                      Text(
                        widget.isLoading 
                            ? 'Procesando...'
                            : widget.nextLabel,
                        style: TextStyle(
                          color: isEnabled ? Colors.white : Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      if (!widget.isLoading) ...[
                        const SizedBox(width: 8),
                        Icon(
                          widget.nextIcon ?? 
                          (widget.isLastStep 
                              ? Icons.check 
                              : Icons.arrow_forward_ios),
                          color: isEnabled ? Colors.white : Colors.grey.shade600,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Versión simplificada para casos específicos
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (showPrevious) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPrevious,
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                label: const Text('Anterior'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF4CAF50)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          
          Expanded(
            flex: showPrevious ? 2 : 1,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onNext,
              icon: isLoading 
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.arrow_forward_ios, size: 18),
              label: Text(isLoading ? 'Procesando...' : nextLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
