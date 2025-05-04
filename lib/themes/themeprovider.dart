import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  late ThemeMode _themeMode;

  ThemeProvider() {
    // Initialize with system theme by default
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    _themeMode =
        brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    SharedPreferences.getInstance().then(
      (value) {
        var isDarkMode = value.getBool('isDarkMode') ?? false;
        toggleTheme(isDarkMode);
      },
    );
  }

  // Get current theme mode
  ThemeMode get themeMode => _themeMode;

  // Switch theme mode based on user choice
  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    SharedPreferences.getInstance().then(
      (value) {
        value.setBool('isDarkMode', isDarkMode);
      },
    );
    notifyListeners();
  }

  // Update theme mode based on system preference
  void updateThemeBasedOnSystem(Brightness brightness) {
    _themeMode =
        brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
