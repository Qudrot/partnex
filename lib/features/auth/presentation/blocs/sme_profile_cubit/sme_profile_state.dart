import 'package:equatable/equatable.dart';

enum CsvProcessingStatus { initial, processing, success, error }

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

  // Step 4: Payment History & Documents
  final int onTimePayments;
  final int latePayments;
  final int latePaymentsOver30Days;
  final int latePaymentsOver60Days;
  final int numDocumentsSubmitted;
  final bool areDocumentsRecent;
  final bool areDocumentsComplete;
  final bool areDocumentsConsistent;

  // CSV Processing Status
  final CsvProcessingStatus csvProcessingStatus;
  final String? csvErrorMessage;

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
    this.onTimePayments = 0,
    this.latePayments = 0,
    this.latePaymentsOver30Days = 0,
    this.latePaymentsOver60Days = 0,
    this.numDocumentsSubmitted = 0,
    this.areDocumentsRecent = false,
    this.areDocumentsComplete = false,
    this.areDocumentsConsistent = false,
    this.csvProcessingStatus = CsvProcessingStatus.initial,
    this.csvErrorMessage,
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
    int? onTimePayments,
    int? latePayments,
    int? latePaymentsOver30Days,
    int? latePaymentsOver60Days,
    int? numDocumentsSubmitted,
    bool? areDocumentsRecent,
    bool? areDocumentsComplete,
    bool? areDocumentsConsistent,
    CsvProcessingStatus? csvProcessingStatus,
    String? csvErrorMessage,
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
      onTimePayments: onTimePayments ?? this.onTimePayments,
      latePayments: latePayments ?? this.latePayments,
      latePaymentsOver30Days: latePaymentsOver30Days ?? this.latePaymentsOver30Days,
      latePaymentsOver60Days: latePaymentsOver60Days ?? this.latePaymentsOver60Days,
      numDocumentsSubmitted: numDocumentsSubmitted ?? this.numDocumentsSubmitted,
      areDocumentsRecent: areDocumentsRecent ?? this.areDocumentsRecent,
      areDocumentsComplete: areDocumentsComplete ?? this.areDocumentsComplete,
      areDocumentsConsistent: areDocumentsConsistent ?? this.areDocumentsConsistent,
      csvProcessingStatus: csvProcessingStatus ?? this.csvProcessingStatus,
      csvErrorMessage: csvErrorMessage ?? this.csvErrorMessage,
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
      'onTimePayments': onTimePayments,
      'latePayments': latePayments,
      'latePaymentsOver30Days': latePaymentsOver30Days,
      'latePaymentsOver60Days': latePaymentsOver60Days,
      'numDocumentsSubmitted': numDocumentsSubmitted,
      'areDocumentsRecent': areDocumentsRecent,
      'areDocumentsComplete': areDocumentsComplete,
      'areDocumentsConsistent': areDocumentsConsistent,
    };
  }

  factory SmeProfileState.fromMap(Map<String, dynamic> map) {
    return SmeProfileState(
      businessName: map['businessName'] ?? '',
      industry: map['industry'] ?? '',
      location: map['location'] ?? '',
      yearsOfOperation: map['yearsOfOperation'] ?? 0,
      numberOfEmployees: map['numberOfEmployees'] ?? 0,
      annualRevenueYear1: map['annualRevenueYear1'] ?? 0,
      annualRevenueAmount1: (map['annualRevenueAmount1'] ?? 0).toDouble(),
      annualRevenueYear2: map['annualRevenueYear2'] ?? 0,
      annualRevenueAmount2: (map['annualRevenueAmount2'] ?? 0).toDouble(),
      annualRevenueYear3: map['annualRevenueYear3'],
      annualRevenueAmount3: map['annualRevenueAmount3']?.toDouble(),
      monthlyAvgRevenue: map['monthlyAvgRevenue']?.toDouble(),
      monthlyAvgExpenses: (map['monthlyAvgExpenses'] ?? 0).toDouble(),
      totalLiabilities: (map['totalLiabilities'] ?? 0).toDouble(),
      outstandingLoans: (map['outstandingLoans'] ?? 0).toDouble(),
      hasPriorFunding: map['hasPriorFunding'],
      priorFundingAmount: map['priorFundingAmount']?.toDouble(),
      priorFundingSource: map['priorFundingSource'],
      fundingYear: map['fundingYear'],
      repaymentHistory: map['repaymentHistory'],
      onTimePayments: map['onTimePayments'] ?? 0,
      latePayments: map['latePayments'] ?? 0,
      latePaymentsOver30Days: map['latePaymentsOver30Days'] ?? 0,
      latePaymentsOver60Days: map['latePaymentsOver60Days'] ?? 0,
      numDocumentsSubmitted: map['numDocumentsSubmitted'] ?? 0,
      areDocumentsRecent: map['areDocumentsRecent'] ?? false,
      areDocumentsComplete: map['areDocumentsComplete'] ?? false,
      areDocumentsConsistent: map['areDocumentsConsistent'] ?? false,
    );
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
        onTimePayments,
        latePayments,
        latePaymentsOver30Days,
        latePaymentsOver60Days,
        numDocumentsSubmitted,
        areDocumentsRecent,
        areDocumentsComplete,
        areDocumentsConsistent,
        csvProcessingStatus,
        csvErrorMessage,
      ];
}
