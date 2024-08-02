import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bafia/main.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BafiaApp());

    // Verify that the app starts with a CircularProgressIndicator.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('App error state test', (WidgetTester tester) async {
    // Simulate an error in the FutureBuilder.
    await tester.pumpWidget(
      const BafiaApp(userData: null),
    );

    // Simulate the error state.
    await tester.pumpAndSettle();

    // Verify that the error message is displayed.
    expect(
        find.textContaining('Error initializing the database'), findsOneWidget);
  });

  testWidgets('App successful initialization test',
      (WidgetTester tester) async {
    // Simulate a successful database initialization.
    await tester.pumpWidget(
      const BafiaApp(userData: {'isDarkMode': true}),
    );

    // Simulate the successful state.
    await tester.pumpAndSettle();

    // Verify that the initial route is set correctly.
    expect(find.byType(GetMaterialApp), findsOneWidget);
    expect(find.text('Bafia'), findsOneWidget);
  });
}
