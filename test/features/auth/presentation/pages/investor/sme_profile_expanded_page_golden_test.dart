import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:partnex/features/auth/data/models/sme_profile_data.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_profile_expanded_page.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('SmeProfileExpandedPage Golden Tests', () {
    testGoldens('SmeProfileExpandedPage - Loaded State', (tester) async {
      final mockSme = SmeCardData(
        id: '1',
        companyName: 'Acme Logistics',
        industry: 'Logistics',
        location: 'Lagos, Nigeria',
        score: 72,
        generatedAt: DateTime(2026, 3, 11),
        yearsOfOperation: 5,
        numberOfEmployees: 30,
        annualRevenue: 150000000.0,
        monthlyExpenses: 8000000.0,
        liabilities: 20000000.0,
        fundingHistory: 'Bootstrapped',
        riskLevel: 'MEDIUM',
        bio: 'Acme Logistics provides innovative supply chain solutions across West Africa.',
        website: 'www.acmelogistics.com',
      );

      await tester.pumpWidgetBuilder(
        pumpApp(
          SmeProfileExpandedPage(sme: mockSme),
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'sme_profile_expanded_page_loaded');
    });
  });
}
