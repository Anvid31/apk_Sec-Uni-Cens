import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../form/enhanced_form_navigation.dart';
import '../../utils/form_navigator.dart';

/// Container mejorado para formularios con transiciones fluidas
class EnhancedFormContainer extends StatefulWidget {
  final String title;
  final String? subtitle;
  final int currentStep;
  final int totalSteps;
  final Widget child;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool showPrevious;
  final bool isLoading;
  final bool isLastStep;
  final List<Widget>? headerActions;
  final Color? primaryColor;
  final FormTransitionType transitionType;
  final Widget? floatingActionButton;
  final bool customScrolling;
  final bool showProgressBar;
  final bool showNavigationButtons;
  final bool showDragHandle;
  final EdgeInsets? contentPadding;

  const EnhancedFormContainer({
    super.key,
    required this.title,
    this.subtitle,
    required this.currentStep,
    this.totalSteps = 9,
    required this.child,
    this.onPrevious,
    this.onNext,
    this.nextLabel = 'Continuar',
    this.showPrevious = true,
    this.isLoading = false,
    this.isLastStep = false,
    this.headerActions,
    this.primaryColor,
    this.transitionType = FormTransitionType.slideScale,
    this.floatingActionButton,
    this.customScrolling = false,
    this.showProgressBar = true,
    this.showNavigationButtons = true,
    this.showDragHandle = true,
    this.contentPadding,
  });

  @override
  State<EnhancedFormContainer> createState() => _EnhancedFormContainerState();
}

class _EnhancedFormContainerState extends State<EnhancedFormContainer>
    with TickerProviderStateMixin {
  
  late AnimationController _headerController;
  late AnimationController _contentController;
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;
  late Animation<Offset> _contentSlideAnimation;

  @override
  void initState() {
    super.initState();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    // Iniciar animaciones
    _startAnimations();
  }

  void _startAnimations() async {
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _contentController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Color get _primaryColor => widget.primaryColor ?? const Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header animado mejorado
          _buildAnimatedHeader(),
          
          // Contenido principal
          Expanded(
            child: _buildAnimatedContent(),
          ),
        ],
      ),
      
      // Botones de navegación mejorados
      bottomNavigationBar: widget.showNavigationButtons ? EnhancedFormNavigationButtons(
        onPrevious: widget.onPrevious,
        onNext: widget.onNext,
        nextLabel: widget.nextLabel,
        showPrevious: widget.showPrevious,
        isLoading: widget.isLoading,
        isLastStep: widget.isLastStep,
        currentStep: widget.currentStep,
        totalSteps: widget.totalSteps,
      ) : null,
      
      // FloatingActionButton opcional
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Widget _buildAnimatedHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _primaryColor,
                    _primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Header principal
                      Row(
                        children: [
                          // Botón de retroceso con animación
                          if (widget.showPrevious)
                            _buildAnimatedBackButton()
                          else
                            const SizedBox(width: 40),
                          
                          // Título y subtítulo
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (widget.subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.subtitle!,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  'Paso ${widget.currentStep} de ${widget.totalSteps}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Acciones del header
                          SizedBox(
                            width: 40,
                            child: widget.headerActions != null
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: widget.headerActions!,
                                  )
                                : null,
                          ),
                        ],
                      ),
                      
                      if (widget.showProgressBar) ...[
                        const SizedBox(height: 24),
                        
                        // Barra de progreso mejorada
                        _buildEnhancedProgressBar(),
                        
                        const SizedBox(height: 16),
                        
                        // Indicadores de paso
                        _buildStepIndicators(),
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

  Widget _buildAnimatedBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            FormNavigator.popForm(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedProgressBar() {
    final progress = widget.currentStep / widget.totalSteps;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOutCubic,
                width: MediaQuery.of(context).size.width * progress,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.totalSteps.clamp(0, 9), // Máximo 9 indicadores
        (index) {
          final stepNumber = index + 1;
          final isCompleted = stepNumber < widget.currentStep;
          final isCurrent = stepNumber == widget.currentStep;
          
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutBack,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isCurrent ? 16 : (isCompleted ? 12 : 8),
            height: isCurrent ? 16 : (isCompleted ? 12 : 8),
            decoration: BoxDecoration(
              color: isCompleted || isCurrent 
                  ? Colors.white 
                  : Colors.white.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              boxShadow: isCurrent ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.6),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              ] : [],
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    color: Color(0xFF4CAF50),
                    size: 8,
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildAnimatedContent() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _contentSlideAnimation,
          child: FadeTransition(
            opacity: _contentAnimation,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    offset: Offset(0, -8),
                    blurRadius: 32,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                child: Column(
                  children: [
                    // Indicador visual de drag
                    if (widget.showDragHandle)
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Contenido
                    Expanded(
                      child: widget.customScrolling
                          ? Padding(
                              padding: widget.contentPadding ?? const EdgeInsets.fromLTRB(24, 16, 24, 0),
                              child: widget.child,
                            )
                          : SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              padding: widget.contentPadding ?? const EdgeInsets.fromLTRB(24, 16, 24, 0),
                              child: widget.child,
                            ),
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
}
