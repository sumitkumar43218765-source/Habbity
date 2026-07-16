/// Represents a single completion record for a habit on a given day.
///
/// This is a plain Dart class (no Hive annotations). Persistence is handled
/// by the manually written [HabitRecordAdapter] in `habit_record_adapter.dart`.
class HabitRecord {
  /// Unique identifier (UUID v4).
  final String id;

  /// The [Habit.id] this record belongs to.
  final String habitId;

  /// The calendar date this record covers, normalised to midnight (no time).
  final DateTime date;

  /// Whether the habit was completed on [date].
  final bool isCompleted;

  /// The exact timestamp when the user marked the habit as complete.
  /// `null` if the record exists but is not yet completed.
  final DateTime? completedAt;

  HabitRecord({
    required this.id,
    required this.habitId,
    required this.date,
    this.isCompleted = false,
    this.completedAt,
  });

  /// Creates a shallow copy with selected fields overridden.
  HabitRecord copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return HabitRecord(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Serialises the record to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Deserialises a record from a JSON-compatible map.
  factory HabitRecord.fromJson(Map<String, dynamic> json) {
    return HabitRecord(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      date: DateTime.parse(json['date'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  @override
  String toString() =>
      'HabitRecord(id: $id, habitId: $habitId, date: $date, done: $isCompleted)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is HabitRecord && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
