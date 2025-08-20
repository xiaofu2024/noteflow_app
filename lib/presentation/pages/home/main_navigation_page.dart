import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'notes_page.dart';
import 'calendar_page.dart';
import 'search_page.dart';
import 'settings_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<NavigationTab> _tabs = [
    NavigationTab(
      icon: Icons.edit_note_rounded,
      activeIcon: Icons.edit_note_rounded,
      label: 'Notes',
    ),
    NavigationTab(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      label: 'Calendar',
    ),
    NavigationTab(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: 'Search',
    ),
    NavigationTab(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  final List<Widget> _pages = const [
    NotesPage(),
    CalendarPage(),
    SearchPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      // If tapping the same tab, scroll to top or refresh
      _handleSameTabTap();
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleSameTabTap() {
    // Handle double-tap on same tab (scroll to top, refresh, etc.)
    // This can be customized per tab
    switch (_currentIndex) {
      case 0: // Notes
        // Could scroll notes list to top
        break;
      case 1: // Calendar
        // Could go to today
        break;
      case 2: // Search
        // Could clear search
        break;
      case 3: // Settings
        // Could scroll to top
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.labelSmall,
          iconSize: 24.sp,
          elevation: 0,
          items: _tabs.map((tab) {
            final isActive = _tabs.indexOf(tab) == _currentIndex;
            return BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive ? tab.activeIcon : tab.icon,
                    key: ValueKey(isActive),
                    size: 24.sp,
                  ),
                ),
              ),
              label: tab.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NavigationTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}