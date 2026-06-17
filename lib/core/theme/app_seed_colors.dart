import 'package:flutter/material.dart';

/// Preset Material 3 seed colors offered in Settings.
abstract final class AppSeedColors {
  static const Color indigo = Color(0xFF6750A4);
  static const Color teal = Color(0xFF006A6A);
  static const Color green = Color(0xFF386A20);
  static const Color orange = Color(0xFF8B5000);
  static const Color rose = Color(0xFFB3261E);
  static const Color blue = Color(0xFF0061A4);

  static const Color defaultSeed = indigo;

  static const List<Color> all = [
    indigo,
    teal,
    green,
    orange,
    rose,
    blue,
  ];
}
