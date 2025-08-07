import 'package:flutter/material.dart';
import 'package:lboard/core/services/sembast_service.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app.settings.theme_mode';

  final SembastService _sembastService = SembastService.instance;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    await _sembastService.init();
    final storedTheme = await _sembastService.getSetting(_themeKey);
    if (storedTheme != null) {
      _themeMode = _stringToThemeMode(storedTheme);
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _sembastService.saveSetting(_themeKey, _themeModeToString(mode));
    notifyListeners();
  }

  ThemeMode _stringToThemeMode(String themeString) {
    switch (themeString) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    return mode.toString();
  }
}
