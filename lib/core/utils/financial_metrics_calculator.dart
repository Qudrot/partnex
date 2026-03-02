import 'dart:math';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/data/models/financial_metrics.dart';

class FinancialMetricsCalculator {
  static FinancialMetrics calculate(SmeProfileState profile) {
    // 1. Revenue Trend Analysis
    final revenueTrend = _calculateRevenueTrend(profile);

    // 2. Expense Ratio Analysis
    final expenseRatioResult = _calculateExpenseRatio(profile);

    // 3. Liabilities Burden Analysis
    final liabilitiesResult = _calculateLiabilitiesBurden(profile, expenseRatioResult.profitMargin);

    // 4. Payment History Analysis
    final paymentHistoryResult = _calculatePaymentHistory(profile);

    // 5. Business Stability Analysis
    final businessStabilityResult = _calculateBusinessStability(profile);

    // 6. Financial Documentation Quality
    final documentationResult = _calculateDocumentationQuality(profile);

    // Driver Calculation & Ranking
    final drivers = [
      DriverResult(name: 'Payment History', score: paymentHistoryResult.score, weight: 0.35, contribution: paymentHistoryResult.score * 0.35),
      DriverResult(name: 'Revenue Trend', score: revenueTrend.score, weight: 0.25, contribution: revenueTrend.score * 0.25),
      DriverResult(name: 'Expense Ratio', score: expenseRatioResult.score, weight: 0.15, contribution: expenseRatioResult.score * 0.15),
      DriverResult(name: 'Liabilities Burden', score: liabilitiesResult.score, weight: 0.15, contribution: liabilitiesResult.score * 0.15),
      DriverResult(name: 'Business Stability', score: businessStabilityResult, weight: 0.05, contribution: businessStabilityResult * 0.05),
      DriverResult(name: 'Financial Documentation', score: documentationResult.score, weight: 0.05, contribution: documentationResult.score * 0.05),
    ];

    // Rank drivers by contribution (highest to lowest)
    final rankedDrivers = List<DriverResult>.from(drivers)..sort((a, b) => b.contribution.compareTo(a.contribution));

    final totalScore = drivers.fold<double>(0, (sum, d) => sum + d.contribution);

    return FinancialMetrics(
      yoyGrowth: revenueTrend.yoyGrowth,
      cagr: revenueTrend.cagr,
      revenueVolatility: revenueTrend.volatility,
      revenueTrendScore: revenueTrend.score,
      expenseRatio: expenseRatioResult.ratio,
      profitMargin: expenseRatioResult.profitMargin,
      efficiencyTrend: expenseRatioResult.efficiencyTrend,
      expenseRatioScore: expenseRatioResult.score,
      debtToRevenueRatio: liabilitiesResult.debtToRevenue,
      debtServiceRatio: liabilitiesResult.debtServiceRatio,
      liabilitiesBurdenScore: liabilitiesResult.score,
      onTimePaymentRate: paymentHistoryResult.onTimeRate,
      paymentReliabilityScore: paymentHistoryResult.score,
      businessStabilityScore: businessStabilityResult,
      documentationCompletenessScore: documentationResult.completeness,
      documentationQualityScore: documentationResult.score,
      totalCredibilityScore: totalScore,
      rankedDrivers: rankedDrivers,
    );
  }

  static _RevenueTrendResult _calculateRevenueTrend(SmeProfileState profile) {
    double r1 = profile.annualRevenueAmount1;
    double r2 = profile.annualRevenueAmount2;
    double? r3 = profile.annualRevenueAmount3;

    if (r1 <= 0) return _RevenueTrendResult(0, 0, 0, 0);

    // YoY Growth
    double yoy = ((r2 - r1) / r1) * 100;

    // CAGR
    double cagr;
    int years;
    if (r3 != null && r3 > 0) {
      years = 2; // (ending/beginning)^(1/n) - 1 where n is years between
      cagr = (pow(r3 / r1, 1 / 2) - 1) * 100;
    } else {
      years = 1;
      cagr = ((r2 / r1) - 1) * 100;
    }

    // Volatility
    // For 2-3 years, we calculate standard deviation of YoY growths
    List<double> growths = [yoy];
    if (r3 != null && r3 > 0) {
       growths.add(((r3 - r2) / r2) * 100);
    }
    
    double mean = growths.reduce((a, b) => a + b) / growths.length;
    double volatility = 0;
    if (growths.length > 1) {
      double variance = growths.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / growths.length;
      volatility = mean != 0 ? (sqrt(variance) / mean.abs()) : 0;
    }

    // Score
    double score = 50 + (cagr * 2) - (volatility * 10);
    if (cagr < 0) score -= 20;
    else if (cagr == 0) score -= 10;

    return _RevenueTrendResult(yoy, cagr, volatility, score.clamp(0, 100));
  }

