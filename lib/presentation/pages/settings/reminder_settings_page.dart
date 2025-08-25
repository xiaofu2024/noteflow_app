import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import '../../../core/services/reminder_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/reminder_entity.dart';

class ReminderSettingsPage extends StatefulWidget {
  const ReminderSettingsPage({super.key});

  @override
  State<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  late ReminderService _reminderService;
  bool _isLoading = true;
  
  // 设置值
  bool _globalRemindersEnabled = true;
  int _defaultReminderTime = 540; // 9:00 AM
  ReminderType _defaultReminderType = ReminderType.daily;
  // List<ReminderAction> _defaultReminderActions = [ReminderAction.notification];
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  int _advanceNotificationMinutes = 5;
  bool _weekendRemindersEnabled = false;
  int? _doNotDisturbStartTime;
  int? _doNotDisturbEndTime;

  @override
  void initState() {
    super.initState();
    _reminderService = GetIt.instance<ReminderService>();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _globalRemindersEnabled = _reminderService.globalRemindersEnabled;
      _defaultReminderTime = _reminderService.defaultReminderTime;
      _defaultReminderType = _reminderService.defaultReminderType;
      // _defaultReminderActions = _reminderService.defaultReminderActions;
      _soundEnabled = _reminderService.soundEnabled;
      _vibrationEnabled = _reminderService.vibrationEnabled;
      _advanceNotificationMinutes = _reminderService.advanceNotificationMinutes;
      _weekendRemindersEnabled = _reminderService.weekendRemindersEnabled;
      _doNotDisturbStartTime = _reminderService.doNotDisturbStartTime;
      _doNotDisturbEndTime = _reminderService.doNotDisturbEndTime;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              '提醒设置',
              style: AppTextStyles.appBarTitle,
            ),
          ),

          // Settings Sections
          SliverList(
            delegate: SliverChildListDelegate([
              // 基本设置
              _buildSettingsSection(
                title: '🔔 基本设置',
                children: [
                  _buildSwitchTile(
                    title: '启用提醒',
                    subtitle: '开启或关闭所有提醒功能',
                    value: _globalRemindersEnabled,
                    onChanged: (value) async {
                      await _reminderService.setGlobalRemindersEnabled(value);
                      setState(() {
                        _globalRemindersEnabled = value;
                      });
                    },
                  ),
                  _buildTile(
                    title: '默认提醒时间',
                    subtitle: _reminderService.minutesToTimeString(_defaultReminderTime),
                    onTap: _showDefaultTimeDialog,
                  ),
                  _buildTile(
                    title: '默认提醒类型',
                    subtitle: _getTypeDisplayText(_defaultReminderType),
                    onTap: _showDefaultTypeDialog,
                  ),
                ],
              ),
/*
              // 提醒方式
              _buildSettingsSection(
                title: '📳 提醒方式',
                children: [
                  _buildSwitchTile(
                    title: '声音提醒',
                    subtitle: '播放提醒音效',
                    value: _soundEnabled,
                    onChanged: (value) async {
                      await _reminderService.setSoundEnabled(value);
                      setState(() {
                        _soundEnabled = value;
                      });
                    },
                  ),
                  _buildSwitchTile(
                    title: '振动提醒',
                    subtitle: '振动设备进行提醒',
                    value: _vibrationEnabled,
                    onChanged: (value) async {
                      await _reminderService.setVibrationEnabled(value);
                      setState(() {
                        _vibrationEnabled = value;
                      });
                    },
                  ),
                  _buildTile(
                    title: '提前提醒',
                    subtitle: '提前 $_advanceNotificationMinutes 分钟提醒',
                    onTap: _showAdvanceTimeDialog,
                  ),
                ],
              ),

              // 高级设置
              _buildSettingsSection(
                title: '⚙️ 高级设置',
                children: [
                  _buildSwitchTile(
                    title: '周末提醒',
                    subtitle: '在周末也发送提醒',
                    value: _weekendRemindersEnabled,
                    onChanged: (value) async {
                      await _reminderService.setWeekendRemindersEnabled(value);
                      setState(() {
                        _weekendRemindersEnabled = value;
                      });
                    },
                  ),
                  _buildTile(
                    title: '勿扰时段',
                    subtitle: _getDoNotDisturbDisplayText(),
                    onTap: _showDoNotDisturbDialog,
                  ),
                ],
              ),

              // 提醒管理
              _buildSettingsSection(
                title: '📝 提醒管理',
                children: [
                  _buildTile(
                    title: '查看所有提醒',
                    subtitle: '管理已创建的提醒',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AllRemindersPage(),
                        ),
                      );
                    },
                  ),
                  _buildTile(
                    title: '创建新提醒',
                    subtitle: '添加新的提醒事项',
                    onTap: () {
                      _showCreateReminderDialog();
                    },
                  ),
                ],
              ),
              */

              SizedBox(height: 100.h), // Bottom padding
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
            child: Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.bodyLarge,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            )
          : null,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.bodyLarge,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
    );
  }

  String _getTypeDisplayText(ReminderType type) {
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

  String _getDoNotDisturbDisplayText() {
    if (_doNotDisturbStartTime == null || _doNotDisturbEndTime == null) {
      return '未设置';
    }
    return '${_reminderService.minutesToTimeString(_doNotDisturbStartTime!)} - ${_reminderService.minutesToTimeString(_doNotDisturbEndTime!)}';
  }

  Future<void> _showDefaultTimeDialog() async {
    final TimeOfDay initialTime = TimeOfDay(
      hour: _defaultReminderTime ~/ 60,
      minute: _defaultReminderTime % 60,
    );

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      final minutes = pickedTime.hour * 60 + pickedTime.minute;
      await _reminderService.setDefaultReminderTime(minutes);
      setState(() {
        _defaultReminderTime = minutes;
      });
    }
  }

  Future<void> _showDefaultTypeDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('默认提醒类型', style: AppTextStyles.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ReminderType.values.map((type) {
              return RadioListTile<ReminderType>(
                title: Text(_getTypeDisplayText(type)),
                value: type,
                groupValue: _defaultReminderType,
                onChanged: (value) async {
                  await _reminderService.setDefaultReminderType(value!);
                  setState(() {
                    _defaultReminderType = value;
                  });
                  if (mounted) Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _showAdvanceTimeDialog() async {
    int tempMinutes = _advanceNotificationMinutes;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('提前提醒时间', style: AppTextStyles.titleMedium),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('提前 $tempMinutes 分钟提醒'),
                  SizedBox(height: 16.h),
                  Slider(
                    value: tempMinutes.toDouble(),
                    min: 0,
                    max: 60,
                    divisions: 12,
                    label: '$tempMinutes 分钟',
                    onChanged: (value) {
                      setState(() {
                        tempMinutes = value.round();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      await _reminderService.setAdvanceNotificationMinutes(tempMinutes);
      setState(() {
        _advanceNotificationMinutes = tempMinutes;
      });
    }
  }

  Future<void> _showDoNotDisturbDialog() async {
    TimeOfDay? startTime = _doNotDisturbStartTime != null
        ? TimeOfDay(
            hour: _doNotDisturbStartTime! ~/ 60,
            minute: _doNotDisturbStartTime! % 60,
          )
        : null;
    TimeOfDay? endTime = _doNotDisturbEndTime != null
        ? TimeOfDay(
            hour: _doNotDisturbEndTime! ~/ 60,
            minute: _doNotDisturbEndTime! % 60,
          )
        : null;

    final result = await showDialog<Map<String, TimeOfDay?>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('勿扰时段设置', style: AppTextStyles.titleMedium),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('开始时间'),
                    subtitle: Text(startTime?.format(context) ?? '未设置'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: startTime ?? const TimeOfDay(hour: 22, minute: 0),
                      );
                      if (time != null) {
                        setState(() {
                          startTime = time;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('结束时间'),
                    subtitle: Text(endTime?.format(context) ?? '未设置'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: endTime ?? const TimeOfDay(hour: 7, minute: 0),
                      );
                      if (time != null) {
                        setState(() {
                          endTime = time;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        startTime = null;
                        endTime = null;
                      });
                    },
                    child: const Text('清除勿扰时段'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, {
                    'start': startTime,
                    'end': endTime,
                  }),
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      final start = result['start'];
      final end = result['end'];
      
      int? startMinutes = start != null ? start.hour * 60 + start.minute : null;
      int? endMinutes = end != null ? end.hour * 60 + end.minute : null;
      
      await _reminderService.setDoNotDisturbTime(startMinutes, endMinutes);
      setState(() {
        _doNotDisturbStartTime = startMinutes;
        _doNotDisturbEndTime = endMinutes;
      });
    }
  }

  Future<void> _showCreateReminderDialog() async {
    // TODO: 实现创建提醒对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('创建提醒功能开发中...')),
    );
  }
}

// 所有提醒页面（占位符）
class AllRemindersPage extends StatelessWidget {
  const AllRemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('所有提醒'),
      ),
      body: const Center(
        child: Text('提醒列表功能开发中...'),
      ),
    );
  }
}