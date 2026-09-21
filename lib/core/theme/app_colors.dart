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

  // Semantic aliases used across the app's light theme — built from the same
  // "Dusk" palette so light mode reads as the same brand, not a different one.
  // A soft, cool-tinted off-white (not the beige-ish alabasterGrey) so white
  // cards actually pop off the background instead of blending into it.
  static const Color surfaceLight = Color(0xFFEEF1F5);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = inkBlack;
  // Deepened past lavenderGrey for real contrast on a light background —
  // lavenderGrey alone reads washed-out on white.
  static const Color textSecondaryLight = Color(0xFF54697F);

  static const Color error = Color(0xFFFF5470);

  /// Fixed brand accent from the app logo (the equalizer bars/play triangle).
  /// Intentionally the same in light and dark mode — it's the logo's color,
  /// not a theme-derived one.
  static const Color logoOrange = Color(0xFFFA6E4C);

  static const List<Color> darkBackgroundGradient = [inkBlack, prussianBlue];
  static const List<Color> lightBackgroundGradient = [Color(0xFFFFFFFF), surfaceLight];
}
