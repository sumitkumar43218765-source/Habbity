import 'package:hive/hive.dart';

import '../models/habit.dart';
import '../models/habit_record.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';

/// Service responsible for all local persistence using Hive.
///
/// Habits and HabitRecords are stored as JSON Maps inside [Box<dynamic>] boxes,
/// since they are plain Dart classes (not HiveObjects).
/// Settings are stored as simple key-value pairs.
class DatabaseService {
  static late Box<dynamic> _habitsBox;
  static late Box<dynamic> _recordsBox;
  static late Box<dynamic> _settingsBox;

  /// Initializes all Hive boxes. Must be called once before any other method.
  static Future<void> init() async {
    _habitsBox = await Hive.openBox<dynamic>(AppConstants.habitsBox);
    _recordsBox = await Hive.openBox<dynamic>(AppConstants.recordsBox);
    _settingsBox = await Hive.openBox<dynamic>(AppConstants.settingsBox);
  }

  // ---------------------------------------------------------------------------
  // Habit CRUD
  // ---------------------------------------------------------------------------

  /// Persists a new [Habit] into the habits box keyed by its [Habit.id].
  Future<void> addHabit(Habit habit) async {
    await _habitsBox.put(habit.id, habit.toJson());
  }

  /// Updates an existing [Habit] in the habits box.
  Future<void> updateHabit(Habit habit) async {
    await _habitsBox.put(habit.id, habit.toJson());
  }

  /// Deletes the habit with the given [id] from the habits box.
  Future<void> deleteHabit(String id) async {
    await _habitsBox.delete(id);
  }

  /// Returns all stored habits as a list of [Habit] objects.
  List<Habit> getAllHabits() {
    return _habitsBox.values.map((dynamic value) {
      return Habit.fromJson(Map<String, dynamic>.from(value as Map));
    }).toList();
  }

  /// Returns the habit matching [id], or `null` if not found.
  Habit? getHabit(String id) {
    final dynamic value = _habitsBox.get(id);
    if (value == null) return null;
    return Habit.fromJson(Map<String, dynamic>.from(value as Map));
  }

  // ---------------------------------------------------------------------------
  // HabitRecord CRUD
  // ---------------------------------------------------------------------------

  /// Persists a new [HabitRecord] keyed by its [HabitRecord.id].
  Future<void> addRecord(HabitRecord record) async {
    await _recordsBox.put(record.id, record.toJson());
  }

  /// Updates an existing [HabitRecord].
  Future<void> updateRecord(HabitRecord record) async {
    await _recordsBox.put(record.id, record.toJson());
  }

  /// Deletes the record with the given [id].
  Future<void> deleteRecord(String id) async {
    await _recordsBox.delete(id);
  }

  /// Returns every stored [HabitRecord].
  List<HabitRecord> getAllRecords() {
    return _recordsBox.values.map((dynamic value) {
      return HabitRecord.fromJson(Map<String, dynamic>.from(value as Map));
    }).toList();
  }

  /// Returns all records that belong to the habit with [habitId].
  List<HabitRecord> getRecordsForHabit(String habitId) {
    return getAllRecords()
        .where((record) => record.habitId == habitId)
        .toList();
  }

  /// Returns the record for a specific [habitId] on a specific [date],
  /// or `null` if none exists. The [date] is normalized to midnight.
  HabitRecord? getRecordForDate(String habitId, DateTime date) {
    final normalizedDate = AppDateUtils.normalizeDate(date);
    final records = getRecordsForHabit(habitId);
    try {
      return records.firstWhere(
        (record) => AppDateUtils.isSameDay(record.date, normalizedDate),
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns all records whose date falls within [start] and [end] (inclusive).
  List<HabitRecord> getRecordsInRange(DateTime start, DateTime end) {
    final normalizedStart = AppDateUtils.normalizeDate(start);
    final normalizedEnd = AppDateUtils.normalizeDate(end);
    return getAllRecords().where((record) {
      final recordDate = AppDateUtils.normalizeDate(record.date);
      return !recordDate.isBefore(normalizedStart) &&
          !recordDate.isAfter(normalizedEnd);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  /// Saves a single setting identified by [key].
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Retrieves a setting value for the given [key], cast to [T].
  /// Returns `null` if the key does not exist.
  T? getSetting<T>(String key) {
    final dynamic value = _settingsBox.get(key);
    if (value is T) return value;
    return null;
  }

  /// Convenience getter: returns `true` if dark mode is enabled.
  /// Defaults to `true` when no preference has been saved.
  bool get isDarkMode => getSetting<bool>('isDarkMode') ?? true;

  /// Convenience setter for dark mode preference.
  Future<void> setDarkMode(bool value) async {
    await saveSetting('isDarkMode', value);
  }
}
