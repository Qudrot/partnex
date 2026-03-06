import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';

class SmeCardData {
  final String id;
  final String companyName;
  final String industry;
  final String location;
  final int yearsOfOperation;
  final int numberOfEmployees;
  final double annualRevenue;
  final double monthlyExpenses;
  final double liabilities;
  final String fundingHistory;
  final int score;
  final String riskLevel;
  final DateTime generatedAt;
  final DataSource dataSource;

  // Computed fields for UI:
  String get employeesText => '$numberOfEmployees employees';
  String get revenueText => '₦${(annualRevenue / 1000).toStringAsFixed(0)}K';
  
  bool get isGrowthPositive => yoyGrowth >= 0;
  String get growthSignal => '${yoyGrowth >= 0 ? '↑' : '↓'} ${yoyGrowth.abs().toStringAsFixed(0)}% YoY';
  
  bool get trustFunded => fundingHistory.toLowerCase() != 'no prior funding';
  bool get trustPayments => true;
  bool get trustStable => true;

  // Metric Signals Implementation
  static const Color _positiveColor = Color(0xFF10B981);
  static const Color _moderateColor = Color(0xFFF97316);
  static const Color _concerningColor = Color(0xFFEF4444);
  static const Color _criticalColor = Color(0xFF991B1B);

  double get _prevRevenue {
    if (annualRevenue <= 0) return 0;
    if (score >= 80) return annualRevenue / 1.25;
    if (score >= 60) return annualRevenue / 1.10;
    if (score >= 40) return annualRevenue / 0.98;
    return annualRevenue / 0.92;
  }

  double get yoyGrowth {
    if (_prevRevenue <= 0) return 0;
    return ((annualRevenue - _prevRevenue) / _prevRevenue) * 100;
  }

  String get revenueTrendText {
    if (annualRevenue <= 0) return 'N/A';
    final sign = yoyGrowth > 0 ? '+' : '';
    return '$sign${yoyGrowth.toStringAsFixed(0)}% YoY';
  }

  String get revenueTrendSignal {
    if (yoyGrowth > 15) return 'Positive';
    if (yoyGrowth >= 0) return 'Moderate';
    if (yoyGrowth >= -5) return 'Declining';
    return 'Steep Decline';
  }

  Color get revenueTrendColor {
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

  double get profitMargin =>
      annualRevenue > 0 ? ((annualRevenue - (monthlyExpenses * 12)) / annualRevenue) * 100 : 0;

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
    if (lowerRisk.contains('low') || score >= 80)
      return const Color(0xFF10B981);
    if (lowerRisk.contains('medium') || score >= 50)
      return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  const SmeCardData({
    required this.id,
    required this.companyName,
    required this.industry,
    required this.location,
    required this.yearsOfOperation,
    required this.numberOfEmployees,
    required this.annualRevenue,
    required this.monthlyExpenses,
    required this.liabilities,
    required this.fundingHistory,
    required this.score,
    required this.riskLevel,
    required this.generatedAt,
    this.dataSource = DataSource.selfReported,
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
            map['number_of_employees']?.toString() ??
                map['numbersOfEmployee']?.toString() ??
                '0',
          ) ??
          0,
      annualRevenue:
          double.tryParse(
            map['annual_revenue_amount_1']?.toString() ??
                map['annualRevenue']?.toString() ??
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
            map['currentCredibilityScore'],
      ),
      riskLevel:
          map['risk_level']?.toString() ??
          map['riskLevel']?.toString() ??
          'Unknown',
      generatedAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      dataSource: DataSource.values.firstWhere(
        (e) => e.name == (map['data_source'] ?? map['dataSource'] ?? 'selfReported'),
        orElse: () => DataSource.selfReported,
      ),
    );
  }
}
