import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/welcome_role_selection_page.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('WelcomeRoleSelectionPage Golden Tests', () {
    testGoldens('WelcomeRoleSelectionPage - Empty State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(const WelcomeRoleSelectionPage()),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'welcome_role_selection_page_empty');
    });
  });
}
