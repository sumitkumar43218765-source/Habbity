import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A gorgeous animated circular progress ring built with [CustomPainter].
///
/// Displays a gradient arc (primary → accent) over a subtle background
/// track, with the completion count centred inside.
///
/// Features:
/// - [TweenAnimationBuilder] driven progress animation
/// - Rounded stroke caps
/// - Gradient arc via [SweepGradient]
/// - Large centred "completed/total" label
/// - Small percentage label below
class ProgressRing extends StatelessWidget {
  /// Current progress value from `0.0` to `1.0`.
  final double progress;

  /// Number of habits completed today.
  final int completed;

  /// Total habits due today.
  final int total;

  /// Outer diameter of the ring widget.
  final double size;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.completed,
    required this.total,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final pct = (progress * 100).round();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Painted ring ──────────────────────────────
              CustomPaint(
                size: Size(size, size),
                painter: _ProgressRingPainter(
                  progress: animatedProgress,
                  strokeWidth: size * 0.075, // ~9px at 120
                ),
              ),

              // ── Centre text ───────────────────────────────
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$completed',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            height: 1.1,
                          ),
                        ),
                        TextSpan(
                          text: '/$total',
                          style: textTheme.titleSmall?.copyWith(
                            color: AppColors.textSubtle,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$pct%',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Custom painter
// ═══════════════════════════════════════════════════════════════════

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2; // 12-o'clock
    final sweepAngle = 2 * math.pi * progress;

    // ── Background track ────────────────────────────────────────
    final trackPaint = Paint()
      ..color = AppColors.darkSurface.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // ── Gradient arc ────────────────────────────────────────────
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradientPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: const [
          AppColors.primary,
          AppColors.primaryLight,
          AppColors.accent,
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);

    canvas.drawArc(rect, startAngle, sweepAngle, false, gradientPaint);
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.strokeWidth != strokeWidth;
}
