import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/business_profile_page.dart';

import '../../../../../helpers/pump_app.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class MockSmeProfileCubit extends Mock implements SmeProfileCubit {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockSmeProfileCubit mockSmeCubit;

  setUpAll(() {
    registerFallbackValue(AuthInitial());
    registerFallbackValue(SmeProfileState());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockSmeCubit = MockSmeProfileCubit();

    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockSmeCubit.state).thenReturn(SmeProfileState());
    when(() => mockSmeCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  group('BusinessProfilePage Golden Tests', () {
    testGoldens('BusinessProfilePage - Empty State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(
          const BusinessProfilePage(),
          authBloc: mockAuthBloc,
          smeProfileCubit: mockSmeCubit,
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'business_profile_page_empty');
    });
  });
}
