import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bafia/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BafiaApp(
      initialRoute: '',
    ));

    // Verify that the app starts with a CircularProgressIndicator.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
