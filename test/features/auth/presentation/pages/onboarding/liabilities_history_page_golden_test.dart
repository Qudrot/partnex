import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/liabilities_history_page.dart';

import '../../../../../helpers/pump_app.dart';

class MockSmeProfileCubit extends Mock implements SmeProfileCubit {}

void main() {
  late MockSmeProfileCubit mockSmeCubit;

  setUpAll(() {
    registerFallbackValue(SmeProfileState());
  });

  setUp(() {
    mockSmeCubit = MockSmeProfileCubit();
    when(() => mockSmeCubit.state).thenReturn(SmeProfileState());
    when(() => mockSmeCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  group('LiabilitiesHistoryPage Golden Tests', () {
    testGoldens('LiabilitiesHistoryPage - Empty State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(
          const LiabilitiesHistoryPage(),
          smeProfileCubit: mockSmeCubit,
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'liabilities_history_page_empty');
    });
  });
}
