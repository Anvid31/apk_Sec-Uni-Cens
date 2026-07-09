import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dirección de la transición entre formularios
enum FormTransitionDirection {
  forward,
  backward,
}

/// Tipo de transición visual
enum FormTransitionType {
  slide,
  slideScale,
  fadeSlide,
  layered,
}

/// Navegador personalizado para formularios con transiciones mejoradas
class FormNavigator {
  /// Navega al siguiente formulario con animación de avance
  static Future<T?> pushForm<T extends Object?>(
    BuildContext context,
    Widget page, {
    FormTransitionType type = FormTransitionType.slideScale,
    int stepNumber = 1,
  }) {
    return Navigator.push<T>(
      context,
      _createTransition(
        page, 
        FormTransitionDirection.forward, 
        type,
        stepNumber,
      ),
    );
  }

  /// Navega al siguiente formulario reemplazando el actual
  static Future<T?> pushReplacementForm<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page, {
    FormTransitionType type = FormTransitionType.slideScale,
    int stepNumber = 1,
  }) {
    return Navigator.pushReplacement<T, TO>(
      context,
      _createTransition(
        page, 
        FormTransitionDirection.forward, 
        type,
        stepNumber,
      ),
    );
  }

  /// Regresa al formulario anterior con animación de retroceso
  static void popForm<T extends Object?>(
    BuildContext context, [
    T? result,
    FormTransitionType type = FormTransitionType.slideScale,
  ]) {
    HapticFeedback.lightImpact();
    Navigator.pop<T>(context, result);
  }

  /// Navega usando rutas nombradas con transiciones mejoradas
  static Future<T?> pushNamedForm<T extends Object?>(
    BuildContext context,
    String routeName, {
    FormTransitionType type = FormTransitionType.slideScale,
    Object? arguments,
    int stepNumber = 1,
  }) {
    // Crear la página basada en la ruta
    Widget page = _getPageFromRoute(routeName);
    
    return Navigator.push<T>(
      context,
      _createTransition(
        page, 
        FormTransitionDirection.forward, 
        type,
        stepNumber,
      ),
    );
  }

  /// Crea la transición apropiada según el tipo especificado
  static PageRoute<T> _createTransition<T>(
    Widget page,
    FormTransitionDirection direction,
    FormTransitionType type,
    int stepNumber,
  ) {
    switch (type) {
      case FormTransitionType.slide:
        return FormSlideTransition<T>(
          page: page,
          direction: direction,
          stepNumber: stepNumber,
        );
      case FormTransitionType.slideScale:
        return FormSlideScaleTransition<T>(
          page: page,
          direction: direction,
          stepNumber: stepNumber,
        );
      case FormTransitionType.fadeSlide:
        return FormFadeSlideTransition<T>(
          page: page,
          direction: direction,
          stepNumber: stepNumber,
        );
      case FormTransitionType.layered:
        return FormLayeredTransition<T>(
          page: page,
          direction: direction,
          stepNumber: stepNumber,
        );
    }
  }
  /// Obtiene la página correspondiente a una ruta nombrada
  static Widget _getPageFromRoute(String routeName) {
    // Este es un placeholder - en una implementación real necesitarías
    // importar las páginas específicas o usar un registro de rutas
    return const Center(
      child: Text('Página no encontrada'),
    );
  }
}

/// Transición deslizante suave para formularios
class FormSlideTransition<T> extends PageRouteBuilder<T> {
  final Widget page;
  final FormTransitionDirection direction;
  final int stepNumber;

