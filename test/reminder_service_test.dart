import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noteflow_app/core/services/reminder_service.dart';
import 'package:noteflow_app/domain/entities/reminder_entity.dart';

void main() {
  late ReminderService reminderService;

  setUp(() async {
    // Mock SharedPreferences with an empty map
    SharedPreferences.setMockInitialValues({});
    
    reminderService = ReminderService.instance;
    await reminderService.init();
  });

  group('ReminderService Tests', () {
    test('should have default settings', () {
      expect(reminderService.globalRemindersEnabled, true);
      expect(reminderService.defaultReminderTime, 540); // 9:00 AM
      expect(reminderService.defaultReminderType, ReminderType.daily);
      expect(reminderService.soundEnabled, true);
      expect(reminderService.vibrationEnabled, true);
    });

    test('should set and get global reminders enabled', () async {
      await reminderService.setGlobalRemindersEnabled(false);
      expect(reminderService.globalRemindersEnabled, false);
      
      await reminderService.setGlobalRemindersEnabled(true);
      expect(reminderService.globalRemindersEnabled, true);
    });

    test('should set and get default reminder time', () async {
      const newTime = 600; // 10:00 AM
      await reminderService.setDefaultReminderTime(newTime);
      expect(reminderService.defaultReminderTime, newTime);
    });

    test('should set and get default reminder type', () async {
      await reminderService.setDefaultReminderType(ReminderType.weekly);
      expect(reminderService.defaultReminderType, ReminderType.weekly);
    });

    test('should set and get sound enabled', () async {
      await reminderService.setSoundEnabled(false);
      expect(reminderService.soundEnabled, false);
      
      await reminderService.setSoundEnabled(true);
      expect(reminderService.soundEnabled, true);
    });

    test('should set and get vibration enabled', () async {
      await reminderService.setVibrationEnabled(false);
      expect(reminderService.vibrationEnabled, false);
      
      await reminderService.setVibrationEnabled(true);
      expect(reminderService.vibrationEnabled, true);
    });

    test('should convert minutes to time string correctly', () {
      expect(reminderService.minutesToTimeString(540), '09:00'); // 9:00 AM
      expect(reminderService.minutesToTimeString(720), '12:00'); // 12:00 PM
      expect(reminderService.minutesToTimeString(1440 - 1), '23:59'); // 11:59 PM
    });

    test('should convert time string to minutes correctly', () {
      expect(reminderService.timeStringToMinutes('09:00'), 540);
      expect(reminderService.timeStringToMinutes('12:00'), 720);
      expect(reminderService.timeStringToMinutes('23:59'), 1439);
    });

    test('should create and get reminder', () async {
      final reminder = ReminderEntity(
        id: 'test-reminder',
        title: '测试提醒',
        message: '这是一个测试提醒',
        time: DateTime.now().add(const Duration(hours: 1)),
        type: ReminderType.daily,
        actions: [ReminderAction.notification],
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await reminderService.createReminder(reminder);
      
      final retrievedReminder = await reminderService.getReminderById('test-reminder');
      expect(retrievedReminder, isNotNull);
      expect(retrievedReminder!.id, 'test-reminder');
      expect(retrievedReminder.title, '测试提醒');
    });

    test('should get all reminders', () async {
      // 创建两个提醒
      final reminder1 = ReminderEntity(
        id: 'reminder-1',
        title: '提醒1',
        time: DateTime.now(),
        type: ReminderType.daily,
        actions: [ReminderAction.notification],
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final reminder2 = ReminderEntity(
        id: 'reminder-2',
        title: '提醒2',
        time: DateTime.now(),
        type: ReminderType.weekly,
        actions: [ReminderAction.sound],
        isEnabled: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await reminderService.createReminder(reminder1);
      await reminderService.createReminder(reminder2);

      final allReminders = await reminderService.getAllReminders();
      expect(allReminders.length, 2); // reminder1 和 reminder2
    });

    test('should toggle reminder enabled state', () async {
      final reminder = ReminderEntity(
        id: 'toggle-reminder',
        title: '切换提醒',
        time: DateTime.now(),
        type: ReminderType.daily,
        actions: [ReminderAction.notification],
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await reminderService.createReminder(reminder);
      
      // 禁用提醒
      await reminderService.toggleReminder('toggle-reminder', false);
      final disabledReminder = await reminderService.getReminderById('toggle-reminder');
      expect(disabledReminder!.isEnabled, false);
      
      // 启用提醒
      await reminderService.toggleReminder('toggle-reminder', true);
      final enabledReminder = await reminderService.getReminderById('toggle-reminder');
      expect(enabledReminder!.isEnabled, true);
    });

    test('should delete reminder', () async {
      final reminder = ReminderEntity(
        id: 'delete-reminder',
        title: '待删除提醒',
        time: DateTime.now(),
        type: ReminderType.daily,
        actions: [ReminderAction.notification],
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await reminderService.createReminder(reminder);
      
      // 确认提醒存在
      expect(await reminderService.getReminderById('delete-reminder'), isNotNull);
      
      // 删除提醒
      await reminderService.deleteReminder('delete-reminder');
      
      // 确认提醒已删除
      expect(await reminderService.getReminderById('delete-reminder'), isNull);
    });

    test('should export and import reminder settings', () async {
      // 设置一些值
      await reminderService.setGlobalRemindersEnabled(false);
      await reminderService.setDefaultReminderTime(420); // 7:00 AM
      await reminderService.setDefaultReminderType(ReminderType.weekly);
      await reminderService.setSoundEnabled(false);
      await reminderService.setVibrationEnabled(false);

      // 导出设置
      final exportedSettings = reminderService.exportReminderSettings();
      
      expect(exportedSettings['global_reminders_enabled'], false);
      expect(exportedSettings['default_reminder_time'], 420);
      expect(exportedSettings['default_reminder_type'], 'weekly');
      expect(exportedSettings['sound_enabled'], false);
      expect(exportedSettings['vibration_enabled'], false);

      // 重置为默认值
      await reminderService.setGlobalRemindersEnabled(true);
      await reminderService.setDefaultReminderTime(540);
      
      // 导入设置
      await reminderService.importReminderSettings(exportedSettings);
      
      // 验证导入的设置
      expect(reminderService.globalRemindersEnabled, false);
      expect(reminderService.defaultReminderTime, 420);
      expect(reminderService.defaultReminderType, ReminderType.weekly);
      expect(reminderService.soundEnabled, false);
      expect(reminderService.vibrationEnabled, false);
    });
  });
}