import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:noteflow_app/main.dart';
import 'package:noteflow_app/core/services/theme_manager.dart';
import 'package:noteflow_app/core/services/user_preferences_service.dart';

void main() {
  testWidgets('NoteFlow app smoke test', (WidgetTester tester) async {
    // Mock theme manager
    final mockPrefs = UserPreferencesService.instance;
    final mockThemeManager = ThemeManager(mockPrefs);
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(NoteFlowApp(themeManager: mockThemeManager));

    // Wait for splash screen animation to complete
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that we can find the app name or navigation
    expect(find.text('NoteFlow'), findsOneWidget);
  });
}
