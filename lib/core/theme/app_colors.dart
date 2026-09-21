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
  static const Color surfaceLight = Color(0xFFF7F7FA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF14141A);
  static const Color textSecondaryLight = Color(0xFF6E6E78);

  static const Color error = Color(0xFFFF5470);

  static const List<Color> darkBackgroundGradient = [inkBlack, prussianBlue];
}
