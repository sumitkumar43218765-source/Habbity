import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A GitHub-style contribution heatmap calendar.
///
/// Renders a horizontally scrollable grid where each cell represents a
/// single day. Cell colour intensity maps to a completion ratio (0.0–1.0).
///
/// Features:
/// - Day-of-week labels (M, W, F) on the left
/// - Month labels along the top
/// - Tappable cells with tooltip (date + %)
/// - Colour legend at the bottom
/// - Smooth scroll with auto-scroll-to-end on first render
class CalendarHeatmap extends StatefulWidget {
  /// Map of date (day-precision) → completion ratio `0.0`–`1.0`.
  final Map<DateTime, double> data;

  /// Number of months of history to show.
  final int months;

  const CalendarHeatmap({
    super.key,
    required this.data,
    this.months = 3,
  });

  @override
  State<CalendarHeatmap> createState() => _CalendarHeatmapState();
}

class _CalendarHeatmapState extends State<CalendarHeatmap> {
  late final ScrollController _scrollController;

  // Grid constants
  static const double _cellSize = 14;
  static const double _cellGap = 2;
  static const double _labelWidth = 24;

  // Pre-computed day rows (Mon → Sun = 7 rows)
  static const _dayLabels = ['M', '', 'W', '', 'F', '', 'S'];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Colour scale ──────────────────────────────────────────────

  static Color _intensityColor(double value) {
    if (value <= 0) return AppColors.darkSurface.withValues(alpha: 0.5);
    if (value <= 0.25) return AppColors.primary.withValues(alpha: 0.25);
    if (value <= 0.50) return AppColors.primary.withValues(alpha: 0.50);
    if (value <= 0.75) return AppColors.primary.withValues(alpha: 0.75);
    return AppColors.primary;
  }

  // ── Date helpers ──────────────────────────────────────────────

  /// Strip time components for map lookup.
  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Start date rounded back to the previous Monday.
  DateTime get _startDate {
    final raw = DateTime.now().subtract(Duration(days: widget.months * 30));
    // back-track to Monday (weekday 1)
    return raw.subtract(Duration(days: raw.weekday - 1));
  }

  DateTime get _endDate => DateTime.now();

  /// Generate columns (weeks) of 7-day slices.
  List<List<DateTime?>> _buildWeeks() {
    final weeks = <List<DateTime?>>[];
    var cursor = _startDate;
    while (!cursor.isAfter(_endDate)) {
      final week = <DateTime?>[];
      for (var d = 0; d < 7; d++) {
        final day = cursor.add(Duration(days: d));
        week.add(day.isAfter(_endDate) ? null : day);
      }
      weeks.add(week);
      cursor = cursor.add(const Duration(days: 7));
    }
    return weeks;
  }

  // ── Month label positioning ───────────────────────────────────

  List<_MonthLabel> _monthLabels(List<List<DateTime?>> weeks) {
    final labels = <_MonthLabel>[];
    int? lastMonth;
    for (var i = 0; i < weeks.length; i++) {
      final firstDay = weeks[i].firstWhere((d) => d != null, orElse: () => null);
      if (firstDay != null && firstDay.month != lastMonth) {
        lastMonth = firstDay.month;
        labels.add(_MonthLabel(
          index: i,
          label: _monthName(firstDay.month),
        ));
      }
    }
    return labels;
  }

  static String _monthName(int m) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[m];
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final weeks = _buildWeeks();
    final monthLabels = _monthLabels(weeks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Heatmap grid
        SizedBox(
          height: 7 * (_cellSize + _cellGap) + 20, // 7 rows + month label row
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Day-of-week labels
              SizedBox(
                width: _labelWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(7, (i) {
                    return SizedBox(
                      height: _cellSize + _cellGap,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _dayLabels[i],
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSubtle,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Scrollable grid
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Month labels row
                      SizedBox(
                        height: 18,
                        child: Stack(
                          children: monthLabels.map((ml) {
                            return Positioned(
                              left: ml.index * (_cellSize + _cellGap),
                              child: Text(
                                ml.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSubtle,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Cell grid
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: weeks.map((week) {
                          return Padding(
                            padding: const EdgeInsets.only(right: _cellGap),
                            child: Column(
                              children: week.map((day) {
                                if (day == null) {
                                  return SizedBox(
                                    width: _cellSize,
                                    height: _cellSize + _cellGap,
                                  );
                                }
                                final value =
                                    widget.data[_dayKey(day)] ?? 0.0;
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: _cellGap),
                                  child: Tooltip(
                                    message:
                                        '${day.day}/${day.month}/${day.year}'
                                        ' — ${(value * 100).round()}%',
                                    preferBelow: false,
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkCard,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Container(
                                      width: _cellSize,
                                      height: _cellSize,
                                      decoration: BoxDecoration(
                                        color: _intensityColor(value),
                                        borderRadius:
                                            BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── Legend ────────────────────────────────────────────────
        _Legend(),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Helper types
// ═══════════════════════════════════════════════════════════════════

class _MonthLabel {
  final int index;
  final String label;
  const _MonthLabel({required this.index, required this.label});
}

/// Colour-scale legend strip.
class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const levels = [0.0, 0.25, 0.50, 0.75, 1.0];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Less',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSubtle,
          ),
        ),
        const SizedBox(width: 4),
        ...levels.map((v) => Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: _CalendarHeatmapState._intensityColor(v),
                borderRadius: BorderRadius.circular(2),
              ),
            )),
        const SizedBox(width: 4),
        Text(
          'More',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSubtle,
          ),
        ),
      ],
    );
  }
}
