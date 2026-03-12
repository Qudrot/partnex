import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:partnex/features/auth/presentation/pages/investor/investor_full_bio_page.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('InvestorFullBioPage Golden Tests', () {
    testGoldens('InvestorFullBioPage - Loaded State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(
          const InvestorFullBioPage(
            smeName: 'Optik Tech',
            bio: 'Optik Tech is a forward-thinking software development agency specializing in AI and distributed systems.',
            contactPersonName: 'John Doe',
            contactPersonTitle: 'CEO',
            email: 'john.doe@optik.tech',
            phoneNumber: '+1234567890',
            website: 'www.optik.tech',
            linkedinUrl: 'linkedin.com/optik',
            whatsappNumber: '+1234567890',
            twitterHandle: '@optiktech',
          ),
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'investor_full_bio_page_loaded');
    });
  });
}
