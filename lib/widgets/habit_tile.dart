import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/habit.dart';
import '../theme/app_colors.dart';

/// A compact habit row designed for list views.
///
/// This is a slimmer alternative to [HabitCard], optimised for dense lists.
///
/// Features:
/// - Single-row layout: checkbox circle → emoji → name → streak → chevron
/// - Animated checkbox with scale bounce on toggle
/// - [Dismissible] wrapper (swipe-left to delete, red background)
/// - Subtle bottom divider
/// - 64px height for comfortable touch targets
/// - flutter_animate entrance animation
class HabitTile extends StatelessWidget {
  /// The habit to display.
  final Habit habit;

  /// Whether the habit is completed today.
  final bool isCompleted;

  /// Consecutive-day streak.
  final int streak;

  /// Tap callback (e.g. toggle completion).
  final VoidCallback onTap;

  /// Long-press callback (e.g. open detail).
  final VoidCallback? onLongPress;

  const HabitTile({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.streak,
    required this.onTap,
    this.onLongPress,
  });

  Color get _habitColor => Color(habit.colorValue);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dismissible(
      key: ValueKey(habit.id),
      direction: DismissDirection.endToStart,
      background: _DismissBackground(),
      confirmDismiss: (_) async {
        // Delegated to the parent — return false to prevent auto-removal
        onLongPress?.call();
        return false;
      },
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        splashColor: _habitColor.withValues(alpha: 0.08),
        highlightColor: _habitColor.withValues(alpha: 0.04),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.glassBorder,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // ── Animated checkbox circle ─────────────────
              _AnimatedCheckbox(
                isCompleted: isCompleted,
                color: _habitColor,
              ),
              const SizedBox(width: 14),

              // ── Emoji icon ───────────────────────────────
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _habitColor.withValues(alpha: 0.12),
                ),
                alignment: Alignment.center,
                child: Text(habit.icon, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),

              // ── Name ─────────────────────────────────────
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.textSubtle,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (habit.targetDescription != null &&
                        habit.targetDescription!.isNotEmpty)
                      Text(
                        habit.targetDescription!,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSubtle,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // ── Streak ──────────────────────────────────
              if (streak > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🔥',
                        style: TextStyle(
                          fontSize: streak >= 7 ? 14 : 12,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$streak',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: streak >= 7
                              ? AppColors.warning
                              : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Chevron ──────────────────────────────────
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSubtle.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms, curve: Curves.easeOut)
        .slideX(begin: 0.04, end: 0, duration: 350.ms, curve: Curves.easeOut);
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Private sub-widgets
// ═══════════════════════════════════════════════════════════════════

/// Checkbox circle with an elastic scale animation on state change.
class _AnimatedCheckbox extends StatelessWidget {
  final bool isCompleted;
  final Color color;

  const _AnimatedCheckbox({
    required this.isCompleted,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: isCompleted ? 1.0 : 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return AnimatedScale(
          scale: isCompleted ? 1.0 : 0.95,
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: 26,
            height: 26,
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
                      color: AppColors.textSubtle.withValues(alpha: 0.4),
                      width: 2,
                    ),
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                      key: ValueKey('done'),
                    )
                  : const SizedBox.shrink(key: ValueKey('undone')),
            ),
          ),
        );
      },
    );
  }
}

/// Red dismiss background shown when swiping left.
class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Delete',
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.delete_outline_rounded,
            color: AppColors.secondary,
            size: 22,
          ),
        ],
      ),
    );
  }
}
