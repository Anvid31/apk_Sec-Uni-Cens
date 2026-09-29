import 'package:flutter/material.dart';
import 'tokens.dart';

/// Configuración de temas para CENS Caracterización.
/// Todo el estilo visual fluye desde aquí — sin colores/radios inline en pantallas.
class AppTheme {
  static const Color seedColor = Color(0xFF2E7D32);
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color secondaryColor = Color(0xFF1B5E20);
  static const Color accentColor = Color(0xFF43A047);
  static const Color backgroundColor = Color(0xFFF7F8F6);
  static const Color surfaceColor = Color(0xFFFCFDFB);
  static const Color errorColor = Color(0xFFBA1A1A);

  static ColorScheme get _lightScheme => ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      ).copyWith(
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        tertiary: accentColor,
        error: errorColor,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: const Color(0xFF1A1C19),
        onSurfaceVariant: const Color(0xFF424940),
        outline: const Color(0xFF72796F),
        outlineVariant: const Color(0xFFC2C9BD),
        surfaceContainerLowest: const Color(0xFFFFFFFF),
        surfaceContainerLow: const Color(0xFFF1F3EE),
        surfaceContainer: const Color(0xFFEBEEE8),
        surfaceContainerHigh: const Color(0xFFE5E8E2),
        surfaceContainerHighest: const Color(0xFFE0E3DD),
      );

  static TextTheme _textTheme(ColorScheme scheme) {
    TextStyle base(double size, FontWeight weight, double height,
        {double letterSpacing = 0}) {
      return TextStyle(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: scheme.onSurface,
      );
    }

    return TextTheme(
      displayLarge: base(32, FontWeight.w700, 1.15, letterSpacing: -0.5),
      displayMedium: base(28, FontWeight.w700, 1.15, letterSpacing: -0.25),
      displaySmall: base(24, FontWeight.w700, 1.2),
      headlineLarge: base(22, FontWeight.w600, 1.25),
      headlineMedium: base(20, FontWeight.w600, 1.25),
      headlineSmall: base(18, FontWeight.w600, 1.3),
      titleLarge: base(16, FontWeight.w600, 1.35),
      titleMedium: base(14, FontWeight.w500, 1.4),
      titleSmall: base(12, FontWeight.w500, 1.4),
      bodyLarge: base(16, FontWeight.w400, 1.5),
      bodyMedium: base(14, FontWeight.w400, 1.5),
      bodySmall: base(12, FontWeight.w400, 1.45).copyWith(
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: base(14, FontWeight.w600, 1.35),
      labelMedium: base(12, FontWeight.w500, 1.35),
      labelSmall: base(11, FontWeight.w500, 1.35).copyWith(
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  static ThemeData get light {
    final scheme = _lightScheme;
    final text = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: text,
      scaffoldBackgroundColor: backgroundColor,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: Insets.xl, vertical: Insets.md),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: Radii.button),
          ),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.onSurface.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.pressed)) {
              return scheme.primary.withValues(alpha: 0.88);
            }
            return scheme.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.onSurface.withValues(alpha: 0.38);
            }
            return scheme.onPrimary;
          }),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.xl,
            vertical: Insets.md,
          ),
          shape: const RoundedRectangleBorder(borderRadius: Radii.button),
          textStyle: text.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(0, 48),
          side: BorderSide(color: scheme.outlineVariant),
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.xl,
            vertical: Insets.md,
          ),
          shape: const RoundedRectangleBorder(borderRadius: Radii.button),
          textStyle: text.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: text.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Insets.lg,
          vertical: Insets.md,
        ),
        border: OutlineInputBorder(
          borderRadius: Radii.input,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Radii.input,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.input,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Radii.input,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: Radii.input,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        labelStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        hintStyle: text.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),

      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.card,
          side: BorderSide(color: scheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        shape: const RoundedRectangleBorder(borderRadius: Radii.card),
        behavior: SnackBarBehavior.floating,
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainer,
        shape: const RoundedRectangleBorder(borderRadius: Radii.sheet),
      ),

      iconTheme: IconThemeData(color: scheme.primary, size: 24),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
    );
  }

  /// Alias conservado para widgets legacy.
  static InputDecorationThemeData get inputDecoration =>
      light.inputDecorationTheme;
}
