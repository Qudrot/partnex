import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/core/theme/widgets/driver_card.dart';

class DriverMetric {
  final String name;
  final DriverRiskLevel riskLevel;
  final double percentage;
  final double impactPoints;
  final String description;

  const DriverMetric({
    required this.name,
    required this.riskLevel,
    required this.percentage,
    required this.impactPoints,
    required this.description,
  });
}

class SmeCardData {
  List<DriverMetric> get drivers {
    return [
      DriverMetric(
        name: 'Revenue Growth & Stability',
        riskLevel: _mapToDriverRisk(revenueTrendSignal),
        percentage: yoyGrowth.clamp(0, 100),
        impactPoints: (score * 0.3),
        description:
            'Evaluates your year-over-year revenue trajectory. Current growth: ${yoyGrowth.toStringAsFixed(1)}%.',
      ),
      DriverMetric(
        name: 'Profitability & Expense Management',
        riskLevel: _mapToDriverRisk(profitMarginSignal),
        percentage: profitMargin.clamp(0, 100),
        impactPoints: (score * 0.25),
        description:
            'Measures operational efficiency. Current profit margin: ${profitMargin.toStringAsFixed(1)}%.',
      ),
      DriverMetric(
        name: 'Debt & Liability Management',
        riskLevel: _mapToDriverRisk(liabilitiesRatioSignal),
        percentage: (100 - liabilitiesRatio).clamp(0, 100),
        impactPoints: (score * 0.2),
        description:
            'Evaluates debt relative to total revenue. Your liability ratio is ${liabilitiesRatio.toStringAsFixed(1)}%.',
      ),
    ];
  }

  DriverRiskLevel _mapToDriverRisk(String signal) {
    final s = signal.toLowerCase();
    if (s.contains('positive') ||
        s.contains('healthy') ||
        s.contains('low') ||
        s.contains('excellent')) {
      return DriverRiskLevel.excellent;
    }
    if (s.contains('good') || s.contains('strong')) {
      return DriverRiskLevel.good;
    }
    if (s.contains('moderate')) {
      return DriverRiskLevel.moderate;
    }
    if (s.contains('declining') ||
        s.contains('high') ||
        s.contains('needs work')) {
      return DriverRiskLevel.needsWork;
    }
    return DriverRiskLevel.critical;
  }

  final String id;
  final String companyName;
  final String industry;
  final String location;
  final int yearsOfOperation;
  final int numberOfEmployees;
  final int annualRevenueYear1;
  final int annualRevenueYear2;
  final int annualRevenueYear3;
  final double annualRevenue;
  final double previousAnnualRevenue;
  final double annualRevenueAmount3;
  final double monthlyExpenses;
  final double liabilities;
  final String fundingHistory;
  final int score;
  final String riskLevel;
  final DateTime generatedAt;
  final DataSource dataSource;
  final bool allowSharing;

  final String? website;
  final String? bio;
  final String? contactPersonName;
  final String? contactPersonTitle;
  final String? phoneNumber;
  final String? email;
  final String? whatsappNumber;
  final String? linkedinUrl;
  final String? twitterHandle;

  // Computed fields for UI:
  String get employeesText => '$numberOfEmployees employees';
  String get yearsOfOperationText =>
      '$yearsOfOperation ${yearsOfOperation == 1 ? 'yr' : 'yrs'}';
  String get displayLocation => location.split(',').first.trim();
  String get revenueText => '₦${(annualRevenue / 1000).toStringAsFixed(0)}K';

  bool get isGrowthPositive => yoyGrowth >= 0;
  String get growthSignal =>
      '${yoyGrowth >= 0 ? '↑' : '↓'} ${yoyGrowth.abs().toStringAsFixed(0)}% YoY';

  bool get trustFunded => fundingHistory.toLowerCase() != 'no prior funding';
  bool get trustPayments => true;
  bool get trustStable => true;

  // Metric Signals Implementation
  static const Color _positiveColor = AppColors.successGreen;
  static const Color _moderateColor = AppColors.warningOrange;
  static const Color _concerningColor = AppColors.dangerRed;
  static const Color _criticalColor = AppColors.dangerRed;

