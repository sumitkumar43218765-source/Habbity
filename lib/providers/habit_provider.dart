import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/habit.dart';
import '../models/habit_record.dart';
import '../services/database_service.dart';
import '../utils/date_utils.dart';

/// Central provider that manages habit and record state.
///
/// Exposes getters for today's progress, filtered habit lists, streak
/// calculations, and completion rates. All mutations are persisted via
/// [DatabaseService] and trigger UI rebuilds through [ChangeNotifier].
class HabitProvider extends ChangeNotifier {
  final DatabaseService _db;
  static const _uuid = Uuid();

  List<Habit> _habits = [];
  List<HabitRecord> _records = [];
  String? _selectedCategory;

  HabitProvider({DatabaseService? databaseService})
      : _db = databaseService ?? DatabaseService();

  // ---------------------------------------------------------------------------
  // Getters — Habits
  // ---------------------------------------------------------------------------

  /// Active (non-archived) habits sorted by creation date (newest first).
  List<Habit> get habits {
    final active = _habits.where((h) => !h.isArchived).toList();
    active.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return active;
  }

  /// Habits that are scheduled for today based on [Habit.frequencyDays].
  /// An empty [frequencyDays] list means the habit is daily.
  List<Habit> get todayHabits {
    final todayWeekday = DateTime.now().weekday; // 1=Mon..7=Sun
    return habits.where((habit) {
      if (habit.frequencyDays.isEmpty) return true;
      return habit.frequencyDays.contains(todayWeekday);
    }).toList();
  }

  /// All records for today.
  List<HabitRecord> get todayRecords {
    final now = DateTime.now();
    return _records
        .where((r) => AppDateUtils.isSameDay(r.date, now))
        .toList();
  }

  /// Number of today's habits that have been completed.
  int get todayCompleted {
    final todayHabitIds = todayHabits.map((h) => h.id).toSet();
    return todayRecords
        .where((r) => r.isCompleted && todayHabitIds.contains(r.habitId))
        .length;
  }

  /// Total number of habits scheduled for today.
  int get todayTotal => todayHabits.length;

  /// Today's completion progress as a value between 0.0 and 1.0.
  double get todayProgress {
    if (todayTotal == 0) return 0.0;
    return todayCompleted / todayTotal;
  }

  /// Currently selected category filter (null = show all).
  String? get selectedCategory => _selectedCategory;

  /// Habits filtered by the selected category. If no category is selected,
  /// returns all active habits.
  List<Habit> get filteredHabits {
    if (_selectedCategory == null) return habits;
    return habits.where((h) => h.category == _selectedCategory).toList();
  }

  // ---------------------------------------------------------------------------
  // Data Loading
  // ---------------------------------------------------------------------------

  /// Loads all habits and records from the database into memory.
  Future<void> loadData() async {
    _habits = _db.getAllHabits();
    _records = _db.getAllRecords();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Habit Mutations
  // ---------------------------------------------------------------------------

  /// Adds a new habit and persists it.
  Future<void> addHabit(Habit habit) async {
    await _db.addHabit(habit);
    _habits.add(habit);
    notifyListeners();
  }

  /// Updates an existing habit and persists the change.
  Future<void> updateHabit(Habit habit) async {
    await _db.updateHabit(habit);
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
    }
    notifyListeners();
  }

