import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/habit.dart';
import '../models/habit_record.dart';

/// Provides export and sharing functionality for habit data.
///
/// Supports CSV and JSON formats. Files are written to the app's temporary
/// directory and can be shared via the system share sheet.
class ExportService {
  /// Date formatter for CSV/JSON date fields.
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Exports all [habits] and [records] to a CSV file.
  ///
  /// Returns the absolute path to the generated CSV file.
  static Future<String> exportToCsv(
    List<Habit> habits,
    List<HabitRecord> records,
  ) async {
    final buffer = StringBuffer();

    // ----- Habits section -----
    buffer.writeln('--- HABITS ---');
    buffer.writeln(
      'id,name,icon,color,category,frequencyDays,reminderTime,'
      'targetDescription,createdAt,isArchived',
    );
    for (final habit in habits) {
      buffer.writeln(
        '${_escapeCsv(habit.id)},'
        '${_escapeCsv(habit.name)},'
        '${_escapeCsv(habit.icon)},'
        '${habit.colorValue},'
        '${_escapeCsv(habit.category)},'
        '${_escapeCsv(habit.frequencyDays.join(';'))},'
        '${_escapeCsv(habit.reminderTime ?? '')},'
        '${_escapeCsv(habit.targetDescription ?? '')},'
        '${_escapeCsv(_dateTimeFormat.format(habit.createdAt))},'
        '${habit.isArchived}',
      );
    }

    buffer.writeln();

    // ----- Records section -----
    buffer.writeln('--- RECORDS ---');
    buffer.writeln('id,habitId,date,isCompleted,completedAt');
    for (final record in records) {
      buffer.writeln(
        '${_escapeCsv(record.id)},'
        '${_escapeCsv(record.habitId)},'
        '${_escapeCsv(_dateFormat.format(record.date))},'
        '${record.isCompleted},'
        '${record.completedAt != null ? _escapeCsv(_dateTimeFormat.format(record.completedAt!)) : ''}',
      );
    }

    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/habbity_export_$timestamp.csv');
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  /// Exports all [habits] and [records] to a JSON file.
  ///
  /// Returns the absolute path to the generated JSON file.
  static Future<String> exportToJson(
    List<Habit> habits,
    List<HabitRecord> records,
  ) async {
    final data = {
      'exportDate': _dateTimeFormat.format(DateTime.now()),
      'appName': 'Habbity',
      'habits': habits.map((h) => h.toJson()).toList(),
      'records': records.map((r) => r.toJson()).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/habbity_export_$timestamp.json');
    await file.writeAsString(jsonString);
    return file.path;
  }

  /// Shares the file at [filePath] using the system share sheet.
  static Future<void> shareExport(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Habbity Data Export',
      text: 'Here is my Habbity habit data export.',
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Wraps [value] in double-quotes and escapes existing quotes for CSV safety.
  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
