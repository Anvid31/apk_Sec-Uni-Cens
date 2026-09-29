import 'package:flutter/widgets.dart';

/// 4pt spacing scale — the only paddings/gaps that exist in this app.
abstract final class Insets {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;
}

/// Soft radius family — one language app-wide.
abstract final class Radii {
  static const Radius sm = Radius.circular(8);
  static const Radius md = Radius.circular(12);
  static const Radius lg = Radius.circular(16);
  static const Radius xl = Radius.circular(24);

  static const BorderRadius card = BorderRadius.all(md);
  static const BorderRadius button = BorderRadius.all(md);
  static const BorderRadius input = BorderRadius.all(md);
  static const BorderRadius sheet = BorderRadius.vertical(top: xl);
  static const BorderRadius sheetSm = BorderRadius.vertical(top: Radius.circular(20));
}

/// M3-aligned motion tokens. Keep Utility register restrained.
abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration enter = Duration(milliseconds: 400);
  static const Duration exit = Duration(milliseconds: 250);
}
