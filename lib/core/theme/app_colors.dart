import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // "Dusk" palette — the source of truth for the app's dark aesthetic.
  static const Color inkBlack = Color(0xFF0D1B2A);
  static const Color prussianBlue = Color(0xFF1B263B);
  static const Color duskBlue = Color(0xFF415A77);
  static const Color lavenderGrey = Color(0xFF778DA9);
  static const Color alabasterGrey = Color(0xFFE0E1DD);

  // Semantic aliases used across the app's dark theme.
  static const Color black = inkBlack;
  static const Color charcoal = prussianBlue;
  static const Color surfaceDark = prussianBlue;
  static const Color cardDark = prussianBlue;

  static const Color primary = duskBlue;
  static const Color primaryVariant = Color(0xFF344A63);
  static const Color accent = duskBlue;

  static const Color textPrimaryDark = alabasterGrey;
  static const Color textSecondaryDark = lavenderGrey;

  static const Color white = alabasterGrey;

  static const Color error = Color(0xFFFF5470);

  /// Fixed brand accent from the app logo (the equalizer bars/play triangle):
  /// the logo's own color, not a theme-derived one.
  static const Color logoOrange = Color(0xFFFA6E4C);

  // Orange/black "glass" palette: the app's only theme.
  static const Color obsidian = Color(0xFF090A0C);
  static const Color surfaceSolid = Color(0xFF181A20);
  static const Color glassSurface = Color(0xBF181A20); // 75% opacity
  static const Color glassBorder = Color(0x1FFFFFFF); // 12% white
  static const Color coral = Color(0xFFFF6B4A);
  static const Color tangerineStart = Color(0xFFFF8F6B);
  static const Color tangerineEnd = Color(0xFFFF5733);
  static const Color mutedGrey = Color(0xFF9499A6);
  static const Color navPillFill = Color(0xFF1E2028);

  static const List<Color> darkBackgroundGradient = [obsidian, Color(0xFF0E1015)];
}
