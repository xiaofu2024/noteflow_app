import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/reminder_entity.dart';

class ReminderService {
  static const String _remindersKey = 'reminders';
  
  late SharedPreferences _prefs;
  
  static ReminderService? _instance;
  
  ReminderService._();
  
  static ReminderService get instance {
    _instance ??= ReminderService._();
    return _instance!;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 提醒设置相关方法
  
  /// 获取是否启用了全局提醒
  bool get globalRemindersEnabled => _prefs.getBool('global_reminders_enabled') ?? true;
  
  /// 设置全局提醒开关
  Future<void> setGlobalRemindersEnabled(bool enabled) async {
    await _prefs.setBool('global_reminders_enabled', enabled);
  }

  /// 获取默认提醒时间 (以分钟为单位，从午夜开始计算)
  int get defaultReminderTime => _prefs.getInt('default_reminder_time') ?? 540; // 默认9:00

  /// 设置默认提醒时间
  Future<void> setDefaultReminderTime(int minutes) async {
    await _prefs.setInt('default_reminder_time', minutes);
  }

  /// 获取默认提醒类型
  ReminderType get defaultReminderType {
    final typeString = _prefs.getString('default_reminder_type') ?? 'daily';
    return ReminderType.values.firstWhere(
      (type) => type.name == typeString,
      orElse: () => ReminderType.daily,
    );
  }

  /// 设置默认提醒类型
  Future<void> setDefaultReminderType(ReminderType type) async {
    await _prefs.setString('default_reminder_type', type.name);
  }

  /// 获取默认提醒动作
  List<ReminderAction> get defaultReminderActions {
    final actionsJson = _prefs.getStringList('default_reminder_actions') ?? ['notification'];
    return actionsJson.map((action) => ReminderAction.values.firstWhere(
      (a) => a.name == action,
      orElse: () => ReminderAction.notification,
    )).toList();
  }

  /// 设置默认提醒动作
  Future<void> setDefaultReminderActions(List<ReminderAction> actions) async {
    final actionsJson = actions.map((action) => action.name).toList();
    await _prefs.setStringList('default_reminder_actions', actionsJson);
  }

  /// 获取是否启用声音提醒
  bool get soundEnabled => _prefs.getBool('reminder_sound_enabled') ?? true;

  /// 设置声音提醒开关
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool('reminder_sound_enabled', enabled);
  }

  /// 获取是否启用振动提醒
  bool get vibrationEnabled => _prefs.getBool('reminder_vibration_enabled') ?? true;

  /// 设置振动提醒开关
  Future<void> setVibrationEnabled(bool enabled) async {
    await _prefs.setBool('reminder_vibration_enabled', enabled);
  }

  /// 获取提前提醒时间（分钟）
  int get advanceNotificationMinutes => _prefs.getInt('advance_notification_minutes') ?? 5;

  /// 设置提前提醒时间
  Future<void> setAdvanceNotificationMinutes(int minutes) async {
    await _prefs.setInt('advance_notification_minutes', minutes);
  }

  /// 获取周末是否启用提醒
  bool get weekendRemindersEnabled => _prefs.getBool('weekend_reminders_enabled') ?? false;

  /// 设置周末提醒开关
  Future<void> setWeekendRemindersEnabled(bool enabled) async {
    await _prefs.setBool('weekend_reminders_enabled', enabled);
  }

  /// 获取勿扰模式开始时间（分钟）
  int? get doNotDisturbStartTime => _prefs.getInt('dnd_start_time');

  /// 获取勿扰模式结束时间（分钟）
  int? get doNotDisturbEndTime => _prefs.getInt('dnd_end_time');

  /// 设置勿扰模式时间段
  Future<void> setDoNotDisturbTime(int? startMinutes, int? endMinutes) async {
    if (startMinutes != null) {
      await _prefs.setInt('dnd_start_time', startMinutes);
    } else {
      await _prefs.remove('dnd_start_time');
    }
    
    if (endMinutes != null) {
      await _prefs.setInt('dnd_end_time', endMinutes);
    } else {
      await _prefs.remove('dnd_end_time');
    }
  }

  /// 获取是否启用勿扰模式
  bool get doNotDisturbEnabled => doNotDisturbStartTime != null && doNotDisturbEndTime != null;

  // 提醒管理相关方法

  /// 获取所有提醒
  Future<List<ReminderEntity>> getAllReminders() async {
    final remindersJson = _prefs.getStringList(_remindersKey) ?? [];
    return remindersJson.map((jsonStr) {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return ReminderEntity.fromJson(json);
    }).toList();
  }

