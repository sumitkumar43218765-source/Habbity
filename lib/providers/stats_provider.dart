import 'package:flutter/foundation.dart';

import '../models/habit.dart';
import '../models/habit_record.dart';
import '../utils/date_utils.dart';
import 'habit_provider.dart';

/// Provides computed statistics and analytics derived from [HabitProvider].
///
/// Designed to be used with [ChangeNotifierProxyProvider] so that it
/// automatically updates whenever the underlying habit data changes.
class StatsProvider extends ChangeNotifier {
  HabitProvider _habitProvider;

  StatsProvider(this._habitProvider);

  /// Called by [ChangeNotifierProxyProvider] whenever [HabitProvider] changes.
  void update(HabitProvider provider) {
    _habitProvider = provider;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Convenience accessors
  // ---------------------------------------------------------------------------

  List<Habit> get _habits => _habitProvider.habits;

  List<HabitRecord> get _allRecords =>
      _habits.expand((h) => _habitProvider.getHabitRecords(h.id)).toList();

  // ---------------------------------------------------------------------------
  // Weekly & Monthly Completion Rates
  // ---------------------------------------------------------------------------

  /// Overall completion rate for the last 7 days (0.0 – 1.0).
  double get weeklyCompletionRate => _completionRateForDays(7);

  /// Overall completion rate for the last 30 days (0.0 – 1.0).
  double get monthlyCompletionRate => _completionRateForDays(30);

  /// Generic helper: computes the aggregate completion rate across all active
  /// habits for the last [days] days.
  double _completionRateForDays(int days) {
    if (_habits.isEmpty) return 0.0;

    int totalScheduled = 0;
    int totalCompleted = 0;
    final today = AppDateUtils.normalizeDate(DateTime.now());

    for (final habit in _habits) {
      final completedDates = _completedDateKeys(habit.id);

      for (int i = 0; i < days; i++) {
        final date = today.subtract(Duration(days: i));
        if (_isScheduled(habit, date)) {
          totalScheduled++;
          if (completedDates.contains(_dateKey(date))) {
            totalCompleted++;
          }
        }
      }
    }

    if (totalScheduled == 0) return 0.0;
    return totalCompleted / totalScheduled;
  }

  // ---------------------------------------------------------------------------
  // Chart Data
  // ---------------------------------------------------------------------------

  /// Returns a map of {dayOfWeek (1=Mon..7=Sun): completionRate} for the
  /// current week. Suitable for a bar chart.
  Map<int, double> get weeklyData {
    final today = AppDateUtils.normalizeDate(DateTime.now());
    // Find the Monday of the current week.
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final result = <int, double>{};

    for (int weekday = 1; weekday <= 7; weekday++) {
      final date = monday.add(Duration(days: weekday - 1));
      // Don't include future days.
      if (date.isAfter(today)) {
        result[weekday] = 0.0;
        continue;
      }

      int scheduled = 0;
      int completed = 0;

      for (final habit in _habits) {
        if (_isScheduled(habit, date)) {
          scheduled++;
          if (_habitProvider.isHabitCompletedOn(habit.id, date)) {
            completed++;
          }
        }
      }

      result[weekday] = scheduled == 0 ? 0.0 : completed / scheduled;
    }

    return result;
  }

  /// Returns a map of {daysAgo (0 = today, 29 = 29 days ago): completionRate}
  /// for the last 30 days. Suitable for a line chart.
  Map<int, double> get last30DaysData {
    final today = AppDateUtils.normalizeDate(DateTime.now());
    final result = <int, double>{};

    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));

      int scheduled = 0;
      int completed = 0;

      for (final habit in _habits) {
        if (_isScheduled(habit, date)) {
          scheduled++;
          if (_habitProvider.isHabitCompletedOn(habit.id, date)) {
            completed++;
          }
        }
      }

      result[i] = scheduled == 0 ? 0.0 : completed / scheduled;
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Habit Rankings
  // ---------------------------------------------------------------------------

  /// Habits sorted by completion rate (highest first).
  List<Habit> get topHabits {
    final sorted = List<Habit>.from(_habits);
    sorted.sort((a, b) {
      final rateA = _habitProvider.getCompletionRate(a.id);
      final rateB = _habitProvider.getCompletionRate(b.id);
      return rateB.compareTo(rateA);
    });
    return sorted;
  }

  /// Habits sorted by completion rate (lowest first) — those needing the
  /// most attention.
  List<Habit> get needsWorkHabits {
    final sorted = List<Habit>.from(_habits);
    sorted.sort((a, b) {
      final rateA = _habitProvider.getCompletionRate(a.id);
      final rateB = _habitProvider.getCompletionRate(b.id);
      return rateA.compareTo(rateB);
    });
    return sorted;
  }

  // ---------------------------------------------------------------------------
  // Lifetime Stats
  // ---------------------------------------------------------------------------

  /// Total number of completed habit records across all time.
  int get totalCompletions {
    return _allRecords.where((r) => r.isCompleted).length;
  }

  /// The longest streak across all active habits.
  int get longestStreak {
    if (_habits.isEmpty) return 0;
    int best = 0;
    for (final habit in _habits) {
      final streak = _habitProvider.getBestStreak(habit.id);
      if (streak > best) best = streak;
    }
    return best;
  }

  /// Number of active habits that currently have a streak > 0.
  int get activeStreaks {
    int count = 0;
    for (final habit in _habits) {
      if (_habitProvider.getCurrentStreak(habit.id) > 0) count++;
    }
    return count;
  }

  // ---------------------------------------------------------------------------
  // Heatmap
  // ---------------------------------------------------------------------------

  /// Returns a map of {date: completionPercentage (0.0–1.0)} for the last
  /// 90 days. Suitable for a contribution/heatmap chart.
  Map<DateTime, double> get heatmapData {
    final today = AppDateUtils.normalizeDate(DateTime.now());
    final result = <DateTime, double>{};

    for (int i = 0; i < 90; i++) {
      final date = today.subtract(Duration(days: i));

      int scheduled = 0;
      int completed = 0;

      for (final habit in _habits) {
        if (_isScheduled(habit, date)) {
          scheduled++;
          if (_habitProvider.isHabitCompletedOn(habit.id, date)) {
            completed++;
          }
        }
      }

      result[date] = scheduled == 0 ? 0.0 : completed / scheduled;
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Whether [habit] is scheduled on [date] based on its frequency days.
  bool _isScheduled(Habit habit, DateTime date) {
    if (habit.frequencyDays.isEmpty) return true;
    return habit.frequencyDays.contains(date.weekday);
  }

  /// Builds a set of date-key strings for all completed records of [habitId].
  Set<String> _completedDateKeys(String habitId) {
    final records = _habitProvider.getHabitRecords(habitId);
    return records
        .where((r) => r.isCompleted)
        .map((r) => _dateKey(r.date))
        .toSet();
  }

  /// Creates a unique string key for a date (ignoring time).
  String _dateKey(DateTime date) {
    final d = AppDateUtils.normalizeDate(date);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
