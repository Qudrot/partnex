import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:partnex/features/auth/presentation/pages/splash_page.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('SplashPage Golden Tests', () {
    testGoldens('SplashPage', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(const SplashPage()),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'splash_page_empty', customPump: (tester) async {
        await tester.pump(const Duration(milliseconds: 100));
      });

      // Unmount the widget and advance time to clear pending Future.delayed and animations
      await tester.pumpWidgetBuilder(Container(), surfaceSize: const Size(393, 852));
      await tester.pumpAndSettle(const Duration(seconds: 6));
    });
  });
}
