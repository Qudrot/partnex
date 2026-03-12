import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/driver_card.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_state.dart';
import 'package:partnex/features/auth/data/models/financial_metrics.dart';

class ScoreDriversDetailPage extends StatelessWidget {
  const ScoreDriversDetailPage({super.key});

  DriverRiskLevel _mapRiskLevel(MetricStatus status) {
    switch (status) {
      case MetricStatus.positive:
        return DriverRiskLevel.excellent;
      case MetricStatus.moderate:
        return DriverRiskLevel.moderate;
      case MetricStatus.concerning:
        return DriverRiskLevel.needsWork;
      case MetricStatus.critical:
        return DriverRiskLevel.critical;
    }
  }

  double _calculateImpactPoints(
    MetricStatus status,
    double scoreValue,
    double weight,
  ) {
    if (status == MetricStatus.critical) {
      return -((100 - scoreValue) * weight);
    } else if (status == MetricStatus.concerning) {
      return -((100 - scoreValue) * weight * 0.5);
    }
    return scoreValue * weight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.neutralWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Score Breakdown',
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.slate900,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ScoreCubit, ScoreState>(
        builder: (context, state) {
          if (state is! ScoreLoadedSuccess || state.financialMetrics == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.trustBlue),
            );
          }

          final metrics = state.financialMetrics!;
          final sc = state.score.totalScore;
          final rLevel = state.score.riskLevel.name.toUpperCase();
          final rankedDrivers = metrics.rankedDrivers;

          return SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xl,
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your Score: ${sc.toInt()}',
                      style: AppTypography.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                        fontSize: 28,
                      ),
                    ),
                    SizedBox(width: AppSpacing.smd),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (rLevel == 'LOW')
                            ? AppColors.successGreen
                            : (rLevel == 'MEDIUM'
                                  ? AppColors.warningOrange
                                  : AppColors.dangerRed),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        '$rLevel RISK',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutralWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Text(
                  'Primary Drivers (Top Impact)',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),

                ...rankedDrivers
                    .take(3)
                    .map(
                      (driver) => DriverCard(
                        driverName: driver.name,
                        riskLevel: _mapRiskLevel(driver.status),
                        percentage: driver.scoreValue,
                        impactPoints: _calculateImpactPoints(
                          driver.status,
                          driver.scoreValue,
                          driver.weight,
                        ),
                        description: _getDriverExplanation(
                          driver.name,
                          metrics,
                        ),
                        initiallyExpanded: rankedDrivers.indexOf(driver) == 0,
                      ),
                    ),

                const SizedBox(height: 24),

                Theme(
                  data: ThemeData(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(
                      'Secondary Drivers',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.slate600,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    tilePadding: EdgeInsets.zero,
                    children: rankedDrivers
                        .skip(3)
                        .map(
                          (driver) => DriverCard(
                            driverName: driver.name,
                            riskLevel: _mapRiskLevel(driver.status),
                            percentage: driver.scoreValue,
                            impactPoints: _calculateImpactPoints(
                              driver.status,
                              driver.scoreValue,
                              driver.weight,
                            ),
                            description: _getDriverExplanation(
                              driver.name,
                              metrics,
                            ),
                            initiallyExpanded: false,
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 32),
                Text(
                  'Improvement Recommendations',
                  style: AppTypography.textTheme.headlineMedium?.copyWith(
                    color: AppColors.slate900,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                ..._generateRecommendations(metrics),

                const SizedBox(height: 32),
                CustomButton(
                  text: 'Back to Dashboard',
                  variant: ButtonVariant.primary,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendationSection({
    required String title,
    required List<String> items,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.slate900,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Text(
                item,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.trustBlue,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getDriverExplanation(String driverName, FinancialMetrics metrics) {
    if (driverName.contains('Revenue Growth')) {
      final val = metrics.yoyGrowth.toStringAsFixed(metrics.yoyGrowth % 1 == 0 ? 0 : 1);
      return 'Measures your business\'s revenue trajectory. You have a $val% YoY growth rate. Consistent growth is key to credibility.';
    } else if (driverName.contains('Profitability')) {
      final exp = metrics.expenseRatio.toStringAsFixed(metrics.expenseRatio % 1 == 0 ? 0 : 1);
      final prof = metrics.profitMargin.toStringAsFixed(metrics.profitMargin % 1 == 0 ? 0 : 1);
      return 'Measures your ability to generate profit. Your expense ratio is $exp% with a profit margin of $prof%.';
    } else if (driverName.contains('Debt')) {
      final lib = metrics.liabilitiesToRevenueRatio.toStringAsFixed(metrics.liabilitiesToRevenueRatio % 1 == 0 ? 0 : 1);
      return 'Measures your debt relative to revenue. Your liabilities-to-revenue ratio is $lib%.';
    } else if (driverName.contains('Efficiency')) {
      return 'Measures operational output. You are generating ₦${(metrics.revenuePerEmployee / 1000000).toStringAsFixed(2)}M in revenue per employee.';
    } else if (driverName.contains('Maturity')) {
      return 'Measures business stability based on your ${metrics.yearsOfOperation} years of operation. Older businesses have more predictable performance.';
    }
    return 'This metric evaluates a key aspect of your business creditworthiness.';
  }

  List<Widget> _generateRecommendations(FinancialMetrics metrics) {
    List<Widget> sections = [];

    for (var driver in metrics.rankedDrivers) {
      if (driver.status == MetricStatus.concerning ||
          driver.status == MetricStatus.critical) {
        List<String> items = [];

        if (driver.name.contains("Revenue")) {
          items = [
            '→ Maintain consistent revenue growth',
            '→ Document growth drivers and expand market reach',
          ];
        } else if (driver.name.contains("Profitability")) {
          items = [
            '→ Audit expenses and identify cost-saving opportunities',
            '→ Negotiate supplier contracts to reduce overhead',
          ];
        } else if (driver.name.contains("Debt")) {
          items = [
            '→ Develop a structured debt repayment plan',
            '→ Prioritize paying off high-interest liabilities first',
          ];
        } else if (driver.name.contains("Efficiency")) {
          items = [
            '→ Invest in employee training and productivity tools',
            '→ Document operational processes for scalability',
          ];
        } else if (driver.name.contains("Maturity")) {
          items = [
            '→ Focus on building a consistent track record',
            '→ Establish long-term 3-5 year growth plans',
          ];
        }

        sections.add(
          _buildRecommendationSection(title: '${driver.name}:', items: items),
        );
      }
    }

    if (sections.isEmpty) {
      sections.add(
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Your metrics are incredibly strong! Maintain your current financial discipline to keep your high credibility rating.',
          ),
        ),
      );
    }

    return sections;
  }
}
