import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_state.dart';

class ScoreDriversDetailPage extends StatelessWidget {
  const ScoreDriversDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'Understanding your credibility score',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.x, color: AppColors.slate900),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: BlocBuilder<ScoreCubit, ScoreState>(
        builder: (context, state) {
          if (state is! ScoreLoadedSuccess || state.financialMetrics == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.trustBlue));
          }

          final metrics = state.financialMetrics!;
          final sc = metrics.totalCredibilityScore;
          final rLevel = state.score.riskLevel.name.toUpperCase();
          final rankedDrivers = metrics.rankedDrivers;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              children: [
                // Score Summary
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
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (rLevel == 'LOW') ? AppColors.successGreen : (rLevel == 'MEDIUM' ? AppColors.warningAmber : AppColors.dangerRed),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$rLevel RISK',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Primary Drivers
                Text(
                  'Primary Drivers (Top Impact)',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...rankedDrivers.take(3).map((driver) => _buildDriverExpansionTile(
                  driverName: driver.name,
                  points: (driver.contribution).toStringAsFixed(1),
                  percentageStr: '${(driver.weight * 100).toInt()}%',
                  percentage: driver.score / 100,
                  statusText: driver.score >= 80 ? 'Excellent' : (driver.score >= 50 ? 'Moderate' : 'Needs Work'),
                  statusColor: driver.score >= 80 ? AppColors.successGreen : (driver.score >= 50 ? AppColors.warningAmber : AppColors.dangerRed),
                  explanation: _getDriverExplanation(driver.name, metrics),
                  initiallyExpanded: rankedDrivers.indexOf(driver) == 0,
                )),

                const SizedBox(height: 24),
                // Secondary Drivers
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
                    children: rankedDrivers.skip(3).map((driver) => _buildDriverExpansionTile(
                      driverName: driver.name,
                      points: (driver.contribution).toStringAsFixed(1),
                      percentageStr: '${(driver.weight * 100).toInt()}%',
                      percentage: driver.score / 100,
                      statusText: driver.score >= 80 ? 'Excellent' : (driver.score >= 50 ? 'Moderate' : 'Needs Work'),
                      statusColor: driver.score >= 80 ? AppColors.successGreen : (driver.score >= 50 ? AppColors.warningAmber : AppColors.dangerRed),
                      explanation: _getDriverExplanation(driver.name, metrics),
                    )).toList(),
                  ),
                ),

                const SizedBox(height: 32),

                // Recommendations
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

            const SizedBox(height: 32),

            // Methodology Header
            Text(
              'How Your Score is Calculated',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.slate900,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your credibility score is calculated using machine learning models trained on historical financial data, payment patterns, and business metrics. The score ranges from 0-100, with higher scores indicating lower credit risk. Each factor is weighted based on its predictive power for business success and creditworthiness.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate600,
                fontSize: 14,
                height: 1.5,
              ),
            ),

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
      }),
    );
  }

  Widget _buildDriverExpansionTile({
    required String driverName,
    required String points,
    required String percentageStr,
    required double percentage,
    required String statusText,
    required Color statusColor,
    required String explanation,
    bool initiallyExpanded = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        border: Border.all(color: AppColors.slate200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          iconColor: AppColors.slate600,
          collapsedIconColor: AppColors.slate600,
          title: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.slate900,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        statusText,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.slate200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percentage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        percentageStr,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.slate600,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                points,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate900,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Text(
                explanation,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate600,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationSection({
    required String title,
    required List<String> items,
    required bool isPositive,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
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
            Color itemColor = isPositive ? AppColors.successGreen : AppColors.warningAmber;
            if (item.startsWith('✓')) {
              itemColor = AppColors.successGreen;
            } else if (item.startsWith('→')) {
              itemColor = AppColors.trustBlue;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                item,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: itemColor,
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

  String _getDriverExplanation(String driverName, dynamic metrics) {
    switch (driverName) {
      case 'Revenue Trend':
        return 'Your revenue trend score is based on CAGR of ${metrics.cagr.toStringAsFixed(1)}% and volatility of ${metrics.revenueVolatility.toStringAsFixed(2)}. Growth consistency is key to credibility.';
      case 'Expense Ratio':
        return 'Operating expenses ratio is ${metrics.expenseRatio.toStringAsFixed(1)}%. Keeping expenses below 70% of revenue ensures healthy profit margins.';
      case 'Liabilities Burden':
        return 'Debt-to-revenue ratio is ${metrics.debtToRevenueRatio.toStringAsFixed(1)}%. Lower debt relative to revenue indicates better repayment capacity.';
      case 'Payment History':
        return 'On-time payment rate is ${metrics.onTimePaymentRate.toStringAsFixed(0)}%. Consistent on-time payments are the strongest indicator of reliability.';
      case 'Business Stability':
        return 'Stability score is based on your years of operation. Older businesses generally have more predictable and stable performance.';
      case 'Financial Documentation':
        return 'Score reflects the completeness and quality of submitted records. Recent and consistent documents build high trust.';
      default:
        return 'This metric evaluates a key aspect of your business creditworthiness.';
    }
  }

  List<Widget> _generateRecommendations(dynamic metrics) {
    List<Widget> sections = [];

    // Revenue
    if (metrics.revenueTrendScore < 80) {
      sections.add(_buildRecommendationSection(
        title: 'Revenue Trend:',
        items: [
          metrics.cagr < 5 ? '→ Develop new revenue channels' : '→ Maintain consistent revenue growth',
          metrics.revenueVolatility > 0.5 ? '→ Stabilize revenue fluctuations' : '→ Continue diversifying revenue streams',
        ],
        isPositive: false,
      ));
    }

    // Expense
    if (metrics.expenseRatioScore < 80) {
      sections.add(_buildRecommendationSection(
        title: 'Expense Ratio:',
        items: [
          metrics.expenseRatio > 75 ? '→ Implement cost reduction program' : '→ Optimize operational costs',
          '→ Improve efficiency by limiting non-essential spending',
        ],
        isPositive: false,
      ));
    }

    // Liabilities
    if (metrics.liabilitiesBurdenScore < 80) {
      sections.add(_buildRecommendationSection(
        title: 'Liabilities:',
        items: [
          metrics.debtToRevenueRatio > 50 ? '→ Develop debt reduction strategy' : '→ Maintain low debt levels',
          '→ Prioritize repayment of high-interest obligations',
        ],
        isPositive: false,
      ));
    }

    if (sections.isEmpty) {
      sections.add(const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Your metrics are strong! Maintain your current financial discipline.'),
      ));
    }

    return sections;
  }
}
