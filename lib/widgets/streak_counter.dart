import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';

/// Animated streak counter badge.
///
/// Visual treatment scales with streak length:
/// - **0** → subtle "Start today!" hint
/// - **1–6** → standard 🔥 + number
/// - **7–29** → larger fire, golden text
/// - **30+** → golden text with an ambient glow
class StreakCounter extends StatelessWidget {
  /// Current consecutive-day streak.
  final int streak;

  /// Base font size of the counter number.
  final double size;

  const StreakCounter({
    super.key,
    required this.streak,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (streak <= 0) {
      return _buildZeroState(context);
    }

    final isWeekly = streak >= 7;
    final isMonthly = streak >= 30;
    final emojiSize = isWeekly ? size * 1.1 : size * 0.85;
    final numberStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: size,
          color: isWeekly ? AppColors.warning : AppColors.textDark,
        );

    Widget counter = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('🔥', style: TextStyle(fontSize: emojiSize)),
        const SizedBox(width: 4),
        Text('$streak', style: numberStyle),
      ],
    );

    // Wrap in a glow for 30+ day streaks
    if (isMonthly) {
      counter = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.warning.withValues(alpha: 0.30),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
          gradient: LinearGradient(
            colors: [
              AppColors.warning.withValues(alpha: 0.12),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: counter,
      );
    }

    return counter
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildZeroState(BuildContext context) {
    return Text(
      'Start today!',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSubtle,
            fontStyle: FontStyle.italic,
            fontSize: size * 0.5,
          ),
    ).animate().fadeIn(duration: 600.ms);
  }
}
