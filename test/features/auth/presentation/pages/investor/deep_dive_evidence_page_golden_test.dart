import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:partnex/features/auth/presentation/pages/investor/deep_dive_evidence_page.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('DeepDiveEvidencePage Golden Tests', () {
    testGoldens('DeepDiveEvidencePage - Loaded State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(
          const DeepDiveEvidencePage(),
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'deep_dive_evidence_page_loaded');
    });
  });
}
