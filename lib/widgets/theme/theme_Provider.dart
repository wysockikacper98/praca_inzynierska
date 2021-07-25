import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:praca_inzynierska/helpers/storage_manager.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  set themeMode(ThemeMode value) {
    if (_themeMode != value) {
      _themeMode = value;
      notifyListeners();
    }
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance.window.platformBrightness;
      return brightness == Brightness.dark;
    } else {
      return _themeMode == ThemeMode.dark;
    }
  }

  Future<void> toggleTheme(bool isOn) async {
    ThemeMode theme = isOn ? ThemeMode.dark : ThemeMode.light;
    isOn
        ? await StorageManager.saveData('themeMode', 'dark')
        : await StorageManager.saveData('themeMode', 'light');
    _themeMode = theme;
    notifyListeners();
  }
}
