import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_state.dart';
import 'package:partnex/features/auth/data/models/credibility_score.dart';
import 'package:partnex/features/auth/data/models/financial_metrics.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/score_drivers_detail_page.dart';

import '../../../../../helpers/pump_app.dart';

class MockScoreCubit extends Mock implements ScoreCubit {}

void main() {
  late MockScoreCubit mockScoreCubit;

  setUp(() {
    mockScoreCubit = MockScoreCubit();

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
        ScoreDriver(name: 'Revenue Consistency', scoreValue: 88, status: MetricStatus.positive, rawDisplayValue: '+15%', weight: 0.4),
        ScoreDriver(name: 'Profitability Margin', scoreValue: 70, status: MetricStatus.moderate, rawDisplayValue: '20%', weight: 0.3),
        ScoreDriver(name: 'Debt Service Coverage', scoreValue: 95, status: MetricStatus.positive, rawDisplayValue: '2.5x', weight: 0.3),
      ],
    );

    when(() => mockScoreCubit.state).thenReturn(ScoreLoadedSuccess(
      score: mockScoreData, 
      smeProfile: const {},
      financialMetrics: mockMetrics,
    ));
    when(() => mockScoreCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  group('ScoreDriversDetailPage Golden Tests', () {
    testGoldens('ScoreDriversDetailPage - Loaded State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(
          const ScoreDriversDetailPage(),
          scoreCubit: mockScoreCubit,
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'score_drivers_detail_page_loaded');
    });
  });
}
