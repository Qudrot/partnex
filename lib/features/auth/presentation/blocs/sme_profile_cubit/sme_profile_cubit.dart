import 'package:flutter_bloc/flutter_bloc.dart';
import 'sme_profile_state.dart';

class SmeProfileCubit extends Cubit<SmeProfileState> {
  SmeProfileCubit() : super(const SmeProfileState());

  void updateBusinessProfile({
    required String businessName,
    required String industry,
    required String location,
    required int yearsOfOperation,
    required int numberOfEmployees,
  }) {
    emit(state.copyWith(
      businessName: businessName,
      industry: industry,
      location: location,
      yearsOfOperation: yearsOfOperation,
      numberOfEmployees: numberOfEmployees,
    ));
  }

  void updateRevenueExpenses({
    required int annualRevenueYear1,
    required double annualRevenueAmount1,
    required int annualRevenueYear2,
    required double annualRevenueAmount2,
    int? annualRevenueYear3,
    double? annualRevenueAmount3,
    double? monthlyAvgRevenue,
    required double monthlyAvgExpenses,
    String? documentFileName,
  }) {
    emit(state.copyWith(
      annualRevenueYear1: annualRevenueYear1,
      annualRevenueAmount1: annualRevenueAmount1,
      annualRevenueYear2: annualRevenueYear2,
      annualRevenueAmount2: annualRevenueAmount2,
      annualRevenueYear3: annualRevenueYear3,
      annualRevenueAmount3: annualRevenueAmount3,
      monthlyAvgRevenue: monthlyAvgRevenue,
      monthlyAvgExpenses: monthlyAvgExpenses,
      documentFileName: documentFileName,
    ));
  }

  void updateLiabilitiesHistory({
    required double totalLiabilities,
    required double outstandingLoans,
    bool? hasPriorFunding,
    double? priorFundingAmount,
    String? priorFundingSource,
    int? fundingYear,
    String? repaymentHistory,
  }) {
    emit(state.copyWith(
      totalLiabilities: totalLiabilities,
      outstandingLoans: outstandingLoans,
      hasPriorFunding: hasPriorFunding,
      priorFundingAmount: priorFundingAmount,
      priorFundingSource: priorFundingSource,
      fundingYear: fundingYear,
      repaymentHistory: repaymentHistory,
    ));
  }
}