  /// 根据ID获取提醒
  Future<ReminderEntity?> getReminderById(String id) async {
    final reminders = await getAllReminders();
    try {
      return reminders.firstWhere((reminder) => reminder.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 创建提醒
  Future<void> createReminder(ReminderEntity reminder) async {
    final reminders = await getAllReminders();
    reminders.add(reminder);
    await _saveReminders(reminders);
  }

  /// 更新提醒
  Future<void> updateReminder(ReminderEntity reminder) async {
    final reminders = await getAllReminders();
    final index = reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      reminders[index] = reminder;
      await _saveReminders(reminders);
    }
  }

  /// 删除提醒
  Future<void> deleteReminder(String id) async {
    final reminders = await getAllReminders();
    reminders.removeWhere((reminder) => reminder.id == id);
    await _saveReminders(reminders);
  }

  /// 启用/禁用提醒
  Future<void> toggleReminder(String id, bool isEnabled) async {
    final reminder = await getReminderById(id);
    if (reminder != null) {
      final updatedReminder = reminder.copyWith(
        isEnabled: isEnabled,
        updatedAt: DateTime.now(),
      );
      await updateReminder(updatedReminder);
    }
  }

  /// 获取已启用的提醒
  Future<List<ReminderEntity>> getEnabledReminders() async {
    final reminders = await getAllReminders();
    return reminders.where((reminder) => reminder.isEnabled).toList();
  }

  /// 获取全局提醒
  Future<List<ReminderEntity>> getGlobalReminders() async {
    final reminders = await getAllReminders();
    return reminders.where((reminder) => reminder.noteId == null).toList();
  }

  /// 获取指定笔记的提醒
  Future<List<ReminderEntity>> getRemindersByNoteId(String noteId) async {
    final reminders = await getAllReminders();
    return reminders.where((reminder) => reminder.noteId == noteId).toList();
  }

  /// 清空所有提醒
  Future<void> clearAllReminders() async {
    await _prefs.remove(_remindersKey);
  }

  /// 保存提醒列表到SharedPreferences
  Future<void> _saveReminders(List<ReminderEntity> reminders) async {
    final remindersJson = reminders.map((reminder) => jsonEncode(reminder.toJson())).toList();
    await _prefs.setStringList(_remindersKey, remindersJson);
  }

  // 工具方法

  /// 将分钟转换为时间字符串 (HH:MM)
  String minutesToTimeString(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  /// 将时间字符串转换为分钟 (从午夜开始计算)
  int timeStringToMinutes(String timeString) {
    final parts = timeString.split(':');
    if (parts.length == 2) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      return hours * 60 + minutes;
    }
    return 0;
  }

  /// 检查当前时间是否在勿扰模式时间段内
  bool isInDoNotDisturbTime() {
    if (!doNotDisturbEnabled) return false;
    
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final startTime = doNotDisturbStartTime!;
    final endTime = doNotDisturbEndTime!;
    
    if (startTime < endTime) {
      // 同一天内的时间段
      return currentMinutes >= startTime && currentMinutes < endTime;
    } else {
      // 跨天的时间段
      return currentMinutes >= startTime || currentMinutes < endTime;
    }
  }

  /// 导出提醒设置
  Map<String, dynamic> exportReminderSettings() {
    return {
      'global_reminders_enabled': globalRemindersEnabled,
      'default_reminder_time': defaultReminderTime,
      'default_reminder_type': defaultReminderType.name,
      'default_reminder_actions': defaultReminderActions.map((a) => a.name).toList(),
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
      'advance_notification_minutes': advanceNotificationMinutes,
      'weekend_reminders_enabled': weekendRemindersEnabled,
      'dnd_start_time': doNotDisturbStartTime,
      'dnd_end_time': doNotDisturbEndTime,
    };
  }

  /// 导入提醒设置
  Future<void> importReminderSettings(Map<String, dynamic> settings) async {
    if (settings.containsKey('global_reminders_enabled')) {
      await setGlobalRemindersEnabled(settings['global_reminders_enabled'] ?? true);
    }
    if (settings.containsKey('default_reminder_time')) {
      await setDefaultReminderTime(settings['default_reminder_time'] ?? 540);
    }
    if (settings.containsKey('default_reminder_type')) {
      final typeString = settings['default_reminder_type'] ?? 'daily';
      final type = ReminderType.values.firstWhere(
        (t) => t.name == typeString,
        orElse: () => ReminderType.daily,
      );
      await setDefaultReminderType(type);
    }
    if (settings.containsKey('default_reminder_actions')) {
      final actionsData = settings['default_reminder_actions'] as List<dynamic>? ?? ['notification'];
      final actions = actionsData.map((action) => ReminderAction.values.firstWhere(
        (a) => a.name == action,
        orElse: () => ReminderAction.notification,
      )).toList();
      await setDefaultReminderActions(actions);
    }
    if (settings.containsKey('sound_enabled')) {
      await setSoundEnabled(settings['sound_enabled'] ?? true);
    }
    if (settings.containsKey('vibration_enabled')) {
      await setVibrationEnabled(settings['vibration_enabled'] ?? true);
    }
    if (settings.containsKey('advance_notification_minutes')) {
      await setAdvanceNotificationMinutes(settings['advance_notification_minutes'] ?? 5);
    }
    if (settings.containsKey('weekend_reminders_enabled')) {
      await setWeekendRemindersEnabled(settings['weekend_reminders_enabled'] ?? false);
    }
    if (settings.containsKey('dnd_start_time') && settings.containsKey('dnd_end_time')) {
      await setDoNotDisturbTime(
        settings['dnd_start_time'],
        settings['dnd_end_time'],
      );
    }
  }
}