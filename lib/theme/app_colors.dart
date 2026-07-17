import 'package:flutter/material.dart';

/// Defines the color palette for the Habbity app.
///
/// Updated to a minimalist Deep Black & Pure White theme.
abstract class AppColors {
  // ── Primary Brand Colors ──────────────────────────────────────────────────
  /// Pure Black for light mode
  static const Color primaryLight = Color(0xFF000000);
  
  /// Pure White for dark mode
  static const Color primaryDark = Color(0xFFFFFFFF);

  /// Accent for subtle highlights (grey)
  static const Color accent = Color(0xFF888888);

  // ── Semantic Colors (Kept vibrant for clarity) ───────────────────────────
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFD50000);

  // ── Dark Theme Surfaces ───────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF000000);       // Deep Black
  static const Color darkSurface = Color(0xFF0A0A0A);  // Very dark grey
  static const Color darkCard = Color(0xFF121212);     // Slightly lighter for depth

  // ── Light Theme Surfaces ──────────────────────────────────────────────────
  static const Color lightBg = Color(0xFFFFFFFF);      // Pure White
  static const Color lightSurface = Color(0xFFF9F9F9); // Off-white
  static const Color lightCard = Color(0xFFF0F0F0);    // Light grey for depth

  // ── Glassmorphism Colors ──────────────────────────────────────────────────
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // ── Text Colors ───────────────────────────────────────────────────────────
  /// Primary text on dark backgrounds.
  static const Color textDark = Color(0xFFFFFFFF);

  /// Primary text on light backgrounds.
  static const Color textLight = Color(0xFF000000);

  /// Subtle / secondary text.
  static const Color textSubtleDark = Color(0xFFAAAAAA);
  static const Color textSubtleLight = Color(0xFF666666);

  // ── Habit Color Palette ───────────────────────────────────────────────────
  /// A curated palette users can choose from when creating or editing a habit.
  /// (Kept colorful so individual habits can still be distinguished)
  static const List<Color> habitColors = [
    Color(0xFF000000), // Black
    Color(0xFF555555), // Grey
    Color(0xFFF44336), // Red
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
  ];
}
