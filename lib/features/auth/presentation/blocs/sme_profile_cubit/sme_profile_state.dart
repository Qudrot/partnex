import 'package:equatable/equatable.dart';

class SmeProfileState extends Equatable {
  // Step 1: Business Profile
  final String businessName;
  final String industry;
  final String location;
  final int yearsOfOperation;
  final int numberOfEmployees;

  // Step 2: Document Upload Memory
  final String? documentFileName;

  // Step 2: Revenue & Expenses (Strict mapping to backend)
  final int annualRevenueYear1;
  final double annualRevenueAmount1;
  final int annualRevenueYear2;
  final double annualRevenueAmount2;
  final int? annualRevenueYear3;
  final double? annualRevenueAmount3;
  final double? monthlyAvgRevenue; // optional as per schema
  final double monthlyAvgExpenses;

  // Step 3: Liabilities & History
  final double totalLiabilities;
  final double outstandingLoans; // Kept for UI aggregate/clarity
  final bool? hasPriorFunding;
  final double? priorFundingAmount;
  final String? priorFundingSource;
  final int? fundingYear;
  final String? repaymentHistory;

  const SmeProfileState({
    this.businessName = '',
    this.industry = '',
    this.location = '',
    this.yearsOfOperation = 0,
    this.numberOfEmployees = 0,
    this.annualRevenueYear1 = 0,
    this.annualRevenueAmount1 = 0,
    this.annualRevenueYear2 = 0,
    this.annualRevenueAmount2 = 0,
    this.annualRevenueYear3,
    this.annualRevenueAmount3,
    this.monthlyAvgRevenue,
    this.monthlyAvgExpenses = 0,
    this.documentFileName,
    this.totalLiabilities = 0,
    this.outstandingLoans = 0,
    this.hasPriorFunding,
    this.priorFundingAmount,
    this.priorFundingSource,
    this.fundingYear,
    this.repaymentHistory,
  });

  SmeProfileState copyWith({
    String? businessName,
    String? industry,
    String? location,
    int? yearsOfOperation,
    int? numberOfEmployees,
    int? annualRevenueYear1,
    double? annualRevenueAmount1,
    int? annualRevenueYear2,
    double? annualRevenueAmount2,
    int? annualRevenueYear3,
    double? annualRevenueAmount3,
    double? monthlyAvgRevenue,
    double? monthlyAvgExpenses,
    String? documentFileName,
    double? totalLiabilities,
    double? outstandingLoans,
    bool? hasPriorFunding,
    double? priorFundingAmount,
    String? priorFundingSource,
    int? fundingYear,
    String? repaymentHistory,
  }) {
    return SmeProfileState(
      businessName: businessName ?? this.businessName,
      industry: industry ?? this.industry,
      location: location ?? this.location,
      yearsOfOperation: yearsOfOperation ?? this.yearsOfOperation,
      numberOfEmployees: numberOfEmployees ?? this.numberOfEmployees,
      annualRevenueYear1: annualRevenueYear1 ?? this.annualRevenueYear1,
      annualRevenueAmount1: annualRevenueAmount1 ?? this.annualRevenueAmount1,
      annualRevenueYear2: annualRevenueYear2 ?? this.annualRevenueYear2,
      annualRevenueAmount2: annualRevenueAmount2 ?? this.annualRevenueAmount2,
      annualRevenueYear3: annualRevenueYear3 ?? this.annualRevenueYear3,
      annualRevenueAmount3: annualRevenueAmount3 ?? this.annualRevenueAmount3,
      monthlyAvgRevenue: monthlyAvgRevenue ?? this.monthlyAvgRevenue,
      monthlyAvgExpenses: monthlyAvgExpenses ?? this.monthlyAvgExpenses,
      documentFileName: documentFileName ?? this.documentFileName,
      totalLiabilities: totalLiabilities ?? this.totalLiabilities,
      outstandingLoans: outstandingLoans ?? this.outstandingLoans,
      hasPriorFunding: hasPriorFunding ?? this.hasPriorFunding,
      priorFundingAmount: priorFundingAmount ?? this.priorFundingAmount,
      priorFundingSource: priorFundingSource ?? this.priorFundingSource,
      fundingYear: fundingYear ?? this.fundingYear,
      repaymentHistory: repaymentHistory ?? this.repaymentHistory,
    );
  }

  // Helper method to gather data into a map for submission
  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'industry': industry,
      'location': location,
      'yearsOfOperation': yearsOfOperation,
      'numberOfEmployees': numberOfEmployees,
      'annualRevenueYear1': annualRevenueYear1,
      'annualRevenueAmount1': annualRevenueAmount1,
      'annualRevenueYear2': annualRevenueYear2,
      'annualRevenueAmount2': annualRevenueAmount2,
      'annualRevenueYear3': annualRevenueYear3,
      'annualRevenueAmount3': annualRevenueAmount3,
      'monthlyAvgRevenue': monthlyAvgRevenue,
      'monthlyAvgExpenses': monthlyAvgExpenses,
      'totalLiabilities': totalLiabilities,
      'outstandingLoans': outstandingLoans,
      'hasPriorFunding': hasPriorFunding,
      'priorFundingAmount': priorFundingAmount,
      'priorFundingSource': priorFundingSource,
      'fundingYear': fundingYear,
      'repaymentHistory': repaymentHistory,
    };
  }

  @override
  List<Object?> get props => [
        businessName,
        industry,
        location,
        yearsOfOperation,
        numberOfEmployees,
        annualRevenueYear1,
        annualRevenueAmount1,
        annualRevenueYear2,
        annualRevenueAmount2,
        annualRevenueYear3,
        annualRevenueAmount3,
        monthlyAvgRevenue,
        monthlyAvgExpenses,
        totalLiabilities,
        outstandingLoans,
        hasPriorFunding,
        priorFundingAmount,
        priorFundingSource,
        fundingYear,
        repaymentHistory,
      ];
}