  double get _prevRevenue {
    // Return actual previous revenue if provided, otherwise default to current revenue (0% growth)
    // to avoid misleading "synthetic" growth numbers.
    if (previousAnnualRevenue > 0) return previousAnnualRevenue;
    return annualRevenue;
  }

  double get yoyGrowth {
    if (_prevRevenue <= 0) return 0.0;
    if (previousAnnualRevenue <= 0) {
      return 0.0; // Avoid showing +Inf or synthetic numbers if no history
    }
    return ((annualRevenue - _prevRevenue) / _prevRevenue) * 100;
  }

  String get revenueTrendText {
    if (annualRevenue <= 0) return 'N/A';
    if (previousAnnualRevenue <= 0) return 'Stable';
    final sign = yoyGrowth > 0 ? '+' : '';
    return '$sign${yoyGrowth.toStringAsFixed(0)}% YoY';
  }

  // Derived Business Insights Metrics
  double get monthlyProfit => (annualRevenue / 12) - monthlyExpenses;
  
  double get estimatedAnnualProfit => annualRevenue - (monthlyExpenses * 12);
  
  double get liabilitiesCoverageRatio => 
    liabilities > 0 ? estimatedAnnualProfit / liabilities : 100.0;
    
  double get employeesHiringRate => 
    yearsOfOperation > 0 ? numberOfEmployees / yearsOfOperation : numberOfEmployees.toDouble();
    
  double get revenueGrowthPerEmployee => 
    numberOfEmployees > 0 ? (annualRevenue - previousAnnualRevenue) / numberOfEmployees : 0.0;
    
  double get liabilitiesPerEmployee =>
    numberOfEmployees > 0 ? liabilities / numberOfEmployees : 0.0;

  String get revenueTrendSignal {
    if (previousAnnualRevenue <= 0) return 'Baseline';
    if (yoyGrowth > 15) return 'Positive';
    if (yoyGrowth >= 0) return 'Moderate';
    if (yoyGrowth >= -5) return 'Declining';
    return 'Steep Decline';
  }

  Color get revenueTrendColor {
    if (previousAnnualRevenue <= 0) return AppColors.trustBlue;
    if (yoyGrowth > 15) return _positiveColor;
    if (yoyGrowth >= 0) return _moderateColor;
    if (yoyGrowth >= -5) return _concerningColor;
    return _criticalColor;
  }

  double get expenseRatio =>
      annualRevenue > 0 ? ((monthlyExpenses * 12) / annualRevenue) * 100 : 0;

  String get expenseRatioText {
    if (annualRevenue <= 0) return 'N/A';
    return '${expenseRatio.toStringAsFixed(0)}%';
  }

  String get expenseRatioSignal {
    if (expenseRatio <= 60) return 'Healthy';
    if (expenseRatio <= 75) return 'Moderate';
    if (expenseRatio <= 90) return 'High';
    return 'Very High';
  }

  Color get expenseRatioColor {
    if (expenseRatio <= 60) return AppColors.trustBlue;
    if (expenseRatio <= 75) return _moderateColor;
    if (expenseRatio <= 90) return _concerningColor;
    return _criticalColor;
  }

  double get liabilitiesRatio =>
      annualRevenue > 0 ? (liabilities / annualRevenue) * 100 : 0;

  String get liabilitiesRatioText {
    if (annualRevenue <= 0) return 'N/A';
    return '${liabilitiesRatio.toStringAsFixed(0)}% of Rev';
  }

  String get liabilitiesRatioSignal {
    if (liabilitiesRatio < 15) return 'Low';
    if (liabilitiesRatio <= 30) return 'Moderate';
    if (liabilitiesRatio <= 50) return 'High';
    return 'Very High';
  }

  Color get liabilitiesRatioColor {
    if (liabilitiesRatio < 15) return _positiveColor;
    if (liabilitiesRatio <= 30) return _moderateColor;
    if (liabilitiesRatio <= 50) return _concerningColor;
    return _criticalColor;
  }

  double get annualDebtPayments => liabilities / 2.0;
  double get debtServiceRatio =>
      annualRevenue > 0 ? (annualDebtPayments / annualRevenue) * 100 : 0;

