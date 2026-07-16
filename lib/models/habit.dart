/// Represents a single trackable habit.
///
/// This is a plain Dart class (no Hive annotations). Persistence is handled
/// by the manually written [HabitAdapter] in `habit_adapter.dart`.
class Habit {
  /// Unique identifier (UUID v4).
  final String id;

  /// User-facing name, e.g. "Morning Run".
  final String name;

  /// An emoji string representing the habit, e.g. "🏃".
  final String icon;

  /// The habit's colour stored as an integer (e.g. `0xFF6C5CE7`).
  final int colorValue;

  /// Category label from [HabitCategory].
  final String category;

  /// Days of the week the habit is active.
  /// 1 = Monday … 7 = Sunday. An empty list means every day.
  final List<int> frequencyDays;

  /// Optional reminder in `HH:mm` format.
  final String? reminderTime;

  /// Optional target description, e.g. "30 min".
  final String? targetDescription;

  /// When the habit was first created.
  final DateTime createdAt;

  /// Whether the habit is archived (hidden from the daily view).
  final bool isArchived;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.category,
    this.frequencyDays = const [],
    this.reminderTime,
    this.targetDescription,
    required this.createdAt,
    this.isArchived = false,
  });

  /// Creates a shallow copy with selected fields overridden.
  Habit copyWith({
    String? id,
    String? name,
    String? icon,
    int? colorValue,
    String? category,
    List<int>? frequencyDays,
    String? reminderTime,
    String? targetDescription,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      category: category ?? this.category,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      reminderTime: reminderTime ?? this.reminderTime,
      targetDescription: targetDescription ?? this.targetDescription,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  /// Serialises the habit to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'colorValue': colorValue,
      'category': category,
      'frequencyDays': frequencyDays,
      'reminderTime': reminderTime,
      'targetDescription': targetDescription,
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  /// Deserialises a habit from a JSON-compatible map.
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      colorValue: json['colorValue'] as int,
      category: json['category'] as String,
      frequencyDays: (json['frequencyDays'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      reminderTime: json['reminderTime'] as String?,
      targetDescription: json['targetDescription'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'Habit(id: $id, name: $name, icon: $icon)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Habit && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
