/// App-wide constants for Habbity.
///
/// Centralises magic strings, box names, animation durations, and
/// motivational quotes so they can be changed from a single location.
class AppConstants {
  AppConstants._(); // Prevent instantiation.

  // ── App Identity ──────────────────────────────────────────────────────────
  static const String appName = 'Habbity';

  // ── Hive Box Names ────────────────────────────────────────────────────────
  static const String habitsBox = 'habits';
  static const String recordsBox = 'records';
  static const String settingsBox = 'settings';

  // ── Animation Durations ───────────────────────────────────────────────────
  static const Duration animDuration = Duration(milliseconds: 300);
  static const Duration animDurationSlow = Duration(milliseconds: 600);

  // ── Motivational Quotes ───────────────────────────────────────────────────
  /// Displayed on the home screen to encourage daily consistency.
  static const List<String> motivationalQuotes = [
    'We are what we repeatedly do. Excellence, then, is not an act, but a habit.',
    'Success is the sum of small efforts repeated day in and day out.',
    'Motivation is what gets you started. Habit is what keeps you going.',
    'The secret of your future is hidden in your daily routine.',
    'Small daily improvements over time lead to stunning results.',
    'First forget inspiration. Habit is more dependable.',
    'Good habits formed at youth make all the difference.',
    'Habits change into character.',
    'Your net worth to the world is usually determined by what remains after your bad habits are subtracted from your good ones.',
    'A habit cannot be tossed out the window; it must be coaxed down the stairs a step at a time.',
    'Champions don\'t do extraordinary things. They do ordinary things, but they do them without thinking.',
    'You\'ll never change your life until you change something you do daily.',
    'Discipline is choosing between what you want now and what you want most.',
    'The only way to break a bad habit is to replace it with a better one.',
    'Every action you take is a vote for the type of person you wish to become.',
  ];
}
