import 'package:hive/hive.dart';

import 'habit_record.dart';

/// Manual Hive [TypeAdapter] for [HabitRecord].
///
/// Since `build_runner` / `hive_generator` cannot run on Android,
/// we hand-write the binary serialisation.
///
/// **TypeId: 1** — must be unique across all registered adapters.
class HabitRecordAdapter extends TypeAdapter<HabitRecord> {
  @override
  final int typeId = 1;

  @override
  HabitRecord read(BinaryReader reader) {
    final id = reader.readString();
    final habitId = reader.readString();

    // DateTime stored as ISO-8601 string.
    final date = DateTime.parse(reader.readString());

    final isCompleted = reader.readBool();

    // Nullable completedAt
    final hasCompletedAt = reader.readBool();
    final completedAt =
        hasCompletedAt ? DateTime.parse(reader.readString()) : null;

    return HabitRecord(
      id: id,
      habitId: habitId,
      date: date,
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
  }

  @override
  void write(BinaryWriter writer, HabitRecord obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.habitId);
    writer.writeString(obj.date.toIso8601String());
    writer.writeBool(obj.isCompleted);

    // Nullable completedAt
    writer.writeBool(obj.completedAt != null);
    if (obj.completedAt != null) {
      writer.writeString(obj.completedAt!.toIso8601String());
    }
  }
}