  /// Deletes a habit and all of its associated records.
  Future<void> deleteHabit(String id) async {
    await _db.deleteHabit(id);

    // Remove associated records.
    final relatedRecords = _records.where((r) => r.habitId == id).toList();
    for (final record in relatedRecords) {
      await _db.deleteRecord(record.id);
    }
    _records.removeWhere((r) => r.habitId == id);
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  /// Archives a habit (soft-delete).
  Future<void> archiveHabit(String id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final updated = _habits[index].copyWith(isArchived: true);
    await _db.updateHabit(updated);
    _habits[index] = updated;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Record / Completion Mutations
  // ---------------------------------------------------------------------------

  /// Toggles the completion state for [habitId] on [date].
  ///
  /// If no record exists for that day a new completed record is created.
  /// If one exists its [isCompleted] flag is toggled.
  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    final normalizedDate = AppDateUtils.normalizeDate(date);

    final existingIndex = _records.indexWhere(
      (r) =>
          r.habitId == habitId &&
          AppDateUtils.isSameDay(r.date, normalizedDate),
    );

    if (existingIndex != -1) {
      final existing = _records[existingIndex];
      final toggled = existing.copyWith(
        isCompleted: !existing.isCompleted,
        completedAt: !existing.isCompleted ? DateTime.now() : null,
      );
      await _db.updateRecord(toggled);
      _records[existingIndex] = toggled;
    } else {
      final newRecord = HabitRecord(
        id: _uuid.v4(),
        habitId: habitId,
        date: normalizedDate,
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      await _db.addRecord(newRecord);
      _records.add(newRecord);
    }

    notifyListeners();
  }

  /// Returns whether [habitId] is completed on [date].
  bool isHabitCompletedOn(String habitId, DateTime date) {
    return _records.any(
      (r) =>
          r.habitId == habitId &&
          AppDateUtils.isSameDay(r.date, date) &&
          r.isCompleted,
    );
  }

  // ---------------------------------------------------------------------------
  // Streak Calculations
  // ---------------------------------------------------------------------------

  /// Returns the current consecutive-day streak for [habitId].
  ///
  /// Counts backwards from today (or yesterday if today is not yet completed).
  int getCurrentStreak(String habitId) {
    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => throw StateError('Habit $habitId not found'),
    );
    final habitRecords = _records
        .where((r) => r.habitId == habitId && r.isCompleted)
        .toList();

    if (habitRecords.isEmpty) return 0;

    // Build a set of completed dates for O(1) lookups.
    final completedDates = <String>{};
    for (final r in habitRecords) {
      completedDates.add(_dateKey(r.date));
    }

    int streak = 0;
    DateTime checkDate = AppDateUtils.normalizeDate(DateTime.now());

    // If today isn't completed yet, start checking from yesterday.
    if (!completedDates.contains(_dateKey(checkDate))) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      // Skip days when the habit isn't scheduled.
      if (habit.frequencyDays.isNotEmpty &&
          !habit.frequencyDays.contains(checkDate.weekday)) {
        checkDate = checkDate.subtract(const Duration(days: 1));
        continue;
      }

      if (completedDates.contains(_dateKey(checkDate))) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Returns the longest streak ever achieved for [habitId].
  int getBestStreak(String habitId) {
    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => throw StateError('Habit $habitId not found'),
    );
    final habitRecords = _records
        .where((r) => r.habitId == habitId && r.isCompleted)
        .toList();

    if (habitRecords.isEmpty) return 0;

    // Sort records by date ascending.
    habitRecords.sort((a, b) => a.date.compareTo(b.date));

    final completedDates = <String>{};
    for (final r in habitRecords) {
      completedDates.add(_dateKey(r.date));
    }

    int bestStreak = 0;
    int currentStreak = 0;

    DateTime checkDate = AppDateUtils.normalizeDate(habitRecords.first.date);
    final endDate = AppDateUtils.normalizeDate(DateTime.now());

    while (!checkDate.isAfter(endDate)) {
      // Skip non-scheduled days.
      if (habit.frequencyDays.isNotEmpty &&
          !habit.frequencyDays.contains(checkDate.weekday)) {
        checkDate = checkDate.add(const Duration(days: 1));
        continue;
      }

      if (completedDates.contains(_dateKey(checkDate))) {
        currentStreak++;
        if (currentStreak > bestStreak) bestStreak = currentStreak;
      } else {
        currentStreak = 0;
      }

      checkDate = checkDate.add(const Duration(days: 1));
    }

    return bestStreak;
  }

  // ---------------------------------------------------------------------------
  // Completion Rate
  // ---------------------------------------------------------------------------

  /// Returns the completion rate for [habitId] over the last [days] days
  /// as a value between 0.0 and 1.0.
  double getCompletionRate(String habitId, {int days = 30}) {
    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => throw StateError('Habit $habitId not found'),
    );

    final completedDates = <String>{};
    for (final r in _records) {
      if (r.habitId == habitId && r.isCompleted) {
        completedDates.add(_dateKey(r.date));
      }
    }

    int scheduledDays = 0;
    int completedCount = 0;
    final today = AppDateUtils.normalizeDate(DateTime.now());

    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));

      // Only count days the habit is scheduled.
      if (habit.frequencyDays.isNotEmpty &&
          !habit.frequencyDays.contains(date.weekday)) {
        continue;
      }

      scheduledDays++;
      if (completedDates.contains(_dateKey(date))) {
        completedCount++;
      }
    }

    if (scheduledDays == 0) return 0.0;
    return completedCount / scheduledDays;
  }

  // ---------------------------------------------------------------------------
  // Record Queries
  // ---------------------------------------------------------------------------

  /// Returns all records for the given [habitId].
  List<HabitRecord> getHabitRecords(String habitId) {
    return _records.where((r) => r.habitId == habitId).toList();
  }

  // ---------------------------------------------------------------------------
  // Category Filter
  // ---------------------------------------------------------------------------

  /// Sets the category filter. Pass `null` to show all categories.
  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Creates a unique string key for a date (ignoring time).
  String _dateKey(DateTime date) {
    final d = AppDateUtils.normalizeDate(date);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
