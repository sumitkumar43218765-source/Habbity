import 'package:flutter/material.dart';

import '../services/database_service.dart';

/// Manages the app's theme mode (light / dark) and persists the preference
/// to Hive via [DatabaseService].
///
/// Dark mode is enabled by default.
class ThemeProvider extends ChangeNotifier {
  final DatabaseService _db;

  bool _isDarkMode;

  /// Creates a [ThemeProvider] and loads the persisted preference.
  ///
  /// Pass in a [DatabaseService] instance so the provider can read/write
  /// the theme setting. The initial value is read synchronously from Hive.
  ThemeProvider({DatabaseService? databaseService})
      : _db = databaseService ?? DatabaseService(),
        _isDarkMode = (databaseService ?? DatabaseService()).isDarkMode;

  /// Whether dark mode is currently active.
  bool get isDarkMode => _isDarkMode;

  /// Returns the corresponding [ThemeMode].
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Toggles between dark and light mode and persists the change.
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _persist();
    notifyListeners();
  }

  /// Explicitly sets dark mode to [value] and persists the change.
  void setDarkMode(bool value) {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    _persist();
    notifyListeners();
  }

  /// Writes the current preference to persistent storage.
  void _persist() {
    _db.setDarkMode(_isDarkMode);
  }
}