  static _ExpenseRatioResult _calculateExpenseRatio(SmeProfileState profile) {
    double revenue = profile.annualRevenueAmount2; // Assume current year for ratio
    double expenses = profile.monthlyAvgExpenses * 12; // Annualized

    if (revenue <= 0) return _ExpenseRatioResult(0, 0, 0, 0);

    double ratio = (expenses / revenue) * 100;
    double profitMargin = ((revenue - expenses) / revenue) * 100;

    // Efficiency Trend (Simplification: compare monthly vs annual if available, or just use 0 if not enough data)
    double efficiencyTrend = 0; // +1, 0, -1
    // Logic: if expenses growing slower than revenue...
    // For now, default to 0 as we don't have expense history in state yet.

    double score = 100 - (ratio * 1.5) + (efficiencyTrend * 5);
    if (ratio > 100) score -= 30;
    else if (ratio > 90) score -= 15;

    return _ExpenseRatioResult(ratio, profitMargin, efficiencyTrend, score.clamp(0, 100));
  }

  static _LiabilitiesResult _calculateLiabilitiesBurden(SmeProfileState profile, double annualProfitMargin) {
    double revenue = profile.annualRevenueAmount2;
    double liabilities = profile.totalLiabilities;

    if (revenue <= 0) return _LiabilitiesResult(0, 0, 0);

    double debtToRevenue = (liabilities / revenue) * 100;

    // Monthly Debt Service = Total_Liabilities × 0.10 / 12
    double monthlyDebtService = liabilities * 0.10 / 12;
    double monthlyRevenue = profile.monthlyAvgRevenue ?? (revenue / 12);
    double monthlyExpenses = profile.monthlyAvgExpenses;
    double monthlyProfit = monthlyRevenue - monthlyExpenses;

    double debtServiceRatio = monthlyProfit > 0 ? (monthlyDebtService / monthlyProfit) : 100;

    double score = 100 - (debtToRevenue * 1.5) - (debtServiceRatio * 100);
    if (debtToRevenue > 150) score -= 60;
    else if (debtToRevenue > 100) score -= 40;

    return _LiabilitiesResult(debtToRevenue, debtServiceRatio, score.clamp(0, 100));
  }

  static _PaymentHistoryResult _calculatePaymentHistory(SmeProfileState profile) {
    int totalPayments = profile.onTimePayments + profile.latePayments;
    if (totalPayments == 0) return _PaymentHistoryResult(100, 50); // Neutral baseline

    double onTimeRate = (profile.onTimePayments / totalPayments) * 100;
    
    double penalty = (profile.latePayments * 1.0) + 
                     (profile.latePaymentsOver30Days * 2.0) + 
                     (profile.latePaymentsOver60Days * 5.0);
    
    double score = onTimeRate - penalty;
    if (onTimeRate < 60) score -= 30;
    else if (onTimeRate < 80) score -= 10;

    return _PaymentHistoryResult(onTimeRate, score.clamp(0, 100));
  }

  static double _calculateBusinessStability(SmeProfileState profile) {
    double years = profile.yearsOfOperation.toDouble();
    double score = min(years * 10, 100);

    if (years < 0.5) score -= 50;
    else if (years < 1.0) score -= 20;

    return score.clamp(0, 100);
  }

  static _DocumentationResult _calculateDocumentationQuality(SmeProfileState profile) {
    int required = 3;
    int submitted = profile.numDocumentsSubmitted;
    double completeness = (submitted / required) * 100;

    double bonus = 0;
    if (profile.areDocumentsRecent) bonus += 10;
    if (profile.areDocumentsComplete) bonus += 5;
    if (profile.areDocumentsConsistent) bonus += 5;

    double score = completeness + bonus;
    return _DocumentationResult(completeness, score.clamp(0, 100));
  }
}

class _RevenueTrendResult {
  final double yoyGrowth;
  final double cagr;
  final double volatility;
  final double score;
  _RevenueTrendResult(this.yoyGrowth, this.cagr, this.volatility, this.score);
}

class _ExpenseRatioResult {
  final double ratio;
  final double profitMargin;
  final double efficiencyTrend;
  final double score;
  _ExpenseRatioResult(this.ratio, this.profitMargin, this.efficiencyTrend, this.score);
}

class _LiabilitiesResult {
  final double debtToRevenue;
  final double debtServiceRatio;
  final double score;
  _LiabilitiesResult(this.debtToRevenue, this.debtServiceRatio, this.score);
}

class _PaymentHistoryResult {
  final double onTimeRate;
  final double score;
  _PaymentHistoryResult(this.onTimeRate, this.score);
}

class _DocumentationResult {
  final double completeness;
  final double score;
  _DocumentationResult(this.completeness, this.score);
}
