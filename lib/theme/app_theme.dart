import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Spacing Scale
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s6 = 6.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s14 = 14.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s28 = 28.0;
  static const double s32 = 32.0;
  static const double s48 = 48.0;

  // Radii
  static const double radiusButton = 14.0;
  static const double radiusCard = 22.0;
  static const double radiusPill = 999.0;

  // Elevation: Soft shadow 0 4 12 rgba(15, 23, 42, 0.05)
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.04),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.06),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> glowShadow = [
    BoxShadow(
      color: Color.fromRGBO(99, 102, 241, 0.28),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static TextStyle get tabularFigures => const TextStyle(
        fontFeatures: [FontFeature.tabularFigures()],
      );

  static ThemeData light() {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.lightAccent,
        onPrimary: Colors.white,
        secondary: AppColors.lightAccentSoft,
        onSecondary: AppColors.lightAccent,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.feedbackMiss,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 72,
          fontWeight: FontWeight.w700,
          color: AppColors.lightTextPrimary,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: AppColors.lightTextPrimary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.lightTextPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.lightTextSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          color: AppColors.lightTextSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lightAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightTextPrimary,
          side: const BorderSide(color: AppColors.lightBorder),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerColor: AppColors.lightBorder,
    );
  }

  static ThemeData dark() {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.darkAccent,
        onPrimary: Colors.black,
        secondary: AppColors.darkAccentSoft,
        onSecondary: AppColors.darkAccent,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.feedbackMiss,
        onError: Colors.black,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 72,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          color: AppColors.darkTextSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkAccent,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
          side: const BorderSide(color: AppColors.darkBorder),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerColor: AppColors.darkBorder,
    );
  }
}
