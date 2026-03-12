import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/review_confirm_page.dart';

import '../../../../../helpers/pump_app.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class MockSmeProfileCubit extends Mock implements SmeProfileCubit {}
class MockScoreCubit extends Mock implements ScoreCubit {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockSmeProfileCubit mockSmeCubit;
  late MockScoreCubit mockScoreCubit;

  setUpAll(() {
    registerFallbackValue(AuthInitial());
    registerFallbackValue(SmeProfileState());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockSmeCubit = MockSmeProfileCubit();
    mockScoreCubit = MockScoreCubit();

    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockScoreCubit.stream).thenAnswer((_) => const Stream.empty());

    final mockSmeState = SmeProfileState(
      businessName: 'Mock Business',
      industry: 'Technology',
      location: 'Lagos',
      yearsOfOperation: 3,
      numberOfEmployees: 10,
      annualRevenueYear1: 2023,
      annualRevenueAmount1: 5000000,
      annualRevenueYear2: 2024,
      annualRevenueAmount2: 7000000,
      monthlyAvgExpenses: 200000,
      totalLiabilities: 100000,
      outstandingLoans: 50000,
    );

    when(() => mockSmeCubit.state).thenReturn(mockSmeState);
    when(() => mockSmeCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  group('ReviewConfirmPage Golden Tests', () {
    testGoldens('ReviewConfirmPage - Loaded State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(
          const ReviewConfirmPage(),
          authBloc: mockAuthBloc,
          smeProfileCubit: mockSmeCubit,
          scoreCubit: mockScoreCubit,
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'review_confirm_page_loaded');
    });
  });
}
