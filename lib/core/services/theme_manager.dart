import 'package:flutter/material.dart';
import 'user_preferences_service.dart';

class ThemeManager extends ChangeNotifier {
  final UserPreferencesService _prefsService;
  
  ThemeManager(this._prefsService) {
    _loadThemeMode();
  }
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  void _loadThemeMode() {
    final themeString = _prefsService.selectedTheme;
    switch (themeString) {
      case 'Light':
        _themeMode = ThemeMode.light;
        break;
      case 'Dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'System':
      default:
        _themeMode = ThemeMode.system;
        break;
    }
  }
  
  Future<void> setThemeMode(String themeString) async {
    await _prefsService.setSelectedTheme(themeString);
    
    switch (themeString) {
      case 'Light':
        _themeMode = ThemeMode.light;
        break;
      case 'Dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'System':
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    
    notifyListeners();
  }
  
  String get currentThemeString {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
      default:
        return 'System';
    }
  }
}