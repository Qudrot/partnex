// Smoke test for the Partnex app.
// Uses TestDefaultBinaryMessengerBinding to handle native plugin calls
// from packages like flutter_secure_storage which require a method-channel mock.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:partnex/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Mock flutter_secure_storage platform channel to avoid MissingPluginException
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'read') return null;
            if (methodCall.method == 'write') return null;
            if (methodCall.method == 'delete') return null;
            if (methodCall.method == 'readAll') return {};
            if (methodCall.method == 'containsKey') return false;
            return null;
          },
        );
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build the app and trigger initial frame
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Verify the app tree contains a MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
