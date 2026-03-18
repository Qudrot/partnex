import 'package:equatable/equatable.dart';

enum CsvProcessingStatus { initial, processing, success, error }
enum DataSource { uploaded, selfReported, bankData }

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
  final DataSource dataSource;
  final bool allowSharing;

  // Bio & Social Links
  final String bio;
  final String websiteUrl;
  final String whatsappNumber;
  final String linkedinUrl;
  final String twitterHandle;

  // Contact Info (from signup + business profile)
  final String contactPosition;
  final String phoneNumber;
  final String email;

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
    this.dataSource = DataSource.selfReported,
    this.allowSharing = true,
    this.bio = '',
    this.websiteUrl = '',
    this.whatsappNumber = '',
    this.linkedinUrl = '',
    this.twitterHandle = '',
    this.contactPosition = '',
    this.phoneNumber = '',
    this.email = '',
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
    DataSource? dataSource,
    String? bio,
    String? websiteUrl,
    String? whatsappNumber,
    String? linkedinUrl,
    String? twitterHandle,
    String? contactPosition,
    String? phoneNumber,
    String? email,
    bool? allowSharing,
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
      dataSource: dataSource ?? this.dataSource,
      allowSharing: allowSharing ?? this.allowSharing,
      bio: bio ?? this.bio,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      twitterHandle: twitterHandle ?? this.twitterHandle,
      contactPosition: contactPosition ?? this.contactPosition,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
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
      'dataSource': dataSource.name,
      'allowSharing': allowSharing,
      'bio': bio,
      'websiteUrl': websiteUrl,
      'whatsappNumber': whatsappNumber,
      'linkedinUrl': linkedinUrl,
      'twitterHandle': twitterHandle,
      'contactPosition': contactPosition,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  factory SmeProfileState.fromMap(Map<String, dynamic> map) {
    // Helper to extract double values from multiple possible keys and handle strings
    double? extractDouble(List<String> keys, double? defaultValue) {
      for (var key in keys) {
        if (map[key] != null) {
          final val = map[key];
          if (val is num) return val.toDouble();
          if (val is String) {
            // Strip currency symbols, commas, and whitespace
            final clean = val.replaceAll(RegExp(r'[^\d.-]'), '').trim();
            final parsed = double.tryParse(clean);
            if (parsed != null) return parsed;
          }
        }
      }
      return defaultValue;
    }

    // Helper to extract int values
    int? extractInt(List<String> keys, int? defaultValue) {
      for (var key in keys) {
        if (map[key] != null) {
          final val = map[key];
          if (val is num) return val.toInt();
          if (val is String) {
            final clean = val.replaceAll(RegExp(r'[^\d.-]'), '').trim();
            final parsed = double.tryParse(clean)?.toInt(); // Handle 2024.0 as int
            if (parsed != null) return parsed;
          }
        }
      }
      return defaultValue;
    }

    return SmeProfileState(
      businessName: map['businessName'] ?? map['business_name'] ?? map['name'] ?? '',
      industry: map['industry'] ?? map['industry_sector'] ?? map['sector'] ?? '',
      location: map['location'] ?? '',
      yearsOfOperation: extractInt(['yearsOfOperation', 'years_of_operation', 'years_operation', 'years'], 0) ?? 0,
      numberOfEmployees: extractInt(['numberOfEmployees', 'number_of_employees', 'employees_count', 'employees'], 0) ?? 0,
      
      // REVENUE YEARS
      annualRevenueYear1: extractInt(['annualRevenueYear1', 'annual_revenue_year_1', 'revenue_year_1', 'year_1'], 0) ?? 0,
      annualRevenueYear2: extractInt(['annualRevenueYear2', 'annual_revenue_year_2', 'revenue_year_2', 'year_2'], 0) ?? 0,
      annualRevenueYear3: extractInt(['annualRevenueYear3', 'annual_revenue_year_3', 'revenue_year_3', 'year_3'], null),
      
      // REVENUE AMOUNTS (Resilient keys)
      annualRevenueAmount1: extractDouble(['annualRevenueAmount1', 'annual_revenue_amount_1', 'revenue_amount_1', 'annual_revenue_1', 'revenue_1', 'amount_1', 'revenue'], 0) ?? 0.0,
      annualRevenueAmount2: extractDouble(['annualRevenueAmount2', 'annual_revenue_amount_2', 'revenue_amount_2', 'annual_revenue_2', 'revenue_2', 'amount_2'], 0) ?? 0.0,
      annualRevenueAmount3: extractDouble(['annualRevenueAmount3', 'annual_revenue_amount_3', 'revenue_amount_3', 'annual_revenue_3', 'revenue_3', 'amount_3'], 0) ?? 0.0,
      
      monthlyAvgRevenue: (() {
        final val = extractDouble(['monthlyAvgRevenue', 'monthly_revenue', 'avg_revenue', 'monthly_avg_revenue'], null);
        return (val != null && val > 0) ? val : null;
      })(),
      monthlyAvgExpenses: extractDouble(['monthlyAvgExpenses', 'monthly_expenses', 'expenses', 'monthly_avg_expenses', 'expens'], 0) ?? 0.0,
      totalLiabilities: extractDouble(['totalLiabilities', 'existing_liabilities', 'liabilities_total', 'liabilities', 'debt', 'loans'], 0) ?? 0.0,
      outstandingLoans: extractDouble(['outstandingLoans', 'outstanding_loans'], 0) ?? 0.0,
      
      hasPriorFunding: map['hasPriorFunding'] ?? map['has_prior_funding'],
      priorFundingAmount: (() {
        final val = extractDouble(['priorFundingAmount', 'prior_funding_amount'], null);
        return (val != null && val > 0) ? val : null;
      })(),
      priorFundingSource: map['priorFundingSource'] ?? map['prior_funding_source'],
      fundingYear: extractInt(['fundingYear', 'funding_year'], null),
      repaymentHistory: map['repaymentHistory'] ?? map['repayment_history'],
      onTimePayments: extractInt(['onTimePayments', 'on_time_payments'], 0) ?? 0,
      latePayments: extractInt(['latePayments', 'late_payments'], 0) ?? 0,
      latePaymentsOver30Days: extractInt(['latePaymentsOver30Days', 'late_payments_over_30_days'], 0) ?? 0,
      latePaymentsOver60Days: extractInt(['latePaymentsOver60Days', 'late_payments_over_60_days'], 0) ?? 0,
      numDocumentsSubmitted: extractInt(['numDocumentsSubmitted', 'num_documents_submitted'], 0) ?? 0,
      areDocumentsRecent: map['areDocumentsRecent'] ?? map['are_documents_recent'] ?? false,
      areDocumentsComplete: map['areDocumentsComplete'] ?? map['are_documents_complete'] ?? false,
      areDocumentsConsistent: map['areDocumentsConsistent'] ?? map['are_documents_consistent'] ?? false,
      dataSource: DataSource.values.firstWhere((e) => e.name == (map['dataSource'] ?? 'selfReported'), orElse: () => DataSource.selfReported),
      bio: map['bio'] ?? '',
      websiteUrl: map['websiteUrl'] ?? map['website'] ?? '',
      whatsappNumber: map['whatsappNumber'] ?? map['whatsapp'] ?? '',
      linkedinUrl: map['linkedinUrl'] ?? map['linkedin'] ?? '',
      twitterHandle: map['twitterHandle'] ?? map['twitter'] ?? '',
      contactPosition: map['contactPosition'] ?? map['position'] ?? '',
      phoneNumber: map['phoneNumber'] ?? map['phone_number'] ?? '',
      email: map['email'] ?? '',
    );
  }

  factory SmeProfileState.empty() => const SmeProfileState();

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
        dataSource,
        allowSharing,
        bio,
        websiteUrl,
        whatsappNumber,
        linkedinUrl,
        twitterHandle,
        contactPosition,
        phoneNumber,
        email,
      ];
}
