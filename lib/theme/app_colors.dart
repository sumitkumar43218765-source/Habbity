import 'package:flutter/material.dart';

/// Defines the color palette for the Habbity app.
///
/// All colors are static constants ensuring consistency across the app.
/// Includes both light and dark theme colors, plus a curated list of
/// habit-assignment colors.
abstract class AppColors {
  // ── Primary Brand Colors ──────────────────────────────────────────────────
  /// Deep purple — the signature brand color.
  static const Color primary = Color(0xFF6C5CE7);

  /// Lighter variant of primary for hover/focus states.
  static const Color primaryLight = Color(0xFF8B7FF5);

  /// Coral — used for secondary actions and accents.
  static const Color secondary = Color(0xFFFF6B6B);

  /// Teal — used for tertiary accents and gradients.
  static const Color accent = Color(0xFF00D2D3);

  // ── Semantic Colors ───────────────────────────────────────────────────────
  /// Green — completion, streaks, positive feedback.
  static const Color success = Color(0xFF00B894);

  /// Orange — warnings, approaching deadlines.
  static const Color warning = Color(0xFFFDAA5E);

  /// Red — errors, missed habits, destructive actions.
  static const Color error = Color(0xFFFF5252);

  // ── Dark Theme Surfaces ───────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0D0D1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);

  // ── Light Theme Surfaces ──────────────────────────────────────────────────
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // ── Glassmorphism Colors ──────────────────────────────────────────────────
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // ── Text Colors ───────────────────────────────────────────────────────────
  /// Primary text on dark backgrounds.
  static const Color textDark = Color(0xFFEEEEEE);

  /// Primary text on light backgrounds.
  static const Color textLight = Color(0xFF2D3436);

  /// Subtle / secondary text (captions, hints).
  static const Color textSubtle = Color(0xFF636E72);

  // ── Habit Color Palette ───────────────────────────────────────────────────
  /// A curated palette users can choose from when creating or editing a habit.
  static const List<Color> habitColors = [
    primary,
    secondary,
    accent,
    success,
    warning,
    Color(0xFFE84393), // Pink
    Color(0xFF0984E3), // Blue
    Color(0xFF6C5CE7), // Purple
    Color(0xFFFD79A8), // Light pink
    Color(0xFFE17055), // Burnt orange
    Color(0xFF00CEC9), // Cyan
    Color(0xFFA29BFE), // Lavender
  ];

  // ── Gradients ─────────────────────────────────────────────────────────────
  /// The signature brand gradient used in hero sections and FABs.
  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );
}
