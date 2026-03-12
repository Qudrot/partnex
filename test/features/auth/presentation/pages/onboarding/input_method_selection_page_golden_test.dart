import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/input_method_selection_page.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('InputMethodSelectionPage Golden Tests', () {
    testGoldens('InputMethodSelectionPage - Onboarding State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(const InputMethodSelectionPage(isUpdatingRecord: false)),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'input_method_selection_page_onboarding');
    });

    testGoldens('InputMethodSelectionPage - Updating state', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(const InputMethodSelectionPage(isUpdatingRecord: true)),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'input_method_selection_page_updating');
    });
  });
}
