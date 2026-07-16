import 'package:intl/intl.dart';

/// Date-manipulation helpers used throughout Habbity.
///
/// Every method is a pure static function so callers never need to
/// instantiate this class.
class AppDateUtils {
  AppDateUtils._(); // Prevent instantiation.

  /// Strips the time component, returning midnight of the same day.
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Returns `true` when [a] and [b] fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns `true` when [date] is today.
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Returns the absolute number of calendar days between [a] and [b].
  static int daysBetween(DateTime a, DateTime b) {
    final normalA = normalizeDate(a);
    final normalB = normalizeDate(b);
    return normalA.difference(normalB).inDays.abs();
  }

  /// Returns all seven dates of the ISO week (Mon – Sun) that contains [date].
  static List<DateTime> getWeekDates(DateTime date) {
    // DateTime.weekday: Monday = 1, Sunday = 7.
    final monday = normalizeDate(date).subtract(
      Duration(days: date.weekday - 1),
    );
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  /// Returns every date in the calendar month of [date].
  static List<DateTime> getMonthDates(DateTime date) {
    final first = DateTime(date.year, date.month, 1);
    final last = DateTime(date.year, date.month + 1, 0); // last day of month
    return List.generate(
      last.day,
      (i) => first.add(Duration(days: i)),
    );
  }

  /// Formats [date] as `"16 Jul 2026"`.
  static String formatDate(DateTime date) {
    return DateFormat('d MMM y').format(date);
  }

  /// Formats [date] as the full weekday name, e.g. `"Wednesday"`.
  static String formatDay(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Returns a time-of-day greeting: Morning, Afternoon, or Evening.
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
