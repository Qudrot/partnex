import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_state.dart';
import 'package:partnex/features/auth/data/models/credibility_score.dart';
import 'package:partnex/features/auth/data/models/financial_metrics.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/profile_management_page.dart';

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

    when(() => mockSmeCubit.state).thenReturn(SmeProfileState(
      businessName: 'Mock Business SME',
      industry: 'Technology',
      bio: 'We are a fast growing tech company in Lagos.',
    ));
    when(() => mockSmeCubit.stream).thenAnswer((_) => const Stream.empty());

    final mockScoreData = CredibilityScore(
      id: '123',
      organisationId: '456',
      totalScore: 785.0,
      riskLevel: RiskLevel.low,
      topContributingFactors: const [],
      modelVersion: '1.0',
      impactScore: 0.85,
      calculatedAt: DateTime(2026, 3, 11, 10, 0),
    );

    final mockMetrics = FinancialMetrics(
      yoyGrowth: 25.0,
      expenseRatio: 55.0,
      profitMargin: 20.0,
      cagr: 15.0,
      revenuePerEmployee: 100000.0,
      liabilitiesToRevenueRatio: 0.1,
      monthlyProfit: 15000.0,
      debtServiceRatio: 0.2,
      liabilitiesPerEmployee: 10000.0,
      liabilitiesCoverageRatio: 2.5,
      yearsOfOperation: 5,
      employeesPerYear: 10.0,
      revenueGrowthPerEmployee: 5000.0,
      rankedDrivers: const [
        ScoreDriver(name: 'Revenue Growth', scoreValue: 85, status: MetricStatus.positive, rawDisplayValue: '25%', weight: 0.4),
      ],
    );

    when(() => mockScoreCubit.state).thenReturn(ScoreLoadedSuccess(score: mockScoreData, smeProfile: const {}, financialMetrics: mockMetrics));
    when(() => mockScoreCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  group('ProfileManagementPage Golden Tests', () {
    testGoldens('ProfileManagementPage - SME State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(
          const ProfileManagementPage(),
          authBloc: mockAuthBloc,
          smeProfileCubit: mockSmeCubit,
          scoreCubit: mockScoreCubit,
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'profile_management_page_sme');
    });
  });
}
