import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_state.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/credibility_dashboard_page.dart';
import 'package:partnex/features/auth/data/models/credibility_score.dart';
import 'package:partnex/features/auth/data/models/financial_metrics.dart';

import '../../../../../helpers/pump_app.dart';

class MockScoreCubit extends Mock implements ScoreCubit {}
class MockSmeProfileCubit extends Mock implements SmeProfileCubit {}

void main() {
  late MockScoreCubit mockScoreCubit;
  late MockSmeProfileCubit mockSmeProfileCubit;

  setUpAll(() {
    registerFallbackValue(ScoreInitial());
    registerFallbackValue(const SmeProfileState());
  });

  setUp(() {
    mockScoreCubit = MockScoreCubit();
    mockSmeProfileCubit = MockSmeProfileCubit();

    when(() => mockScoreCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockScoreCubit.fetchDashboardData()).thenAnswer((_) async {});
    when(() => mockSmeProfileCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSmeProfileCubit.state).thenReturn(const SmeProfileState());
  });

  group('CredibilityDashboardPage Golden Tests', () {
    testGoldens('CredibilityDashboard - Empty State (ScoreInitial)', (tester) async {
      when(() => mockScoreCubit.state).thenReturn(ScoreInitial());

      await tester.pumpWidgetBuilder(
        pumpApp(
          const CredibilityDashboardPage(),
          scoreCubit: mockScoreCubit,
          smeProfileCubit: mockSmeProfileCubit,
        ),
        surfaceSize: const Size(393, 852),
      );
      await screenMatchesGolden(tester, 'dashboard_empty_state');
    });

    testGoldens('CredibilityDashboard - Loading State', (tester) async {
      when(() => mockScoreCubit.state).thenReturn(ScoreLoading());

      await tester.pumpWidgetBuilder(
        pumpApp(
          const CredibilityDashboardPage(),
          scoreCubit: mockScoreCubit,
          smeProfileCubit: mockSmeProfileCubit,
        ),
        surfaceSize: const Size(393, 852),
      );
      // We often ignore loading animations in goldens to avoid flakiness,
      // but golden_toolkit freezes animations by default.
      await screenMatchesGolden(tester, 'dashboard_loading_state', customPump: (tester) async {
        await tester.pump(const Duration(seconds: 1));
      });
    });

    testGoldens('CredibilityDashboard - Success State (Populated)', (tester) async {
      final mockScore = CredibilityScore(
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
          ScoreDriver(name: 'Expense Management', scoreValue: 70, status: MetricStatus.moderate, rawDisplayValue: '55%', weight: 0.3),
          ScoreDriver(name: 'Profitability', scoreValue: 90, status: MetricStatus.positive, rawDisplayValue: '20%', weight: 0.3),
        ],
      );

      when(() => mockScoreCubit.state).thenReturn(ScoreLoadedSuccess(
        score: mockScore,
        financialMetrics: mockMetrics,
        smeProfile: const {},
      ));

      await tester.pumpWidgetBuilder(
        pumpApp(
          const CredibilityDashboardPage(),
          scoreCubit: mockScoreCubit,
          smeProfileCubit: mockSmeProfileCubit,
        ),
        surfaceSize: const Size(393, 852),
      );
      await screenMatchesGolden(tester, 'dashboard_success_state');
    });

    testGoldens('CredibilityDashboard - BottomSheet State', (tester) async {
      final mockScore = CredibilityScore(
        id: '123',
        organisationId: '456',
        totalScore: 785.0,
        riskLevel: RiskLevel.low,
        topContributingFactors: const [],
        modelVersion: '1.0',
        impactScore: 0.85,
        calculatedAt: DateTime(2026, 3, 11, 10, 0),
      );

      when(() => mockScoreCubit.state).thenReturn(ScoreLoadedSuccess(
        score: mockScore,
        smeProfile: const {},
      ));

      await tester.pumpWidgetBuilder(
        pumpApp(
          const CredibilityDashboardPage(),
          scoreCubit: mockScoreCubit,
          smeProfileCubit: mockSmeProfileCubit,
        ),
        surfaceSize: const Size(393, 852),
      );

      final applyBtn = find.text('Apply for Funding');
      await tester.ensureVisible(applyBtn);
      await tester.tap(applyBtn);
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'dashboard_bottomsheet_state');
    });
  });
}