  String get debtServiceText {
    if (annualRevenue <= 0) return 'N/A';
    return '${debtServiceRatio.toStringAsFixed(0)}% of Rev';
  }

  String get debtServiceSignal {
    if (debtServiceRatio < 30) return 'Strong Cap';
    if (debtServiceRatio <= 50) return 'Moderate Cap';
    if (debtServiceRatio <= 100) return 'Strained';
    return 'Unable to Repay';
  }

  Color get debtServiceColor {
    if (debtServiceRatio < 30) return _positiveColor;
    if (debtServiceRatio <= 50) return _moderateColor;
    if (debtServiceRatio <= 100) return _concerningColor;
    return _criticalColor;
  }

  double get profitMargin => annualRevenue > 0
      ? ((annualRevenue - (monthlyExpenses * 12)) / annualRevenue) * 100
      : 0;

  String get profitMarginText {
    if (annualRevenue <= 0) return 'N/A';
    return '${profitMargin.toStringAsFixed(0)}%';
  }

  String get profitMarginSignal {
    if (profitMargin >= 15) return 'Healthy';
    if (profitMargin >= 0) return 'Moderate';
    return 'Negative';
  }

  Color get profitMarginColor {
    if (profitMargin >= 15) return AppColors.successGreen;
    if (profitMargin >= 0) return AppColors.warningOrange;
    return AppColors.dangerRed;
  }

  double get impactScore => score / 100.0;

  String get impactScoreSignal {
    if (impactScore >= 0.8) return 'Excellent';
    if (impactScore >= 0.5) return 'Good';
    return 'Low';
  }

  Color get impactScoreColor {
    if (impactScore >= 0.8) return AppColors.trustBlue;
    if (impactScore >= 0.5) return AppColors.successGreen;
    return AppColors.dangerRed;
  }

  Color get scoreColor {
    final lowerRisk = riskLevel.toLowerCase();
    if (lowerRisk.contains('low') || score >= 85) {
      return AppColors.successGreen;
    }
    if (lowerRisk.contains('medium') || score >= 55) {
      return AppColors.warningAmber;
    }
    return AppColors.dangerRed;
  }

  String getFinancialAssessment({bool isOwnProfile = false}) {
    final String subject = isOwnProfile ? "Your business" : "This business";
    final String possessive = isOwnProfile ? "your" : "this";
    
    if (score >= 100) {
      return isOwnProfile 
        ? "You have it figured out! Your business demonstrates peak financial health with optimized revenue growth, healthy margins, and excellent debt management. Keep rising and growing—you are on a path of exceptional stability."
        : "This business has it figured out! It demonstrates peak financial health with optimized revenue growth, healthy margins, and excellent debt management.";
    }

    final List<String> highlights = [];

    // Revenue Analysis
    if (previousAnnualRevenue > 0) {
      if (annualRevenueAmount3 > 0) {
        final double totalGrowth = ((annualRevenue - annualRevenueAmount3) / annualRevenueAmount3) * 100;
        final String startYear = annualRevenueYear3 > 0 ? '$annualRevenueYear3' : 'Year 3';
        final String currentYear = annualRevenueYear1 > 0 ? '$annualRevenueYear1' : 'Year 1';
        
        highlights.add(
          "has seen a ${(totalGrowth).toStringAsFixed(1)}% revenue expansion since $startYear, culminating in ₦${(annualRevenue / 1e6).toStringAsFixed(1)}M for $currentYear",
        );
      } else if (yoyGrowth > 15) {
        highlights.add(
          "demonstrates robust scaling with a ${yoyGrowth.toStringAsFixed(1)}% YoY revenue surge",
        );
      } else if (yoyGrowth >= 0) {
        highlights.add(
          "shows steady performance with a ${yoyGrowth.toStringAsFixed(1)}% YoY growth trajectory",
        );
      } else {
        highlights.add(
          "is managing a revenue adjustment period (${yoyGrowth.toStringAsFixed(1)}% YoY) with current annual revenue of ₦${(annualRevenue / 1e6).toStringAsFixed(1)}M",
        );
      }
    } else {
      highlights.add(
        "operates with a strong baseline revenue of ₦${(annualRevenue / 1e6).toStringAsFixed(1)}M",
      );
    }

    // Efficiency Analysis
    if (profitMargin >= 20) {
      highlights.add(
        "retains high operational efficiency (Profit Margin: ${profitMargin.toStringAsFixed(1)}%)",
      );
    } else if (profitMargin >= 10) {
      highlights.add("maintains healthy profitability levels");
    } else if (profitMargin < 0) {
      highlights.add(
        "is currently prioritising expansion over immediate margins (Net Margin: ${profitMargin.toStringAsFixed(1)}%)",
      );
    }

    // Leverage Analysis
    if (liabilitiesRatio < 15) {
      highlights.add("maintains a very light debt profile");
    } else if (liabilitiesRatio > 45) {
      highlights.add(
        "utilises significant leverage (Debt-to-Revenue: ${liabilitiesRatio.toStringAsFixed(1)}%)",
      );
    }

    if (highlights.isEmpty) {
      return "The financial profile shows neutral indicators across revenue and expense management.";
    }

    String assessment = "$subject ${highlights[0]}. ";
    if (highlights.length > 1) {
      assessment +=
          "Key performance data indicates ${highlights.sublist(1).join(" and ")}. ";
    }

    assessment +=
        "The ${riskLevel.toUpperCase()} risk rating is driven by ${revenueTrendSignal.toLowerCase()} momentum against a ${expenseRatioSignal.toLowerCase()} expense structure.";

    return assessment;
  }

