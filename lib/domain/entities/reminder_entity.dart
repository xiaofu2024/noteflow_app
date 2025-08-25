import 'package:equatable/equatable.dart';

enum ReminderType {
  daily,      // 每日提醒
  weekly,     // 每周提醒
  monthly,    // 每月提醒
  custom,     // 自定义间隔
}

enum ReminderAction {
  notification,   // 推送通知
  sound,         // 声音提醒
  vibration,     // 振动提醒
}

class ReminderEntity extends Equatable {
  final String id;
  final String title;
  final String? message;
  final DateTime time;
  final ReminderType type;
  final List<ReminderAction> actions;
  final bool isEnabled;
  final String? noteId; // 关联的笔记ID，如果为空则是全局提醒
  final Map<String, dynamic>? customSettings; // 自定义设置
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReminderEntity({
    required this.id,
    required this.title,
    this.message,
    required this.time,
    required this.type,
    required this.actions,
    required this.isEnabled,
    this.noteId,
    this.customSettings,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        time,
        type,
        actions,
        isEnabled,
        noteId,
        customSettings,
        createdAt,
        updatedAt,
      ];

  ReminderEntity copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? time,
    ReminderType? type,
    List<ReminderAction>? actions,
    bool? isEnabled,
    String? noteId,
    Map<String, dynamic>? customSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      type: type ?? this.type,
      actions: actions ?? this.actions,
      isEnabled: isEnabled ?? this.isEnabled,
      noteId: noteId ?? this.noteId,
      customSettings: customSettings ?? this.customSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'time': time.millisecondsSinceEpoch,
      'type': type.name,
      'actions': actions.map((action) => action.name).toList(),
      'isEnabled': isEnabled,
      'noteId': noteId,
      'customSettings': customSettings,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // 从JSON创建实例
  factory ReminderEntity.fromJson(Map<String, dynamic> json) {
    return ReminderEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String?,
      time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
      type: ReminderType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => ReminderType.daily,
      ),
      actions: (json['actions'] as List<dynamic>)
          .map((action) => ReminderAction.values.firstWhere(
                (a) => a.name == action,
                orElse: () => ReminderAction.notification,
              ))
          .toList(),
      isEnabled: json['isEnabled'] as bool,
      noteId: json['noteId'] as String?,
      customSettings: json['customSettings'] as Map<String, dynamic>?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }

  // 获取下次提醒时间
  DateTime? getNextReminderTime() {
    if (!isEnabled) return null;
    
    final now = DateTime.now();
    DateTime nextTime = time;
    
    // 如果设定的时间已经过了今天，需要计算下次提醒时间
    switch (type) {
      case ReminderType.daily:
        if (nextTime.isBefore(now)) {
          nextTime = DateTime(
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
          ).add(const Duration(days: 1));
        }
        break;
      case ReminderType.weekly:
        if (nextTime.isBefore(now)) {
          final daysToAdd = 7 - (now.weekday - time.weekday);
          nextTime = DateTime(
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
          ).add(Duration(days: daysToAdd));
        }
        break;
      case ReminderType.monthly:
        if (nextTime.isBefore(now)) {
          nextTime = DateTime(
            now.month == 12 ? now.year + 1 : now.year,
            now.month == 12 ? 1 : now.month + 1,
            time.day,
            time.hour,
            time.minute,
          );
        }
        break;
      case ReminderType.custom:
        // 自定义逻辑可以在这里实现
        break;
    }
    
    return nextTime;
  }

  // 获取提醒类型的显示文本
  String getTypeDisplayText() {
    switch (type) {
      case ReminderType.daily:
        return '每日';
      case ReminderType.weekly:
        return '每周';
      case ReminderType.monthly:
        return '每月';
      case ReminderType.custom:
        return '自定义';
    }
  }

  // 获取提醒动作的显示文本
  String getActionsDisplayText() {
    final texts = actions.map((action) {
      switch (action) {
        case ReminderAction.notification:
          return '通知';
        case ReminderAction.sound:
          return '声音';
        case ReminderAction.vibration:
          return '振动';
      }
    }).toList();
    
    return texts.join(' + ');
  }
}