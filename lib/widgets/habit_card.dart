import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/habit.dart';
import '../theme/app_colors.dart';

/// A gorgeous glassmorphism habit card with accent bar, streak indicator,
/// and animated completion state.
///
/// This is the primary card used on the home screen to represent a single
/// habit. It features:
/// - A 4px left colour accent bar derived from the habit's colour
/// - An emoji icon in a tinted circle
/// - Habit name and optional target description
/// - A small category chip
/// - A streak counter (with 🔥) on the right
/// - A tap-able completion circle that fills with a gradient when done
/// - Subtle green glow when completed
/// - Glassmorphism styling with frosted surface and soft border
/// - flutter_animate entrance animation (fade + slide)
class HabitCard extends StatelessWidget {
  /// The habit to display.
  final Habit habit;

  /// Whether the habit has been completed today.
  final bool isCompleted;

  /// Current consecutive-day streak for this habit.
  final int streak;

  /// Called when the user taps the card.
  final VoidCallback onTap;

  /// Called when the user long-presses the card.
  final VoidCallback onLongPress;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.streak,
    required this.onTap,
    required this.onLongPress,
  });

  // ── Helpers ─────────────────────────────────────────────────────

  Color get _habitColor => Color(habit.colorValue);

  String _categoryLabel(String category) {
    if (category.isEmpty) return '';
    return '${category[0].toUpperCase()}${category.substring(1)}';
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppColors.success.withValues(alpha: 0.45)
                : AppColors.glassBorder,
            width: 1,
          ),
          boxShadow: [
            if (isCompleted)
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.15),
                blurRadius: 18,
                spreadRadius: 0,
              ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                borderRadius: BorderRadius.circular(16),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // ── Left accent bar ────────────────────────
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: _habitColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                    ),

                    // ── Card body ──────────────────────────────
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // ── Icon circle ────────────────────
                            _EmojiCircle(
                              emoji: habit.icon,
                              color: _habitColor,
                            ),
                            const SizedBox(width: 14),

                            // ── Text content ──────────────────
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    habit.name,
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: AppColors.textDark,
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationColor:
                                          AppColors.textSubtle,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (habit.targetDescription != null &&
                                      habit.targetDescription!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      habit.targetDescription!,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSubtle,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  _CategoryChipSmall(
                                    label: _categoryLabel(habit.category),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            // ── Right side: streak + checkbox ─
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (streak > 0)
                                  _StreakBadge(streak: streak),
                                const SizedBox(height: 6),
                                _CompletionCircle(
                                  isCompleted: isCompleted,
                                  color: _habitColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.06, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Private sub-widgets
// ═══════════════════════════════════════════════════════════════════

/// Emoji icon rendered inside a softly tinted circle.
class _EmojiCircle extends StatelessWidget {
  final String emoji;
  final Color color;

  const _EmojiCircle({required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
      ),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 22),
      ),
    );
  }
}

/// Tiny inline category chip.
class _CategoryChipSmall extends StatelessWidget {
  final String label;

  const _CategoryChipSmall({required this.label});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primaryLight,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// Small streak badge showing 🔥 + number.
class _StreakBadge extends StatelessWidget {
  final int streak;

  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    final isHot = streak >= 7;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '🔥',
          style: TextStyle(fontSize: isHot ? 16 : 13),
        ),
        const SizedBox(width: 2),
        Text(
          '$streak',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isHot ? AppColors.warning : AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: isHot ? 14 : 12,
              ),
        ),
      ],
    );
  }
}

/// Animated completion circle — gradient-filled when done, outlined when not.
class _CompletionCircle extends StatelessWidget {
  final bool isCompleted;
  final Color color;

  const _CompletionCircle({
    required this.isCompleted,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isCompleted
            ? LinearGradient(
                colors: [color, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: isCompleted
            ? null
            : Border.all(
                color: AppColors.textSubtle.withValues(alpha: 0.5),
                width: 2,
              ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: isCompleted
            ? const Icon(
                Icons.check_rounded,
                size: 18,
                color: Colors.white,
                key: ValueKey('check'),
              )
            : const SizedBox.shrink(key: ValueKey('empty')),
      ),
    );
  }
}
