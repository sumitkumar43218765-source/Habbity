import 'package:hive/hive.dart';

import 'habit.dart';

/// Manual Hive [TypeAdapter] for [Habit].
///
/// Since `build_runner` / `hive_generator` cannot run on Android,
/// we hand-write the binary serialisation.
///
/// **TypeId: 0** — must be unique across all registered adapters.
class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    // Read fields in the exact same order they were written.
    final id = reader.readString();
    final name = reader.readString();
    final icon = reader.readString();
    final colorValue = reader.readInt();
    final category = reader.readString();

    // frequencyDays: stored as length + individual ints.
    final freqLen = reader.readInt();
    final frequencyDays = List<int>.generate(freqLen, (_) => reader.readInt());

    // Nullable strings: a bool flag followed by the string if present.
    final hasReminder = reader.readBool();
    final reminderTime = hasReminder ? reader.readString() : null;

    final hasTarget = reader.readBool();
    final targetDescription = hasTarget ? reader.readString() : null;

    // DateTime stored as ISO-8601 string.
    final createdAt = DateTime.parse(reader.readString());

    final isArchived = reader.readBool();

    return Habit(
      id: id,
      name: name,
      icon: icon,
      colorValue: colorValue,
      category: category,
      frequencyDays: frequencyDays,
      reminderTime: reminderTime,
      targetDescription: targetDescription,
      createdAt: createdAt,
      isArchived: isArchived,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.icon);
    writer.writeInt(obj.colorValue);
    writer.writeString(obj.category);

    // frequencyDays
    writer.writeInt(obj.frequencyDays.length);
    for (final day in obj.frequencyDays) {
      writer.writeInt(day);
    }

    // Nullable reminderTime
    writer.writeBool(obj.reminderTime != null);
    if (obj.reminderTime != null) {
      writer.writeString(obj.reminderTime!);
    }

    // Nullable targetDescription
    writer.writeBool(obj.targetDescription != null);
    if (obj.targetDescription != null) {
      writer.writeString(obj.targetDescription!);
    }

    // createdAt as ISO-8601
    writer.writeString(obj.createdAt.toIso8601String());

    writer.writeBool(obj.isArchived);
  }
}