  // Legacy getter for backward compatibility
  String get financialAssessment => getFinancialAssessment();

  const SmeCardData({
    required this.id,
    required this.companyName,
    required this.industry,
    required this.location,
    required this.yearsOfOperation,
    required this.numberOfEmployees,
    this.annualRevenueYear1 = 0,
    this.annualRevenueYear2 = 0,
    this.annualRevenueYear3 = 0,
    required this.annualRevenue,
    this.previousAnnualRevenue = 0.0,
    this.annualRevenueAmount3 = 0.0,
    required this.monthlyExpenses,
    required this.liabilities,
    required this.fundingHistory,
    required this.score,
    required this.riskLevel,
    required this.generatedAt,
    this.dataSource = DataSource.selfReported,
    this.allowSharing = true,
    this.website,
    this.bio,
    this.contactPersonName,
    this.contactPersonTitle,
    this.phoneNumber,
    this.email,
    this.whatsappNumber,
    this.linkedinUrl,
    this.twitterHandle,
  });

  factory SmeCardData.fromMap(Map<String, dynamic> map) {
    int parseScore(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      return (double.tryParse(val.toString()) ?? 0.0).toInt();
    }

    return SmeCardData(
      id: map['id']?.toString() ?? map['sme_id']?.toString() ?? '',
      companyName:
          map['business_name']?.toString() ??
          map['businessName']?.toString() ??
          'Unknown SME',
      industry:
          map['industry_sector']?.toString() ??
          map['industry']?.toString() ??
          'Various',
      location: map['location']?.toString() ?? 'Unknown',
      yearsOfOperation:
          int.tryParse(
            map['years_of_operation']?.toString() ??
                map['yearsOfOperation']?.toString() ??
                '1',
          ) ??
          1,
      numberOfEmployees:
          int.tryParse(
            map['employees']?.toString() ??
                map['number_of_employees']?.toString() ??
                map['numbersOfEmployee']?.toString() ??
                '0',
          ) ??
          0,
      annualRevenueYear1: int.tryParse(map['annual_revenue_year_1']?.toString() ?? '0') ?? 0,
      annualRevenueYear2: int.tryParse(map['annual_revenue_year_2']?.toString() ?? '0') ?? 0,
      annualRevenueYear3: int.tryParse(map['annual_revenue_year_3']?.toString() ?? '0') ?? 0,
      annualRevenue:
          double.tryParse(
            map['annual_revenue_amount_1']?.toString() ??
                map['annualRevenue1']?.toString() ??
                map['revenue1']?.toString() ??
                map['annualRevenue']?.toString() ??
                map['revenue']?.toString() ??
                '0',
          ) ??
          0.0,
      previousAnnualRevenue:
          double.tryParse(
            map['annual_revenue_amount_2']?.toString() ??
                map['annualRevenue2']?.toString() ??
                map['revenue2']?.toString() ??
                '0',
          ) ??
          0.0,
      annualRevenueAmount3:
          double.tryParse(
            map['annual_revenue_amount_3']?.toString() ??
                map['annualRevenue3']?.toString() ??
                map['revenue3']?.toString() ??
                '0',
          ) ??
          0.0,

      monthlyExpenses:
          double.tryParse(
            map['monthly_expenses']?.toString() ??
                map['monthlyExpenses']?.toString() ??
                '0',
          ) ??
          0.0,
      liabilities:
          double.tryParse(map['existing_liabilities']?.toString() ?? '0') ??
          0.0,
      fundingHistory:
          map['prior_funding_history']?.toString() ??
          map['priorFundingHistory']?.toString() ??
          'No prior funding',
      score: parseScore(
        map['score'] ??
            map['credibility_score'] ??
            map['currentCredibilityScore'] ??
            map['credibilityScore'] ??
            map['current_credibility_score'] ??
            map['totalScore'] ??
            map['total_score'] ??
            (map['credibility'] != null && map['credibility'] is Map
                ? map['credibility']['total_score'] ??
                      map['credibility']['score'] ??
                      map['credibility']['totalScore']
                : null),
      ),
      riskLevel:
          map['risk_level']?.toString() ??
          map['riskLevel']?.toString() ??
          (map['credibility'] != null && map['credibility'] is Map
              ? map['credibility']['risk_level']?.toString() ??
                    map['credibility']['riskLevel']?.toString()
              : null) ??
          'Unknown',
      // Robust date parsing that checks multiple common keys
      generatedAt: DateTime.tryParse(
            map['scored_at_raw_timestamp']?.toString() ?? 
            map['created_at']?.toString() ?? 
            map['updated_at']?.toString() ?? 
            ''
          ) ?? DateTime.now(),
          
      // Flexible enum matching that handles spaced strings like "Bank Data"
      dataSource: DataSource.values.firstWhere(
        (e) => e.name.toLowerCase().replaceAll(' ', '') == 
               (map['data_source'] ?? map['dataSource'] ?? 'selfReported').toString().toLowerCase().replaceAll(' ', ''),
        orElse: () => DataSource.selfReported,
      ),
      
      allowSharing: map['allow_sharing'] != null
          ? (map['allow_sharing'] == 1 || map['allow_sharing'] == true)
          : (map['allowSharing'] ?? true),
      website: map['website']?.toString() ?? map['websiteUrl']?.toString(),
      bio: map['bio']?.toString() ?? map['description']?.toString(),

      // Simplified mapping to ensure the COALESCE data from Node.js is respected
      contactPersonName: () {
        final name = map['contact_person_name']?.toString() ?? map['contactPersonName']?.toString() ?? '';
        return name.trim().isEmpty ? 'Business Representative' : name;
      }(),
      
      contactPersonTitle: () {
        final title = map['contact_person_title']?.toString() ?? map['contactPersonTitle']?.toString() ?? '';
        return title.trim().isEmpty ? '' : title;
      }(),
      phoneNumber:
          map['phone_number']?.toString() ??
          map['phoneNumber']?.toString() ??
          map['phone']?.toString() ??
          map['user']?['phone_number']?.toString() ??
          map['user']?['phone']?.toString() ??
          map['contact_phone']?.toString() ??
          map['contact']?['phone']?.toString(),
      email:
          map['email']?.toString() ??
          map['user']?['email']?.toString() ??
          map['contact_email']?.toString() ??
          map['user_email']?.toString() ??
          map['owner_email']?.toString() ??
          map['contact']?['email']?.toString(),
      whatsappNumber:
          map['whatsapp_number']?.toString() ??
          map['whatsappNumber']?.toString() ??
          map['whatsapp']?.toString(),
      linkedinUrl:
          map['linkedin_url']?.toString() ??
          map['linkedinUrl']?.toString() ??
          map['linkedin']?.toString(),
      twitterHandle:
          map['twitter_handle']?.toString() ??
          map['twitterHandle']?.toString() ??
          map['twitter']?.toString(),
    );
  }
}
