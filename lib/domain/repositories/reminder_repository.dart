import '../entities/reminder_entity.dart';

abstract class ReminderRepository {
  /// 获取所有提醒
  Future<List<ReminderEntity>> getAllReminders();
  
  /// 根据ID获取提醒
  Future<ReminderEntity?> getReminderById(String id);
  
  /// 获取指定笔记的提醒
  Future<List<ReminderEntity>> getRemindersByNoteId(String noteId);
  
  /// 获取全局提醒（不关联具体笔记）
  Future<List<ReminderEntity>> getGlobalReminders();
  
  /// 创建提醒
  Future<void> createReminder(ReminderEntity reminder);
  
  /// 更新提醒
  Future<void> updateReminder(ReminderEntity reminder);
  
  /// 删除提醒
  Future<void> deleteReminder(String id);
  
  /// 删除指定笔记的所有提醒
  Future<void> deleteRemindersByNoteId(String noteId);
  
  /// 启用/禁用提醒
  Future<void> toggleReminder(String id, bool isEnabled);
  
  /// 获取已启用的提醒
  Future<List<ReminderEntity>> getEnabledReminders();
  
  /// 获取需要在指定时间之前触发的提醒
  Future<List<ReminderEntity>> getPendingReminders(DateTime beforeTime);
  
  /// 清空所有提醒
  Future<void> clearAllReminders();
}