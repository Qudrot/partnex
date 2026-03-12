import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:partnex/features/auth/presentation/pages/investor/comparison_watchlist_page.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ComparisonWatchlistPage Golden Tests', () {
    testGoldens('ComparisonWatchlistPage - Loaded State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(
          const ComparisonWatchlistPage(),
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'comparison_watchlist_page_loaded');
    });
  });
}
