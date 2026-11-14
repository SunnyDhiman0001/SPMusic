import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_decor.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.coral,
      secondary: AppColors.coral,
      surface: AppColors.surfaceSolid,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSurface: Colors.white,
      onSurfaceVariant: AppColors.mutedGrey,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.obsidian,
      cardColor: AppColors.surfaceSolid,
      textTheme: _textTheme(Colors.white, AppColors.mutedGrey),
      extensions: const [AppDecor.dark],
      cardTheme: CardThemeData(
        color: AppColors.surfaceSolid,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceSolid,
        modalBackgroundColor: AppColors.surfaceSolid,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.coral,
        inactiveTrackColor: Color(0x33FFFFFF),
        thumbColor: Colors.white,
        overlayColor: Color(0x33FF6B4A),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.coral : const Color(0x33FFFFFF),
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.glassSurface,
        selectedColor: AppColors.coral,
        side: BorderSide(color: AppColors.glassBorder),
        labelStyle: TextStyle(color: Colors.white),
        checkmarkColor: Colors.white,
        shape: StadiumBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: AppColors.coral),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.coral),
      dividerTheme: const DividerThemeData(color: AppColors.glassBorder),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.mutedGrey),
      ),
    );
  }

  static TextTheme _textTheme(Color primaryColor, Color secondaryColor) {
    final base = TextTheme(
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: primaryColor),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: primaryColor),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: primaryColor),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: primaryColor),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: secondaryColor),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: secondaryColor),
    );
    return GoogleFonts.notoSansTextTheme(base);
  }
}
