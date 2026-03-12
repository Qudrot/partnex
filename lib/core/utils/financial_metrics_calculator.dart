import 'dart:math';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/data/models/financial_metrics.dart';

class FinancialMetricsCalculator {
  static FinancialMetrics calculate(SmeProfileState profile) {
    // ---------------------------------------------------------
    // BASE VARIABLES (Safeguarded against division by zero)
    // ---------------------------------------------------------
    // 1. GATHER & SORT REVENUE HISTORY (Descending: Most Recent First)
    final int currentYear = DateTime.now().year;
    
    // Attempt to gather revenue with fallbacks for missing year metadata
    final List<Map<String, dynamic>> revData = [];
    
    if (profile.annualRevenueAmount1 > 0) {
      revData.add({
        'year': profile.annualRevenueYear1 > 0 ? profile.annualRevenueYear1 : currentYear,
        'amount': profile.annualRevenueAmount1
      });
    }
    if (profile.annualRevenueAmount2 > 0) {
      revData.add({
        'year': profile.annualRevenueYear2 > 0 ? profile.annualRevenueYear2 : currentYear - 1,
        'amount': profile.annualRevenueAmount2
      });
    }
    if (profile.annualRevenueAmount3 != null && profile.annualRevenueAmount3! > 0) {
      revData.add({
        'year': (profile.annualRevenueYear3 ?? 0) > 0 ? profile.annualRevenueYear3! : currentYear - 2,
        'amount': profile.annualRevenueAmount3!
      });
    }

    // 2. FALLBACK: If no annual data, use monthly avg revenue
    if (revData.isEmpty && (profile.monthlyAvgRevenue ?? 0) > 0) {
      revData.add({
        'year': currentYear,
        'amount': profile.monthlyAvgRevenue! * 12,
      });
    }

    // Sort by year DESC (e.g., 2024, 2023, 2022)
    revData.sort((a, b) => (b['year'] as int).compareTo(a['year'] as int));

    // Safeguarded pointers (revenueY1 is always the latest year)
    final double revenueY1 = revData.isNotEmpty ? (revData[0]['amount'] as double) : 1.0;
    final double revenueY2 = revData.length > 1 ? (revData[1]['amount'] as double) : revenueY1;
    final double revenueY3 = revData.length > 2 ? (revData[2]['amount'] as double) : revenueY2;

    final double annualExpenses = profile.monthlyAvgExpenses * 12;
    final double liabilities = profile.totalLiabilities;
    final int employees = profile.numberOfEmployees > 0 ? profile.numberOfEmployees : 1;
    final int years = profile.yearsOfOperation > 0 ? profile.yearsOfOperation : 1;

    // ---------------------------------------------------------
    // CATEGORY 1: REVENUE METRICS
    // ---------------------------------------------------------
    // YoY Growth: (Recent - Previous) / Previous
    final double yoyGrowth = ((revenueY1 - revenueY2) / (revenueY2 > 0 ? revenueY2 : 1.0)) * 100;
    
    // CAGR (Matches YoY if 2 years, smooths over 3 if available)
    double cagr = yoyGrowth; 
    if (revData.length >= 3) {
      // CAGR over 2 periods (3 years): (Ending / Starting)^(1/2) - 1
      cagr = (pow(revenueY1 / (revenueY3 > 0 ? revenueY3 : 1.0), 0.5) - 1) * 100;
    }
    
    final double revenuePerEmployee = revenueY1 / employees;

    // ---------------------------------------------------------
    // CATEGORY 2: PROFITABILITY METRICS
    // ---------------------------------------------------------
    final double expenseRatio = (annualExpenses / revenueY1) * 100;
    final double profitMargin = ((revenueY1 - annualExpenses) / revenueY1) * 100;
    final double monthlyProfit = (revenueY1 / 12) - profile.monthlyAvgExpenses;
    final double annualProfit = revenueY1 - annualExpenses;

    // ---------------------------------------------------------
    // CATEGORY 3: DEBT & LIABILITIES
    // ---------------------------------------------------------
    final double liabilitiesToRevenueRatio = (liabilities / revenueY1) * 100;
    
    // Handle edge case where annual profit is negative (can't service debt)
    final double debtServiceRatio = annualProfit > 0 ? (liabilities / annualProfit) * 100 : 999.9;
    
    final double liabilitiesPerEmployee = liabilities / employees;
    final double liabilitiesCoverageRatio = liabilities > 0 ? (annualProfit / liabilities) : 999.9;

    // ---------------------------------------------------------
    // CATEGORY 4 & 5: MATURITY & EFFICIENCY
    // ---------------------------------------------------------
    final double employeesPerYear = employees / years;
    final double revenueGrowthAbs = revenueY1 - revenueY2;
    final double revenueGrowthPerEmployee = revenueGrowthAbs / employees;

    // ---------------------------------------------------------
    // SCORE DRIVERS & THRESHOLD MAPPING
    // ---------------------------------------------------------
    
    // 1. Revenue Growth & Stability (Weight: 25%)
    double revenueScore = (yoyGrowth + cagr) / 2;
    MetricStatus revenueStatus = _getRevenueStatus(revenueScore);

    // 2. Profitability & Expense Management (Weight: 20%)
    double profitScore = 100 - expenseRatio; // 86.25% ratio = 13.75 score
    MetricStatus profitStatus = _getProfitStatus(expenseRatio);

    // 3. Debt Management & Financial Leverage (Weight: 20%)
    double debtScore = (1 / (1 + (liabilitiesToRevenueRatio / 100))) * 100;
    MetricStatus debtStatus = _getDebtStatus(liabilitiesToRevenueRatio);

    // 4. Operational Efficiency & Scalability (Weight: 15%)
    double efficiencyScore = min((revenuePerEmployee / 2000000) * 100, 100.0);
    MetricStatus efficiencyStatus = _getEfficiencyStatus(revenuePerEmployee);

    // 5. Business Maturity & Stability (Weight: 20%)
    double maturityScore = min(years / 5, 1.0) * 100;
    MetricStatus maturityStatus = _getMaturityStatus(years);

    // Build the Ranked Drivers List
    final drivers = [
      ScoreDriver(
        name: "Revenue Growth & Stability",
        scoreValue: revenueScore,
        rawDisplayValue: "${yoyGrowth >= 0 ? '+' : ''}${yoyGrowth.toStringAsFixed(yoyGrowth % 1 == 0 ? 0 : 1)}% YoY",
        status: revenueStatus,
        weight: 0.25,
      ),
      ScoreDriver(
        name: "Profitability & Expense Management",
        scoreValue: profitScore,
        rawDisplayValue: "${profitMargin.toStringAsFixed(profitMargin % 1 == 0 ? 0 : 1)}% margin",
        status: profitStatus,
        weight: 0.20,
      ),
      ScoreDriver(
        name: "Debt Management & Leverage",
        scoreValue: debtScore,
        rawDisplayValue: "${liabilitiesToRevenueRatio.toStringAsFixed(liabilitiesToRevenueRatio % 1 == 0 ? 0 : 1)}% of revenue",
        status: debtStatus,
        weight: 0.20,
      ),
      ScoreDriver(
        name: "Operational Efficiency",
        scoreValue: efficiencyScore,
        rawDisplayValue: "₦${_formatCurrency(revenuePerEmployee)} / emp",
        status: efficiencyStatus,
        weight: 0.15,
      ),
      ScoreDriver(
        name: "Business Maturity",
        scoreValue: maturityScore,
        rawDisplayValue: "$years year${years > 1 ? 's' : ''}",
        status: maturityStatus,
        weight: 0.20,
      ),
    ];

    // Sort drivers by status (Critical first, then Concerning, Moderate, Positive) to highlight action areas
    drivers.sort((a, b) => b.status.index.compareTo(a.status.index));

    return FinancialMetrics(
      yoyGrowth: yoyGrowth,
      cagr: cagr,
      revenuePerEmployee: revenuePerEmployee,
      expenseRatio: expenseRatio,
      profitMargin: profitMargin,
      monthlyProfit: monthlyProfit,
      liabilitiesToRevenueRatio: liabilitiesToRevenueRatio,
      debtServiceRatio: debtServiceRatio,
      liabilitiesPerEmployee: liabilitiesPerEmployee,
      liabilitiesCoverageRatio: liabilitiesCoverageRatio,
      yearsOfOperation: years,
      employeesPerYear: employeesPerYear,
      revenueGrowthPerEmployee: revenueGrowthPerEmployee,
      rankedDrivers: drivers,
    );
  }

