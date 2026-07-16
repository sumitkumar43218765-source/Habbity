import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';

/// A glassmorphism statistic card with icon, value, title, and subtitle.
///
/// Matches the visual language of [HabitCard] — frosted glass surface,
/// soft border, and entrance animation via flutter_animate.
class StatCard extends StatelessWidget {
  /// Short label above the value (e.g. "Total Habits").
  final String title;

  /// Primary metric string (e.g. "24").
  final String value;

  /// Optional secondary line (e.g. "↑ 12% this week").
  final String? subtitle;

  /// Leading icon.
  final IconData icon;

  /// Accent colour for the icon circle and value text.
  /// Falls back to [AppColors.primary] if null.
  final Color? color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = color ?? AppColors.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.glassWhite,
            border: Border.all(color: AppColors.glassBorder, width: 1),
            gradient: LinearGradient(
              colors: [
                c.withValues(alpha: 0.06),
                Colors.transparent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon circle ─────────────────────────────────
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.withValues(alpha: 0.15),
                ),
                child: Icon(icon, color: c, size: 20),
              ),
              const SizedBox(height: 14),

              // ── Value ───────────────────────────────────────
              Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: c,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),

              // ── Title ───────────────────────────────────────
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // ── Subtitle ────────────────────────────────────
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSubtle,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 450.ms, curve: Curves.easeOut)
        .slideY(begin: 0.08, end: 0, duration: 450.ms, curve: Curves.easeOut);
  }
}
