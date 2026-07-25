import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mingla/main.dart';

void main() {
  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    // No native secure-storage implementation exists in the test harness, so
    // stub it to report "no saved session" — the same as a fresh install.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  testWidgets('shows the login screen when signed out', (tester) async {
    await tester.pumpWidget(const MinglaApp());
    await tester.pumpAndSettle();

    expect(find.text('Mingla'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Log in'), findsOneWidget);
    expect(find.text('New here? Create an account'), findsOneWidget);
  });

  testWidgets('navigates to the register screen', (tester) async {
    await tester.pumpWidget(const MinglaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();

    expect(find.text('Create your profile'), findsOneWidget);
  });
}