  // --- THRESHOLD HELPERS ---

  static MetricStatus _getRevenueStatus(double growth) {
    if (growth > 15) return MetricStatus.positive;
    if (growth >= 0) return MetricStatus.moderate;
    if (growth >= -5) return MetricStatus.concerning;
    return MetricStatus.critical;
  }

  static MetricStatus _getProfitStatus(double expenseRatio) {
    if (expenseRatio < 70) return MetricStatus.positive;
    if (expenseRatio <= 80) return MetricStatus.moderate;
    if (expenseRatio <= 90) return MetricStatus.concerning;
    return MetricStatus.critical;
  }

  static MetricStatus _getDebtStatus(double liabilitiesRatio) {
    if (liabilitiesRatio < 20) return MetricStatus.positive;
    if (liabilitiesRatio <= 35) return MetricStatus.moderate;
    if (liabilitiesRatio <= 50) return MetricStatus.concerning;
    return MetricStatus.critical;
  }

  static MetricStatus _getEfficiencyStatus(double revPerEmp) {
    if (revPerEmp > 2000000) return MetricStatus.positive;
    if (revPerEmp >= 1000000) return MetricStatus.moderate;
    if (revPerEmp >= 500000) return MetricStatus.concerning;
    return MetricStatus.critical;
  }

  static MetricStatus _getMaturityStatus(int years) {
    if (years > 5) return MetricStatus.positive;
    if (years >= 2) return MetricStatus.moderate;
    if (years == 1) return MetricStatus.concerning;
    return MetricStatus.critical;
  }

  static String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(2)}M";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(1)}K";
    }
    return amount.toStringAsFixed(0);
  }
}