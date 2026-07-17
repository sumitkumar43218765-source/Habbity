import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralised Material 3 theme definitions for Habbity.
///
/// Implements a minimalist Deep Black & Pure White aesthetic.
class AppTheme {
  AppTheme._(); // Prevent instantiation.

  // ── Shared Constants ────────────────────────────────────────────────────
  static const double _cardRadius = 24.0; // Rounder, modern M3 look
  static const double _inputRadius = 16.0;
  static const double _buttonRadius = 16.0;

  // ── Dark Theme (Deep Black) ───────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: Colors.black,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        tertiary: AppColors.accent,
        surface: AppColors.darkSurface,
        onSurface: AppColors.textDark,
        error: AppColors.error,
        onError: Colors.white,
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)), // Subtle border
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ── App Bar ──
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),

      // ── FAB ──
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
      ),

      // ── Input Fields ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(
            color: AppColors.textSubtleDark.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textSubtleDark,
          fontSize: 15,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.textSubtleDark,
          fontSize: 15,
        ),
      ),

      // ── Bottom Navigation ──
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkBg, // Pure black nav bar
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textSubtleDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),

      // ── Elevated Button ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── Text Button ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Dialog ──
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),

      // ── Bottom Sheet ──
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: AppColors.textSubtleDark.withValues(alpha: 0.15),
        thickness: 1,
      ),

      // ── Typography ──
      textTheme: _buildTextTheme(base.textTheme, isDark: true),
    );
  }

  // ── Light Theme (Pure White) ──────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryLight,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.black,
        tertiary: AppColors.accent,
        surface: AppColors.lightSurface,
        onSurface: AppColors.textLight,
        error: AppColors.error,
        onError: Colors.white,
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ── App Bar ──
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),

      // ── FAB ──
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
      ),

      // ── Input Fields ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(
            color: AppColors.textSubtleLight.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textSubtleLight,
          fontSize: 15,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.textSubtleLight,
          fontSize: 15,
        ),
      ),

      // ── Bottom Navigation ──
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightBg, // Pure white nav bar
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textSubtleLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),

      // ── Elevated Button ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── Text Button ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Dialog ──
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
      ),

      // ── Bottom Sheet ──
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: AppColors.textSubtleLight.withValues(alpha: 0.15),
        thickness: 1,
      ),

      // ── Typography ──
      textTheme: _buildTextTheme(base.textTheme, isDark: false),
    );
  }

  // ── Typography Builder ────────────────────────────────────────────────────
  /// Uses Outfit for modern headlines and Inter for clean body text.
  static TextTheme _buildTextTheme(TextTheme base, {required bool isDark}) {
    final color = isDark ? AppColors.textDark : AppColors.textLight;

    return base.copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 57,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 45,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -1.0,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight,
        letterSpacing: 0.4,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 1.25,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 1.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight,
        letterSpacing: 1.5,
      ),
    );
  }
}
