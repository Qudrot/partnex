import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/bio_edit_page.dart';

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

  group('BioEditPage Golden Tests', () {
    testGoldens('BioEditPage - Empty State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(
          const BioEditPage(),
          smeProfileCubit: mockSmeCubit,
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'bio_edit_page_empty');
    });

    testGoldens('BioEditPage - Pre-filled State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(
          const BioEditPage(
            initialBio: 'We are a fast growing tech company in Lagos.',
            initialWebsite: 'https://example.com',
            initialWhatsapp: '+2348012345678',
            initialLinkedin: 'linkedin.com/in/example',
            initialTwitter: '@example',
          ),
          smeProfileCubit: mockSmeCubit,
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'bio_edit_page_filled');
    });
  });
}
