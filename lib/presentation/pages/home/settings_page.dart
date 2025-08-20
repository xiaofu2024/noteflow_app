import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _biometricEnabled = false;
  bool _autoSyncEnabled = true;
  bool _notificationsEnabled = true;
  String _selectedTheme = 'System';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
              'Settings',
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
                      color: AppColors.primary,
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
                          '西门吹雪',
                          style: AppTextStyles.titleLarge,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'john.doe@example.com',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Edit profile
                    },
                    icon: Icon(
                      Icons.edit_rounded,
                      size: 20.sp,
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
                title: '🔒 Security & Privacy',
                children: [
                  _buildSwitchTile(
                    title: 'Biometric Lock',
                    subtitle: 'Use fingerprint or Face ID to unlock',
                    value: _biometricEnabled,
                    onChanged: (value) {
                      setState(() {
                        _biometricEnabled = value;
                      });
                    },
                  ),
                  _buildTile(
                    title: 'Note Passwords',
                    subtitle: 'Manage password-protected notes',
                    onTap: () {
                      // TODO: Navigate to password management
                    },
                  ),
                  _buildTile(
                    title: 'Data Export',
                    subtitle: 'Export your notes and data',
                    onTap: () {
                      // TODO: Export data
                    },
                  ),
                ],
              ),

              _buildSettingsSection(
                title: '🎨 Appearance',
                children: [
                  _buildTile(
                    title: 'Theme',
                    subtitle: _selectedTheme,
                    onTap: () {
                      _showThemeDialog();
                    },
                  ),
                  _buildTile(
                    title: 'Note Colors',
                    subtitle: 'Customize note category colors',
                    onTap: () {
                      // TODO: Color customization
                    },
                  ),
                  _buildTile(
                    title: 'Font Settings',
                    subtitle: 'Adjust font size and family',
                    onTap: () {
                      // TODO: Font settings
                    },
                  ),
                ],
              ),

              _buildSettingsSection(
                title: '☁️ Sync & Backup',
                children: [
                  _buildSwitchTile(
                    title: 'Cloud Sync',
                    subtitle: 'Automatically sync across devices',
                    value: _autoSyncEnabled,
                    onChanged: (value) {
                      setState(() {
                        _autoSyncEnabled = value;
                      });
                    },
                  ),
                  _buildTile(
                    title: 'Backup Now',
                    subtitle: 'Manually backup your data',
                    onTap: () {
                      // TODO: Manual backup
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Backup started...')),
                      );
                    },
                  ),
                  _buildTile(
                    title: 'Storage Usage',
                    subtitle: 'View storage and usage details',
                    onTap: () {
                      // TODO: Storage details
                    },
                  ),
                ],
              ),

              _buildSettingsSection(
                title: '🔔 Notifications',
                children: [
                  _buildSwitchTile(
                    title: 'Push Notifications',
                    subtitle: 'Receive reminders and updates',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                  _buildTile(
                    title: 'Reminder Settings',
                    subtitle: 'Configure note reminders',
                    onTap: () {
                      // TODO: Reminder settings
                    },
                  ),
                ],
              ),

              _buildSettingsSection(
                title: '📱 About',
                children: [
                  _buildTile(
                    title: 'App Version',
                    subtitle: '1.0.0 (Build 1)',
                    onTap: null,
                  ),
                  _buildTile(
                    title: 'Privacy Policy',
                    subtitle: 'View our privacy policy',
                    onTap: () {
                      // TODO: Open privacy policy
                    },
                  ),
                  _buildTile(
                    title: 'Terms of Service',
                    subtitle: 'View terms and conditions',
                    onTap: () {
                      // TODO: Open terms
                    },
                  ),
                  _buildTile(
                    title: 'Contact Support',
                    subtitle: 'Get help and report issues',
                    onTap: () {
                      // TODO: Contact support
                    },
                  ),
                  _buildTile(
                    title: 'Rate App',
                    subtitle: 'Rate us on the App Store',
                    onTap: () {
                      // TODO: Open app store rating
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
            'Choose Theme',
            style: AppTextStyles.titleMedium,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('System'),
                value: 'System',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Light'),
                value: 'Light',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Dark'),
                value: 'Dark',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}