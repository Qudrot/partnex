import 'package:equatable/equatable.dart';

class FinancialMetrics extends Equatable {
  // 1. Revenue Trend
  final double yoyGrowth;
  final double cagr;
  final double revenueVolatility;
  final double revenueTrendScore;

  // 2. Expense Ratio
  final double expenseRatio;
  final double profitMargin;
  final double efficiencyTrend; // +1, 0, -1
  final double expenseRatioScore;

  // 3. Liabilities Burden
  final double debtToRevenueRatio;
  final double debtServiceRatio;
  final double liabilitiesBurdenScore;

  // 4. Payment History
  final double onTimePaymentRate;
  final double paymentReliabilityScore;

  // 5. Business Stability
  final double businessStabilityScore;

  // 6. Financial Documentation
  final double documentationCompletenessScore;
  final double documentationQualityScore;

  // Overall Score & Drivers
  final double totalCredibilityScore;
  final List<DriverResult> rankedDrivers;

  const FinancialMetrics({
    required this.yoyGrowth,
    required this.cagr,
    required this.revenueVolatility,
    required this.revenueTrendScore,
    required this.expenseRatio,
    required this.profitMargin,
    required this.efficiencyTrend,
    required this.expenseRatioScore,
    required this.debtToRevenueRatio,
    required this.debtServiceRatio,
    required this.liabilitiesBurdenScore,
    required this.onTimePaymentRate,
    required this.paymentReliabilityScore,
    required this.businessStabilityScore,
    required this.documentationCompletenessScore,
    required this.documentationQualityScore,
    required this.totalCredibilityScore,
    required this.rankedDrivers,
  });

  @override
  List<Object?> get props => [
    yoyGrowth, cagr, revenueVolatility, revenueTrendScore,
    expenseRatio, profitMargin, efficiencyTrend, expenseRatioScore,
    debtToRevenueRatio, debtServiceRatio, liabilitiesBurdenScore,
    onTimePaymentRate, paymentReliabilityScore,
    businessStabilityScore,
    documentationCompletenessScore, documentationQualityScore,
    totalCredibilityScore, rankedDrivers,
  ];
}

class DriverResult extends Equatable {
  final String name;
  final double score; // 0-100
  final double weight; // e.g., 0.35
  final double contribution; // score * weight

  const DriverResult({
    required this.name,
    required this.score,
    required this.weight,
    required this.contribution,
  });

  @override
  List<Object?> get props => [name, score, weight, contribution];
}