  FormSlideTransition({
    required this.page,
    required this.direction,
    this.stepNumber = 1,
  }) : super(
          transitionDuration: const Duration(milliseconds: 450),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (context, animation, secondaryAnimation) => page,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const curve = Curves.easeInOutCubic;
    
    // Dirección de deslizamiento
    final slideOffset = direction == FormTransitionDirection.forward
        ? const Offset(1.0, 0.0)  // Desde la derecha
        : const Offset(-1.0, 0.0); // Hacia la izquierda

    final slideAnimation = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    // Animación de la página anterior (saliente)
    final exitSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: direction == FormTransitionDirection.forward
          ? const Offset(-0.3, 0.0)  // Sale hacia la izquierda
          : const Offset(1.0, 0.0),  // Sale hacia la derecha
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: curve,
    ));

    return Stack(
      children: [
        // Página anterior (saliente)
        SlideTransition(
          position: exitSlideAnimation,
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(parent: secondaryAnimation, curve: curve),
            ),
            child: Container(),
          ),
        ),
        // Página nueva (entrante)
        SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      ],
    );
  }
}

/// Transición con deslizamiento y escala combinados
class FormSlideScaleTransition<T> extends PageRouteBuilder<T> {
  final Widget page;
  final FormTransitionDirection direction;
  final int stepNumber;

  FormSlideScaleTransition({
    required this.page,
    required this.direction,
    this.stepNumber = 1,
  }) : super(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) => page,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const curve = Curves.easeInOutCubic;
    const reverseCurve = Curves.easeInCubic;
    
    // Feedback háptico al inicio de la transición
    if (animation.value == 0.0) {
      HapticFeedback.lightImpact();
    }

    // Animaciones de entrada
    final slideAnimation = Tween<Offset>(
      begin: direction == FormTransitionDirection.forward
          ? const Offset(1.0, 0.0)
          : const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    final scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
    ));

    // Animaciones de salida
    final exitAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: direction == FormTransitionDirection.forward
          ? const Offset(-0.3, 0.0)
          : const Offset(0.3, 0.0),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: reverseCurve,
    ));

    final exitScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: reverseCurve,
    ));

    return Stack(
      children: [
        // Página anterior (saliente)
        SlideTransition(
          position: exitAnimation,
          child: ScaleTransition(
            scale: exitScaleAnimation,
            child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.3).animate(
                CurvedAnimation(parent: secondaryAnimation, curve: reverseCurve),
              ),
              child: Container(),
            ),
          ),
        ),
        // Página nueva (entrante)
        SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

/// Transición con desvanecimiento y deslizamiento suave
class FormFadeSlideTransition<T> extends PageRouteBuilder<T> {
  final Widget page;
  final FormTransitionDirection direction;
  final int stepNumber;

  FormFadeSlideTransition({
    required this.page,
    required this.direction,
    this.stepNumber = 1,
  }) : super(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => page,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const curve = Curves.easeInOut;
    
    final slideAnimation = Tween<Offset>(
      begin: direction == FormTransitionDirection.forward
          ? const Offset(0.3, 0.0)
          : const Offset(-0.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
}

/// Transición en capas con efecto de profundidad
class FormLayeredTransition<T> extends PageRouteBuilder<T> {
  final Widget page;
  final FormTransitionDirection direction;
  final int stepNumber;

  FormLayeredTransition({
    required this.page,
    required this.direction,
    this.stepNumber = 1,
  }) : super(
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (context, animation, secondaryAnimation) => page,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const curve = Curves.easeInOutCubic;
    
    // Animación de entrada con efecto de elevación
    final slideAnimation = Tween<Offset>(
      begin: direction == FormTransitionDirection.forward
          ? const Offset(1.0, 0.0)
          : const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    final scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutQuart,
    ));

    // Sombra dinámica
    final shadowAnimation = Tween<double>(
      begin: 0.0,
      end: 16.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: shadowAnimation.value,
                spreadRadius: shadowAnimation.value * 0.1,
                offset: Offset(0, shadowAnimation.value * 0.5),
              ),
            ],
          ),
          child: SlideTransition(
            position: slideAnimation,            child: ScaleTransition(
              scale: scaleAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// Widget auxiliar para indicador de progreso de formularios
class FormProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final FormTransitionDirection direction;

  const FormProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.direction = FormTransitionDirection.forward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Text(
              'Paso $currentStep de $totalSteps',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            direction == FormTransitionDirection.forward
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
            color: Colors.white.withValues(alpha: 0.7),
            size: 12,
          ),
        ],
      ),
    );
  }
}
