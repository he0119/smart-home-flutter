import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<ThemeMode> themeMode() async {
    final prefs = await _prefs;
    final String themeModeString = prefs.getString('themeMode') ?? 'system';
    return themeModeString == 'system'
        ? ThemeMode.system
        : themeModeString == 'light'
            ? ThemeMode.light
            : ThemeMode.dark;
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    // Use the shared_preferences package to persist settings locally or the
    // http package to persist settings over the network.
    final prefs = await _prefs;
    final String themeModeString = theme == ThemeMode.system
        ? 'system'
        : theme == ThemeMode.light
            ? 'light'
            : 'dark';
    prefs.setString('themeMode', themeModeString);
  }
}
