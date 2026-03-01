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
          if (state is! ScoreLoadedSuccess) {
            return const Center(child: CircularProgressIndicator(color: AppColors.trustBlue));
          }

          final sc = state.score.totalScore;
          final rLevel = state.score.riskLevel.name.toUpperCase();
          final rev = double.tryParse(state.smeProfile['monthly_revenue']?.toString() ?? '0') ?? 0.0;
          final exp = double.tryParse(state.smeProfile['monthly_expenses']?.toString() ?? '0') ?? 0.0;
          final liab = double.tryParse(state.smeProfile['existing_liabilities']?.toString() ?? '0') ?? 0.0;
          final yrs = int.tryParse(state.smeProfile['years_of_operation']?.toString() ?? '0') ?? 0;

          final opexRatio = rev > 0 ? (exp/rev) : 1.0;
          final debtRatio = rev > 0 ? (liab/(rev*12)) : 1.0;

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

                // Score Composition
                _buildDriverExpansionTile(
                  driverName: 'Opex Ratio Health',
                  points: (sc * 0.4).toInt().toString(),
                  percentageStr: '40%',
                  percentage: 0.40,
                  statusText: opexRatio > 0.8 ? 'Needs Work' : (opexRatio > 0.5 ? 'Moderate' : 'Healthy'),
                  statusColor: opexRatio > 0.8 ? AppColors.dangerRed : (opexRatio > 0.5 ? AppColors.warningAmber : AppColors.successGreen),
                  explanation: 'Operating expenses ratio is ${(opexRatio*100).toStringAsFixed(1)}%. Keeping expenses below 50% of revenue ensures strong profit margins.',
                  initiallyExpanded: true,
                ),
                _buildDriverExpansionTile(
                  driverName: 'Liabilities Burden',
                  points: (sc * 0.35).toInt().toString(),
                  percentageStr: '35%',
                  percentage: 0.35,
                  statusText: debtRatio > 0.5 ? 'High Debt' : (debtRatio > 0.2 ? 'Moderate' : 'Low Debt'),
                  statusColor: debtRatio > 0.5 ? AppColors.dangerRed : (debtRatio > 0.2 ? AppColors.warningAmber : AppColors.successGreen),
                  explanation: 'Your liabilities are roughly ${(debtRatio*100).toStringAsFixed(1)}% of annualized projected revenue. Maintaining low debt allows for growth stability.',
                ),
                _buildDriverExpansionTile(
                  driverName: 'Business Stability',
                  points: (sc * 0.25).toInt().toString(),
                  percentageStr: '25%',
                  percentage: 0.25,
                  statusText: yrs > 5 ? 'Excellent' : (yrs > 2 ? 'Fair' : 'New Business'),
                  statusColor: yrs > 5 ? AppColors.successGreen : (yrs > 2 ? AppColors.trustBlue : AppColors.warningAmber),
                  explanation: 'Your business has been operating for $yrs years. Longer history and continuity directly boost stability confidence.',
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

            _buildRecommendationSection(
              title: 'Payment History:',
              items: [
                '✓ Maintain your excellent payment record',
                '✓ Continue paying all obligations on time',
              ],
              isPositive: true,
            ),
            _buildRecommendationSection(
              title: 'Revenue Trend:',
              items: [
                '✓ Maintain consistent revenue growth',
                '✓ Consider diversifying revenue streams',
              ],
              isPositive: true,
            ),
            _buildRecommendationSection(
              title: 'Expense Ratio:',
              items: [
                '→ Reduce monthly expenses by 5-10% to improve profit margin',
                '→ Optimize operational costs without sacrificing quality',
              ],
              isPositive: false,
            ),
            _buildRecommendationSection(
              title: 'Liabilities:',
              items: [
                '→ Reduce outstanding liabilities by ₦50K to improve score',
                '→ Consider refinancing high-interest loans',
              ],
              isPositive: false,
            ),
            _buildRecommendationSection(
              title: 'Business Stability:',
              items: [
                '→ Continue building business track record',
                '→ Document long-term growth plans',
              ],
              isPositive: false,
            ),

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
            if (!isPositive && item.startsWith('→ Focus') || item.contains('Build') || item.contains('history')) {
              itemColor = AppColors.dangerRed;
            }
            // For simplicity, make arrow items info/warning color, and checkmark items green
            if (item.startsWith('✓')) {
              itemColor = AppColors.successGreen;
            } else if (item.startsWith('→')) {
              itemColor = AppColors.trustBlue; // Actionable
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
}
