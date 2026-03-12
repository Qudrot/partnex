import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/pages/investor/investor_onboarding_page.dart';

import '../../../../../helpers/pump_app.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(AuthInitial());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  group('InvestorOnboardingPage Golden Tests', () {
    testGoldens('InvestorOnboardingPage - Empty State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(const InvestorOnboardingPage(), authBloc: mockAuthBloc),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'investor_onboarding_page_empty');
    });

    testGoldens('InvestorOnboardingPage - Editing State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(const InvestorOnboardingPage(), authBloc: mockAuthBloc),
        surfaceSize: const Size(393, 852),
      );

      final individualOption = find.text('Individual Investor');
      await tester.ensureVisible(individualOption);
      await tester.tap(individualOption);
      await tester.pumpAndSettle();

      final techSector = find.text('Technology');
      await tester.ensureVisible(techSector);
      await tester.tap(techSector);
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'investor_onboarding_page_editing');
    });
  });
}
