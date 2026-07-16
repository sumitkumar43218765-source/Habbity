import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

import '../models/habit.dart';

/// Handles all local notifications for the Habbity app.
///
/// Provides methods to schedule daily habit reminders, streak warnings,
/// morning summaries, and milestone celebrations.
class NotificationService {
  /// Singleton instance.
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Whether the service has been initialized.
  bool _isInitialized = false;

  // ---------------------------------------------------------------------------
  // Notification Channel IDs
  // ---------------------------------------------------------------------------

  static const String _reminderChannelId = 'habit_reminders';
  static const String _reminderChannelName = 'Habit Reminders';
  static const String _reminderChannelDesc =
      'Daily reminders for your habits';

  static const String _streakChannelId = 'streak_warnings';
  static const String _streakChannelName = 'Streak Warnings';
  static const String _streakChannelDesc =
      'Warnings when you might lose a streak';

  static const String _celebrationChannelId = 'celebrations';
  static const String _celebrationChannelName = 'Celebrations';
  static const String _celebrationChannelDesc =
      'Milestone and achievement celebrations';

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initializes the notification plugin and timezone data.
  Future<void> init() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Callback when a notification is tapped.
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  // ---------------------------------------------------------------------------
  // Android Notification Details Helpers
  // ---------------------------------------------------------------------------

  /// Creates [NotificationDetails] for the reminder channel.
  NotificationDetails _reminderDetails() {
    const android = AndroidNotificationDetails(
      _reminderChannelId,
      _reminderChannelName,
      channelDescription: _reminderChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }

  /// Creates [NotificationDetails] for the streak channel.
  NotificationDetails _streakDetails() {
    const android = AndroidNotificationDetails(
      _streakChannelId,
      _streakChannelName,
      channelDescription: _streakChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }

  /// Creates [NotificationDetails] for the celebration channel.
  NotificationDetails _celebrationDetails() {
    const android = AndroidNotificationDetails(
      _celebrationChannelId,
      _celebrationChannelName,
      channelDescription: _celebrationChannelDesc,
      importance: Importance.high,
      priority: Priority.defaultPriority,
      playSound: true,
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }

  // ---------------------------------------------------------------------------
  // Scheduling
  // ---------------------------------------------------------------------------

  /// Generates a deterministic notification ID from a habit's [id].
  int _habitNotificationId(String id) => id.hashCode.abs() % 2147483647;

  /// Schedules a daily reminder for the given [habit].
  ///
  /// The reminder fires at the time specified in [Habit.reminderTime]
  /// (expected format "HH:mm"). If [reminderTime] is null or empty this
  /// method is a no-op.
  Future<void> scheduleDailyReminder(Habit habit) async {
    if (habit.reminderTime == null || habit.reminderTime!.isEmpty) return;

    final parts = habit.reminderTime!.split(':');
    if (parts.length != 2) return;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return;

    // Cancel any existing reminder for this habit first.
    await cancelReminder(habit.id);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow.
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _habitNotificationId(habit.id),
      'Time for ${habit.name}!',
      'Don\'t forget to complete your habit today 💪',
      scheduledDate,
      _reminderDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: habit.id,
    );
  }

  /// Cancels the scheduled reminder for the habit with [habitId].
  Future<void> cancelReminder(String habitId) async {
    await _plugin.cancel(_habitNotificationId(habitId));
  }

  /// Cancels all scheduled and pending notifications.
  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  // ---------------------------------------------------------------------------
  // Immediate Notifications
  // ---------------------------------------------------------------------------

  /// Shows an immediate notification warning the user about a streak at risk.
  Future<void> showStreakWarning(String habitName, int streakDays) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      '🔥 Streak at risk!',
      'Your $streakDays-day streak for "$habitName" is about to break!',
      _streakDetails(),
    );
  }

  /// Shows a morning summary notification listing how many habits are due.
  Future<void> showMorningReminder(int habitCount) async {
    final plural = habitCount == 1 ? 'habit' : 'habits';
    await _plugin.show(
      0,
      '☀️ Good morning!',
      'You have $habitCount $plural to complete today. Let\'s go!',
      _reminderDetails(),
    );
  }

  /// Shows a celebration notification when the user hits a milestone.
  Future<void> showCelebration(String habitName, int milestone) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      '🎉 Milestone reached!',
      'Amazing! You\'ve completed "$habitName" $milestone times!',
      _celebrationDetails(),
    );
  }
}
