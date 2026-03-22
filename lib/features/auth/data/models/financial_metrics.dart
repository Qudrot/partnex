import 'package:equatable/equatable.dart';

enum MetricStatus { positive, moderate, concerning, critical }

class ScoreDriver extends Equatable {
  final String name;
  final double scoreValue; // The 0-100 score mapped to this driver
  final String rawDisplayValue; // e.g., "+25% YoY" or "86.2% margin"
  final MetricStatus status; // High, Medium, Low, Critical status
  final double weight; // The percentage weight of this driver

  const ScoreDriver({
    required this.name,
    required this.scoreValue,
    required this.rawDisplayValue,
    required this.status,
    required this.weight,
  });

  @override
  List<Object?> get props => [name, scoreValue, rawDisplayValue, status, weight];

  double get impactPoints {
    if (status == MetricStatus.critical) {
      return -((100 - scoreValue) * weight);
    } else if (status == MetricStatus.concerning) {
      return -((100 - scoreValue) * weight * 0.5);
    }
    return scoreValue * weight;
  }
}

class FinancialMetrics extends Equatable {
  // Category 1: Revenue Metrics
  final double yoyGrowth;
  final double cagr;
  final double revenuePerEmployee;

  // Category 2: Profitability Metrics
  final double expenseRatio;
  final double profitMargin;
  final double monthlyProfit;

  // Category 3: Debt & Liabilities Metrics
  final double liabilitiesToRevenueRatio;
  final double debtServiceRatio;
  final double liabilitiesPerEmployee;
  final double liabilitiesCoverageRatio;

  // Category 4: Maturity Metrics
  final int yearsOfOperation;
  final double employeesPerYear;

  // Category 5: Efficiency Metrics
  final double revenueGrowthPerEmployee;

  // Final Derived Output (The Top 5 Drivers)
  final List<ScoreDriver> rankedDrivers;

  const FinancialMetrics({
    required this.yoyGrowth,
    required this.cagr,
    required this.revenuePerEmployee,
    required this.expenseRatio,
    required this.profitMargin,
    required this.monthlyProfit,
    required this.liabilitiesToRevenueRatio,
    required this.debtServiceRatio,
    required this.liabilitiesPerEmployee,
    required this.liabilitiesCoverageRatio,
    required this.yearsOfOperation,
    required this.employeesPerYear,
    required this.revenueGrowthPerEmployee,
    required this.rankedDrivers,
  });

  @override
  List<Object?> get props => [
        yoyGrowth, cagr, revenuePerEmployee,
        expenseRatio, profitMargin, monthlyProfit,
        liabilitiesToRevenueRatio, debtServiceRatio, liabilitiesPerEmployee, liabilitiesCoverageRatio,
        rankedDrivers,
      ];

  String getDriverExplanation(String driverName) {
    if (driverName.contains('Revenue Growth')) {
      final val = yoyGrowth.toStringAsFixed(yoyGrowth % 1 == 0 ? 0 : 1);
      return 'Measures your business\'s revenue trajectory. You have a $val% YoY growth rate. Consistent growth is key to credibility.';
    } else if (driverName.contains('Profitability')) {
      final exp = expenseRatio.toStringAsFixed(expenseRatio % 1 == 0 ? 0 : 1);
      final prof = profitMargin.toStringAsFixed(profitMargin % 1 == 0 ? 0 : 1);
      return 'Measures your ability to generate profit. Your expense ratio is $exp% with a profit margin of $prof%.';
    } else if (driverName.contains('Debt')) {
      final lib = liabilitiesToRevenueRatio.toStringAsFixed(liabilitiesToRevenueRatio % 1 == 0 ? 0 : 1);
      return 'Measures your debt relative to revenue. Your liabilities-to-revenue ratio is $lib%.';
    } else if (driverName.contains('Efficiency')) {
      return 'Measures operational output. You are generating ₦${(revenuePerEmployee / 1000000).toStringAsFixed(2)}M in revenue per employee.';
    } else if (driverName.contains('Maturity')) {
      return 'Measures business stability based on your $yearsOfOperation years of operation. Older businesses have more predictable performance.';
    }
    return 'This metric evaluates a key aspect of your business creditworthiness.';
  }

  Map<String, List<String>> getImprovementRecommendations() {
    final Map<String, List<String>> recommendations = {};

    for (var driver in rankedDrivers) {
      if (driver.status == MetricStatus.concerning || driver.status == MetricStatus.critical) {
        if (driver.name.contains("Revenue")) {
          recommendations[driver.name] = [
            '→ Maintain consistent revenue growth',
            '→ Document growth drivers and expand market reach',
          ];
        } else if (driver.name.contains("Profitability")) {
          recommendations[driver.name] = [
            '→ Audit expenses and identify cost-saving opportunities',
            '→ Negotiate supplier contracts to reduce overhead',
          ];
        } else if (driver.name.contains("Debt")) {
          recommendations[driver.name] = [
            '→ Develop a structured debt repayment plan',
            '→ Prioritize paying off high-interest liabilities first',
          ];
        } else if (driver.name.contains("Efficiency")) {
          recommendations[driver.name] = [
            '→ Invest in employee training and productivity tools',
            '→ Document operational processes for scalability',
          ];
        } else if (driver.name.contains("Maturity")) {
          recommendations[driver.name] = [
            '→ Focus on building a consistent track record',
            '→ Establish long-term 3-5 year growth plans',
          ];
        }
      }
    }
    return recommendations;
  }
}