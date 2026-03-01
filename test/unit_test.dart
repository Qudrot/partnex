import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';

void main() {
  group('SmeProfileCubit Unit Tests (Manual Mock)', () {
    late SmeProfileCubit smeProfileCubit;

    setUp(() {
      smeProfileCubit = SmeProfileCubit();
    });

    tearDown(() {
      smeProfileCubit.close();
    });

    test('initial state has empty defaults', () {
      expect(smeProfileCubit.state.businessName, '');
      expect(smeProfileCubit.state.annualRevenueAmount1, 0.0);
    });

    test('updates Revenue and Expenses accurately', () {
      smeProfileCubit.updateRevenueExpenses(
        annualRevenueYear1: 2021,
        annualRevenueAmount1: 100000,
        annualRevenueYear2: 2022,
        annualRevenueAmount2: 120000,
        annualRevenueYear3: 2023,
        annualRevenueAmount3: 150000,
        monthlyAvgRevenue: 12500,
        monthlyAvgExpenses: 8000,
      );

      final state = smeProfileCubit.state;
      expect(state.annualRevenueYear1, 2021);
      expect(state.annualRevenueAmount1, 100000.0);
      expect(state.annualRevenueYear2, 2022);
      expect(state.annualRevenueAmount2, 120000.0);
      
      expect(state.monthlyAvgExpenses, 8000.0);
    });

    test('updates Liabilities and History correctly', () {
      smeProfileCubit.updateLiabilitiesHistory(
        totalLiabilities: 50000,
        outstandingLoans: 0,
        priorFundingSource: 'Angel Investment',
        repaymentHistory: 'No missed payments',
      );

      final state = smeProfileCubit.state;
      expect(state.totalLiabilities, 50000.0);
      expect(state.priorFundingSource, 'Angel Investment');
      expect(state.repaymentHistory, 'No missed payments');
    });
  });
}
