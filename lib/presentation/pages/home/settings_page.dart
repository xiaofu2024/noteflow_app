import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import '../../../core/services/user_preferences_service.dart';
import '../../../core/services/theme_manager.dart';
import '../../../core/services/biometric_auth_service.dart';
import '../../../core/services/data_export_service.dart';
import '../../../core/services/note_color_service.dart';
import '../../../core/services/reminder_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../settings/webview_page.dart';
import '../settings/reminder_settings_page.dart';
import '../../widgets/note_color_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late UserPreferencesService _prefsService;
  late ThemeManager _themeManager;
  late BiometricAuthService _biometricService;
  late DataExportService _exportService;
  late NoteColorService _colorService;
  late ReminderService _reminderService;
  bool _isLoading = true;
  
  // Settings values
  bool _biometricEnabled = false;
  bool _autoSyncEnabled = true;
  bool _notificationsEnabled = true;
  String _selectedTheme = 'System';
  String _userName = '盛华用户';
  String _userEmail = 'user@noteflow.com';
  double _fontSize = 14.0;
  String _noteViewMode = 'grid';
  int? _defaultNoteColor;

  @override
  void initState() {
    super.initState();
    _prefsService = GetIt.instance<UserPreferencesService>();
    _themeManager = GetIt.instance<ThemeManager>();
    _biometricService = GetIt.instance<BiometricAuthService>();
    _exportService = GetIt.instance<DataExportService>();
    _colorService = GetIt.instance<NoteColorService>();
    _reminderService = GetIt.instance<ReminderService>();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _biometricEnabled = _prefsService.biometricEnabled;
      _autoSyncEnabled = _prefsService.autoSyncEnabled;
      _notificationsEnabled = _prefsService.notificationsEnabled;
      _selectedTheme = _prefsService.selectedTheme;
      _userName = _prefsService.userName;
      _userEmail = _prefsService.userEmail;
      _fontSize = _prefsService.fontSize;
      _noteViewMode = _prefsService.noteViewMode;
      _defaultNoteColor = _colorService.defaultNoteColor;
      _isLoading = false;
    });
  }

  Future<void> _showExportDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('数据导出', style: AppTextStyles.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.storage_rounded),
                title: const Text('完整数据备份'),
                subtitle: const Text('导出所有笔记和设置'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAllData();
                },
              ),
              ListTile(
                leading: const Icon(Icons.note_rounded),
                title: const Text('仅导出笔记'),
                subtitle: const Text('只导出笔记内容'),
                onTap: () {
                  Navigator.pop(context);
                  _showNotesExportFormatDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_rounded),
                title: const Text('导出设置'),
                subtitle: const Text('选择导出格式'),
                onTap: () {
                  Navigator.pop(context);
                  _showExportFormatDialog();
                },
              ),
             if (kDebugMode) ListTile(
                leading: const Icon(Icons.bug_report_rounded),
                title: const Text('文件系统诊断'),
                subtitle: const Text('检查文件导出权限'),
                onTap: () {
                  Navigator.pop(context);
                  _showFileSystemDiagnosis();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showExportFormatDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('选择导出格式', style: AppTextStyles.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.code_rounded),
                title: const Text('JSON格式 ✓'),
                subtitle: const Text('结构化数据，可用于导入备份'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAllData(format: ExportFormat.json);
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_rounded),
                title: const Text('文本格式'),
                subtitle: const Text('纯文本，便于阅读（仅用于查看）'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAllData(format: ExportFormat.txt);
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_rounded),
                title: const Text('CSV格式'),
                subtitle: const Text('表格数据，便于Excel处理（仅用于查看）'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAllData(format: ExportFormat.csv);
                },
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '💡 提示：只有JSON格式可以用于恢复备份，文本和CSV格式仅用于查看和分享',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNotesExportFormatDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('选择导出格式', style: AppTextStyles.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.code_rounded),
                title: const Text('JSON格式 ✓'),
                subtitle: const Text('结构化数据，可用于导入备份'),
                onTap: () {
                  Navigator.pop(context);
                  _exportNotesOnly(format: ExportFormat.json);
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_rounded),
                title: const Text('文本格式'),
                subtitle: const Text('纯文本，便于阅读（仅用于查看）'),
                onTap: () {
                  Navigator.pop(context);
                  _exportNotesOnly(format: ExportFormat.txt);
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_rounded),
                title: const Text('CSV格式'),
                subtitle: const Text('表格数据，便于Excel处理（仅用于查看）'),
                onTap: () {
                  Navigator.pop(context);
                  _exportNotesOnly(format: ExportFormat.csv);
                },
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '💡 提示：只有JSON格式可以用于恢复备份，文本和CSV格式仅用于查看和分享',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportAllData({ExportFormat format = ExportFormat.json}) async {
    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('正在导出数据...'),
            ],
          ),
        ),
      );

      final result = await _exportService.exportAllData(format: format);
      
      // 关闭加载对话框
      if (mounted) Navigator.pop(context);

      if (result == ExportResult.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('数据导出成功'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('数据导出失败，请检查设备存储空间或权限'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      // 关闭加载对话框
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _exportNotesOnly({ExportFormat format = ExportFormat.json}) async {
    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('正在导出笔记...'),
            ],
          ),
        ),
      );

      final result = await _exportService.exportNotesOnly(format: format);
      
      // 关闭加载对话框
      if (mounted) Navigator.pop(context);

      if (result == ExportResult.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('笔记导出成功'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('笔记导出失败，请检查设备存储空间或权限'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      // 关闭加载对话框
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _showProfileEditDialog() async {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('编辑个人资料', style: AppTextStyles.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '姓名',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
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

    if (result == true) {
      await _prefsService.setUserName(nameController.text.trim());
      await _prefsService.setUserEmail(emailController.text.trim());
      _loadSettings();
    }
  }

  Future<void> _toggleBiometricLock(bool value) async {
    if (value) {
      // 启用生物识别锁，需要先验证
      final status = await _biometricService.checkBiometricStatus();
      
      if (status != BiometricStatus.available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_biometricService.getBiometricStatusDescription(status)),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      final authResult = await _biometricService.authenticate(
        localizedReason: '验证身份以启用生物识别锁',
      );
      
      if (authResult == AuthenticationStatus.authenticated) {
        await _prefsService.setBiometricEnabled(true);
        setState(() {
          _biometricEnabled = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('生物识别锁已启用'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_biometricService.getAuthenticationStatusDescription(authResult)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // 禁用生物识别锁
      await _prefsService.setBiometricEnabled(false);
      setState(() {
        _biometricEnabled = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('生物识别锁已禁用'),
          ),
        );
      }
    }
  }

  Future<void> _showFontSizeDialog() async {
    double tempFontSize = _fontSize;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('字体大小', style: AppTextStyles.titleMedium),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '示例文本',
                    style: TextStyle(fontSize: tempFontSize.sp),
                  ),
                  SizedBox(height: 16.h),
                  Slider(
                    value: tempFontSize,
                    min: 12.0,
                    max: 20.0,
                    divisions: 8,
                    label: '${tempFontSize.toStringAsFixed(0)}sp',
                    onChanged: (value) {
                      setState(() {
                        tempFontSize = value;
                      });
                    },
                  ),
                  Text(
                    '${tempFontSize.toStringAsFixed(0)}sp',
                    style: AppTextStyles.bodySmall,
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
      await _prefsService.setFontSize(tempFontSize);
      _loadSettings();
    }
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
              '设置',
              style: AppTextStyles.appBarTitle,
            ),
          ),

          // User Profile Section
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(20.w),
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
              child: Row(
                children: [
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: AppTextStyles.titleLarge,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _userEmail,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _showProfileEditDialog,
                    icon: Icon(
                      Icons.edit_rounded,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Settings Sections
          SliverList(
            delegate: SliverChildListDelegate([
              _buildSettingsSection(
                title: '🔒 安全与隐私',
                children: [
                  _buildSwitchTile(
                    title: '生物识别锁',
                    subtitle: '使用指纹或Face ID解锁',
                    value: _biometricEnabled,
                    onChanged: (value) async {
                      await _toggleBiometricLock(value);
                    },
                  ),
                 /* _buildTile(
                    title: '密码保护笔记',
                    subtitle: '管理受密码保护的笔记',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('密码管理功能开发中...')),
                      );
                    },
                  ),*/
                  _buildTile(
                    title: '数据导出',
                    subtitle: '导出您的笔记和设置数据',
                    onTap: _showExportDialog,
                  ),
                ],
              ),

              _buildSettingsSection(
                title: '🎨 外观设置',
                children: [
                  _buildTile(
                    title: '主题',
                    subtitle: _selectedTheme,
                    onTap: () {
                      _showThemeDialog();
                    },
                  ),
                  _buildTile(
                    title: '字体大小',
                    subtitle: '${_fontSize.toStringAsFixed(0)}sp',
                    onTap: _showFontSizeDialog,
                  ),
                  _buildTile(
                    title: '笔记视图',
                    subtitle: _noteViewMode == 'grid' ? '网格视图' : '列表视图',
                    onTap: () {
                      _showViewModeDialog();
                    },
                  ),
                  _buildTile(
                    title: '默认笔记颜色',
                    subtitle: _defaultNoteColor != null 
                        ? NoteColorUtils.getColorName(_defaultNoteColor)
                        : '跟随系统',
                    onTap: () {
                      _showNoteColorDialog();
                    },
                  ),
                  // _buildTile(
                  //   title: '颜色预设管理',
                  //   subtitle: '查看和管理笔记颜色预设',
                  //   onTap: () {
                  //     _showColorPresetsDialog();
                  //   },
                  // ),
                ],
              ),

              _buildSettingsSection(
                title: '☁️ 同步与备份',
                children: [
                  /*_buildSwitchTile(
                    title: '云端同步',
                    subtitle: '自动在设备间同步',
                    value: _autoSyncEnabled,
                    onChanged: (value) async {
                      await _prefsService.setAutoSyncEnabled(value);
                      setState(() {
                        _autoSyncEnabled = value;
                      });
                    },
                  ),*/
                  _buildTile(
                    title: '恢复备份',
                    subtitle: '从备份文件恢复数据',
                    onTap: () {
                      _showRestoreBackupDialog();
                    },
                  ),
                  _buildTile(
                    title: '存储使用情况',
                    subtitle: '查看存储和使用详情',
                    onTap: () {
                      _showStorageDialog();
                    },
                  ),
                ],
              ),

              _buildSettingsSection(
                title: '🔔 通知',
                children: [
                  _buildSwitchTile(
                    title: '推送通知',
                    subtitle: '接收提醒和更新',
                    value: _notificationsEnabled,
                    onChanged: (value) async {
                      await _prefsService.setNotificationsEnabled(value);
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                  _buildTile(
                    title: '提醒设置',
                    subtitle: _reminderService.globalRemindersEnabled 
                        ? '已启用提醒功能' 
                        : '已禁用提醒功能',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ReminderSettingsPage(),
                        ),
                      ).then((_) {
                        // 回到设置页面时刷新状态
                        _loadSettings();
                      });
                    },
                  ),
                ],
              ),

              _buildSettingsSection(
                title: '📱 关于',
                children: [
                  _buildTile(
                    title: '应用版本',
                    subtitle: '1.0.0 (Build 1)',
                    onTap: null,
                  ),
                  _buildTile(
                    title: '隐私政策',
                    subtitle: '查看我们的隐私政策',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WebViewPage(
                            title: '隐私政策',
                            url: 'https://shl-api.weletter01.com/private-protocol/privacy_policy.html',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildTile(
                    title: '服务条款',
                    subtitle: '查看服务条款',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WebViewPage(
                            title: '服务条款',
                            url: 'https://shl-api.weletter01.com/private-protocol/user_agreement.html',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildTile(
                    title: '联系支持',
                    subtitle: '获取帮助和报告问题',
                    onTap: () {
                      _showContactDialog();
                    },
                  ),
                  _buildTile(
                    title: '为应用评分',
                    subtitle: '在App Store上为我们评分',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('谢谢您的支持！')),
                      );
                    },
                  ),
                ],
              ),

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

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '选择主题',
            style: AppTextStyles.titleMedium,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('跟随系统'),
                value: 'System',
                groupValue: _selectedTheme,
                onChanged: (value) async {
                  await _themeManager.setThemeMode(value!);
                  setState(() {
                    _selectedTheme = value;
                  });
                  if (mounted) Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('浅色'),
                value: 'Light',
                groupValue: _selectedTheme,
                onChanged: (value) async {
                  await _themeManager.setThemeMode(value!);
                  setState(() {
                    _selectedTheme = value;
                  });
                  if (mounted) Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('深色'),
                value: 'Dark',
                groupValue: _selectedTheme,
                onChanged: (value) async {
                  await _themeManager.setThemeMode(value!);
                  setState(() {
                    _selectedTheme = value;
                  });
                  if (mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showViewModeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '笔记视图',
            style: AppTextStyles.titleMedium,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('网格视图'),
                value: 'grid',
                groupValue: _noteViewMode,
                onChanged: (value) async {
                  await _prefsService.setNoteViewMode(value!);
                  setState(() {
                    _noteViewMode = value;
                  });
                  if (mounted) Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('列表视图'),
                value: 'list',
                groupValue: _noteViewMode,
                onChanged: (value) async {
                  await _prefsService.setNoteViewMode(value!);
                  setState(() {
                    _noteViewMode = value;
                  });
                  if (mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStorageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('存储使用情况', style: AppTextStyles.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStorageItem('笔记数据', '2.4 MB'),
              _buildStorageItem('附件', '1.2 MB'),
              _buildStorageItem('设置', '0.1 MB'),
              const Divider(),
              _buildStorageItem('总计', '3.7 MB', bold: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStorageItem(String label, String size, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            size,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _showNoteColorDialog() async {
    final selectedColor = await showDialog<int?>(
      context: context,
      builder: (context) => NoteColorPickerDialog(
        initialColor: _defaultNoteColor,
        title: '默认笔记颜色',
        showDefaultOption: true,
      ),
    );

    if (selectedColor != null || selectedColor == null) {
      await _colorService.setDefaultNoteColor(selectedColor);
      setState(() {
        _defaultNoteColor = selectedColor;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              selectedColor != null 
                  ? '已设置默认颜色为${NoteColorUtils.getColorName(selectedColor)}'
                  : '已重置为默认颜色'
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _showColorPresetsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('颜色预设管理', style: AppTextStyles.titleMedium),
          content: SizedBox(
            width: double.maxFinite,
            height: 400.h,
            child: _buildColorPresetsList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorPresetsList() {
    final presets = _colorService.getColorPresets();
    final stats = _colorService.getColorUsageStats();
    
    return ListView.builder(
      shrinkWrap: true,
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final entry = presets.entries.elementAt(index);
        final preset = ColorPreset.fromJson(entry.key, entry.value);
        final usageCount = stats[preset.color] ?? 0;
        
        return ListTile(
          leading: Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: preset.colorValue,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          title: Text(
            preset.name,
            style: AppTextStyles.bodyMedium,
          ),
          subtitle: Text(
            '$usageCount 个笔记使用',
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: 实现编辑颜色预设功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('编辑预设功能开发中...')),
              );
            },
          ),
        );
      },
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('联系支持', style: AppTextStyles.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('邮箱支持'),
                subtitle: const Text('support@noteflow.com'),
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: 'support@noteflow.com'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('邮箱地址已复制')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report),
                title: const Text('报告问题'),
                subtitle: const Text('反馈使用中的问题'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('谢谢您的反馈！')),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRestoreBackupDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('恢复备份', style: AppTextStyles.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.restore_rounded),
                title: const Text('恢复完整备份'),
                subtitle: const Text('恢复笔记和设置数据'),
                onTap: () {
                  Navigator.pop(context);
                  _restoreFullBackup();
                },
              ),
              ListTile(
                leading: const Icon(Icons.note_add_rounded),
                title: const Text('仅恢复笔记'),
                subtitle: const Text('只恢复笔记内容'),
                onTap: () {
                  Navigator.pop(context);
                  _restoreNotesOnly();
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_rounded),
                title: const Text('仅恢复设置'),
                subtitle: const Text('只恢复应用设置和偏好'),
                onTap: () {
                  Navigator.pop(context);
                  _restoreSettingsOnly();
                },
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      '⚠️ 重要提醒',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '• 恢复备份会覆盖现有数据，建议先导出当前数据\n• 仅支持导入JSON格式的备份文件\n• 可选择恢复完整备份、仅笔记或仅设置',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.orange.shade600,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _restoreFullBackup() async {
    // 显示确认对话框
    final confirmed = await _showRestoreConfirmDialog(
      title: '确认恢复完整备份',
      content: '这将替换您现有的所有笔记和设置。此操作无法撤销。',
    );

    if (!confirmed) return;

    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('正在恢复备份...'),
            ],
          ),
        ),
      );

      final result = await _exportService.pickAndImportBackupFile(
        replaceExisting: true,
        importSettings: true,
        importNotes: true,
      );

      // 关闭加载对话框
      if (mounted) Navigator.pop(context);

      if (mounted) {
        final message = _exportService.getImportResultDescription(result);
        final isSuccess = result == ImportResult.success;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );

        if (isSuccess) {
          // 重新加载设置以反映导入的更改
          _loadSettings();
        }
      }
    } catch (e) {
      // 关闭加载对话框
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('恢复失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restoreNotesOnly() async {
    // 显示确认对话框
    final confirmed = await _showRestoreConfirmDialog(
      title: '确认恢复笔记',
      content: '这将添加或替换您的笔记数据。重复的笔记会被覆盖。',
    );

    if (!confirmed) return;

    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('正在恢复笔记...'),
            ],
          ),
        ),
      );

      final result = await _exportService.pickAndImportNotesFile(
        replaceExisting: true,
      );

      // 关闭加载对话框
      if (mounted) Navigator.pop(context);

      if (mounted) {
        final message = _exportService.getImportResultDescription(result);
        final isSuccess = result == ImportResult.success;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      // 关闭加载对话框
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('恢复失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restoreSettingsOnly() async {
    // 显示确认对话框
    final confirmed = await _showRestoreConfirmDialog(
      title: '确认恢复设置',
      content: '这将替换您现有的应用设置和偏好配置。笔记内容不会受到影响。',
    );

    if (!confirmed) return;

    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('正在恢复设置...'),
            ],
          ),
        ),
      );

      final result = await _exportService.pickAndImportBackupFile(
        replaceExisting: true,
        importSettings: true,
        importNotes: false, // 只恢复设置，不恢复笔记
      );

      // 关闭加载对话框
      if (mounted) Navigator.pop(context);

      if (mounted) {
        final message = _exportService.getImportResultDescription(result);
        final isSuccess = result == ImportResult.success;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );

        if (isSuccess) {
          // 重新加载设置以反映导入的更改
          _loadSettings();
        }
      }
    } catch (e) {
      // 关闭加载对话框
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('恢复失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showRestoreConfirmDialog({
    required String title,
    required String content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: AppTextStyles.titleMedium),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('确认恢复'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _showFileSystemDiagnosis() async {
    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('正在诊断文件系统...'),
          ],
        ),
      ),
    );

    try {
      final diagnosis = await _exportService.diagnosisFileSystem();
      
      // 关闭加载对话框
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('文件系统诊断结果', style: AppTextStyles.titleMedium),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('诊断状态: ${diagnosis['diagnosis_success'] ? '✅ 成功' : '❌ 失败'}'),
                    SizedBox(height: 8.h),
                    if (diagnosis['temp_directory'] != null) ...[
                      Text('临时目录: ${diagnosis['temp_directory']}'),
                      Text('目录存在: ${diagnosis['temp_directory_exists'] ? '✅' : '❌'}'),
                      SizedBox(height: 8.h),
                    ],
                    if (diagnosis['file_creation'] != null) ...[
                      Text('文件创建: ${diagnosis['file_creation'] ? '✅' : '❌'}'),
                      if (diagnosis['file_size'] != null)
                        Text('文件大小: ${diagnosis['file_size']} bytes'),
                      SizedBox(height: 8.h),
                    ],
                    if (diagnosis['error'] != null) ...[
                      Text('错误信息:', style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      )),
                      Text('${diagnosis['error']}', style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.red,
                      )),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('关闭'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // 关闭加载对话框
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('诊断失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}