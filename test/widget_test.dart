import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:noteflow_app/main.dart';

void main() {
  testWidgets('NoteFlow app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoteFlowApp());

    // Wait for splash screen animation to complete
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that we can find the app name or navigation
    expect(find.text('NoteFlow'), findsOneWidget);
  });
}
