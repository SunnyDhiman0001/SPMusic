import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The app's glass orange/black visual treatment (surfaces, glows, nav pill,
/// progress colours). Widgets read it through `context.decor`.
@immutable
class AppDecor extends ThemeExtension<AppDecor> {
  const AppDecor({
    required this.glassSurface,
    required this.glassBorder,
    required this.accent,
    required this.accentGradient,
    required this.glowColor,
    required this.ambientGlow,
    required this.blurSigma,
    required this.navBackground,
    required this.navPillFill,
    required this.navPillBorder,
    required this.navPillGlow,
    required this.favorite,
    required this.progressActive,
    required this.progressInactive,
    required this.progressThumb,
    required this.miniPlayFill,
    required this.miniPlayIcon,
  });

  final Color glassSurface;
  final Color glassBorder;
  final Color accent;
  final LinearGradient accentGradient;
  final Color glowColor;

  /// Colour of the soft radial glow at the top of every page.
  final Color ambientGlow;
  final double blurSigma;
  final Color navBackground;
  final Color navPillFill;
  final Color navPillBorder;
  final Color navPillGlow;
  final Color favorite;
  final Color progressActive;
  final Color progressInactive;
  final Color progressThumb;
  final Color miniPlayFill;
  final Color miniPlayIcon;

  static const AppDecor dark = AppDecor(
    glassSurface: AppColors.glassSurface,
    glassBorder: AppColors.glassBorder,
    accent: AppColors.coral,
    accentGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.tangerineStart, AppColors.tangerineEnd],
    ),
    glowColor: Color(0x73FF6B4A), // coral @ 45%
    ambientGlow: Color(0x38FF6B4A), // coral @ 22%
    blurSigma: 12,
    navBackground: AppColors.obsidian,
    navPillFill: AppColors.navPillFill,
    navPillBorder: AppColors.coral,
    navPillGlow: Color(0x4DFF6B4A), // coral @ 30%
    favorite: AppColors.coral,
    progressActive: AppColors.coral,
    progressInactive: Color(0x33FFFFFF),
    progressThumb: Colors.white,
    miniPlayFill: Colors.white,
    miniPlayIcon: AppColors.obsidian,
  );

  @override
  AppDecor copyWith({
    Color? glassSurface,
    Color? glassBorder,
    Color? accent,
    LinearGradient? accentGradient,
    Color? glowColor,
    Color? ambientGlow,
    double? blurSigma,
    Color? navBackground,
    Color? navPillFill,
    Color? navPillBorder,
    Color? navPillGlow,
    Color? favorite,
    Color? progressActive,
    Color? progressInactive,
    Color? progressThumb,
    Color? miniPlayFill,
    Color? miniPlayIcon,
  }) {
    return AppDecor(
      glassSurface: glassSurface ?? this.glassSurface,
      glassBorder: glassBorder ?? this.glassBorder,
      accent: accent ?? this.accent,
      accentGradient: accentGradient ?? this.accentGradient,
      glowColor: glowColor ?? this.glowColor,
      ambientGlow: ambientGlow ?? this.ambientGlow,
      blurSigma: blurSigma ?? this.blurSigma,
      navBackground: navBackground ?? this.navBackground,
      navPillFill: navPillFill ?? this.navPillFill,
      navPillBorder: navPillBorder ?? this.navPillBorder,
      navPillGlow: navPillGlow ?? this.navPillGlow,
      favorite: favorite ?? this.favorite,
      progressActive: progressActive ?? this.progressActive,
      progressInactive: progressInactive ?? this.progressInactive,
      progressThumb: progressThumb ?? this.progressThumb,
      miniPlayFill: miniPlayFill ?? this.miniPlayFill,
      miniPlayIcon: miniPlayIcon ?? this.miniPlayIcon,
    );
  }

  /// There is a single decor (no theme switching), so interpolation just
  /// snaps at the halfway point.
  @override
  AppDecor lerp(ThemeExtension<AppDecor>? other, double t) {
    if (other is! AppDecor) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppDecorContext on BuildContext {
  /// The app decor; falls back to [AppDecor.dark] when a bare `ThemeData`
  /// (e.g. in widget tests) has no [AppDecor] registered.
  AppDecor get decor => Theme.of(this).extension<AppDecor>() ?? AppDecor.dark;
}
