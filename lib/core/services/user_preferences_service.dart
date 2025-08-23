import 'package:noteflow_app/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _biometricKey = 'biometric_enabled';
  static const String _autoSyncKey = 'auto_sync_enabled';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _themeKey = 'selected_theme';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _fontSizeKey = 'font_size';
  static const String _noteViewModeKey = 'note_view_mode';
  static const String _defaultNoteColorKey = 'default_note_color';
  static const String _searchHistoryKey = 'search_history';

  late SharedPreferences _prefs;
  
  static UserPreferencesService? _instance;
  
  UserPreferencesService._();
  
  static UserPreferencesService get instance {
    _instance ??= UserPreferencesService._();
    return _instance!;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Biometric settings
  bool get biometricEnabled => _prefs.getBool(_biometricKey) ?? false;
  
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_biometricKey, enabled);
  }

  // Sync settings
  bool get autoSyncEnabled => _prefs.getBool(_autoSyncKey) ?? true;
  
  Future<void> setAutoSyncEnabled(bool enabled) async {
    await _prefs.setBool(_autoSyncKey, enabled);
  }

  // Notifications settings
  bool get notificationsEnabled => _prefs.getBool(_notificationsKey) ?? true;
  
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsKey, enabled);
  }

  // Theme settings
  String get selectedTheme => _prefs.getString(_themeKey) ?? 'System';
  
  Future<void> setSelectedTheme(String theme) async {
    await _prefs.setString(_themeKey, theme);
  }

  // User profile
  String get userName => _prefs.getString(_userNameKey) ?? AppConstants.appName + '用户';
  
  Future<void> setUserName(String name) async {
    await _prefs.setString(_userNameKey, name);
  }

  String get userEmail => _prefs.getString(_userEmailKey) ?? 'user@noteflow.com';
  
  Future<void> setUserEmail(String email) async {
    await _prefs.setString(_userEmailKey, email);
  }

  // Font settings
  double get fontSize => _prefs.getDouble(_fontSizeKey) ?? 14.0;
  
  Future<void> setFontSize(double size) async {
    await _prefs.setDouble(_fontSizeKey, size);
  }

  // Note view mode (list or grid)
  String get noteViewMode => _prefs.getString(_noteViewModeKey) ?? 'grid';
  
  Future<void> setNoteViewMode(String mode) async {
    await _prefs.setString(_noteViewModeKey, mode);
  }

  // Default note color
  int? get defaultNoteColor => _prefs.getInt(_defaultNoteColorKey);
  
  Future<void> setDefaultNoteColor(int? color) async {
    if (color != null) {
      await _prefs.setInt(_defaultNoteColorKey, color);
    } else {
      await _prefs.remove(_defaultNoteColorKey);
    }
  }

  // Search history
  List<String> get searchHistory => _prefs.getStringList(_searchHistoryKey) ?? [];
  
  Future<void> addSearchHistory(String query) async {
    List<String> history = searchHistory;
    // Remove if already exists to avoid duplicates
    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    // Add to the beginning
    history.insert(0, query);
    // Keep only last 10 searches
    if (history.length > 10) {
      history = history.take(10).toList();
    }
    await _prefs.setStringList(_searchHistoryKey, history);
  }

  Future<void> removeSearchHistory(String query) async {
    List<String> history = searchHistory;
    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    await _prefs.setStringList(_searchHistoryKey, history);
  }

  Future<void> clearSearchHistory() async {
    await _prefs.remove(_searchHistoryKey);
  }

  // Clear all preferences (for logout or reset)
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Export preferences for backup
  Map<String, dynamic> exportPreferences() {
    return {
      'biometric_enabled': biometricEnabled,
      'auto_sync_enabled': autoSyncEnabled,
      'notifications_enabled': notificationsEnabled,
      'selected_theme': selectedTheme,
      'user_name': userName,
      'user_email': userEmail,
      'font_size': fontSize,
      'note_view_mode': noteViewMode,
      'default_note_color': defaultNoteColor,
      'search_history': searchHistory,
    };
  }

  // Import preferences from backup
  Future<void> importPreferences(Map<String, dynamic> preferences) async {
    if (preferences.containsKey('biometric_enabled')) {
      await setBiometricEnabled(preferences['biometric_enabled'] ?? false);
    }
    if (preferences.containsKey('auto_sync_enabled')) {
      await setAutoSyncEnabled(preferences['auto_sync_enabled'] ?? true);
    }
    if (preferences.containsKey('notifications_enabled')) {
      await setNotificationsEnabled(preferences['notifications_enabled'] ?? true);
    }
    if (preferences.containsKey('selected_theme')) {
      await setSelectedTheme(preferences['selected_theme'] ?? 'System');
    }
    if (preferences.containsKey('user_name')) {
      await setUserName(preferences['user_name'] ?? 'NoteFlow用户');
    }
    if (preferences.containsKey('user_email')) {
      await setUserEmail(preferences['user_email'] ?? 'user@noteflow.com');
    }
    if (preferences.containsKey('font_size')) {
      await setFontSize(preferences['font_size']?.toDouble() ?? 14.0);
    }
    if (preferences.containsKey('note_view_mode')) {
      await setNoteViewMode(preferences['note_view_mode'] ?? 'grid');
    }
    if (preferences.containsKey('default_note_color')) {
      await setDefaultNoteColor(preferences['default_note_color']);
    }
    if (preferences.containsKey('search_history')) {
      final history = preferences['search_history'];
      if (history is List) {
        await _prefs.setStringList(_searchHistoryKey, history.cast<String>());
      }
    }
  }
}