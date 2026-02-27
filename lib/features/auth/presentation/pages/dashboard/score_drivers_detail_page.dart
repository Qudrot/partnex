import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';

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
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                color: AppColors.slate900,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          children: [
            // Score Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Your Score: 85',
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
                    color: AppColors.successGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Low Risk',
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
              driverName: 'Payment History',
              points: '90',
              percentageStr: '30%',
              percentage: 0.30,
              statusText: 'Positive',
              statusColor: AppColors.successGreen,
              explanation: 'Your payment history is excellent. You have made 24 of 24 payments on time.',
              initiallyExpanded: true,
            ),
            _buildDriverExpansionTile(
              driverName: 'Revenue Trend',
              points: '75',
              percentageStr: '25%',
              percentage: 0.25,
              statusText: 'Positive',
              statusColor: AppColors.successGreen,
              explanation: 'Your revenue shows consistent growth. Average YoY growth: 22.5%',
            ),
            _buildDriverExpansionTile(
              driverName: 'Expense Ratio',
              points: '60',
              percentageStr: '20%',
              percentage: 0.20,
              statusText: 'Healthy',
              statusColor: AppColors.warningAmber,
              explanation: 'Your expense-to-revenue ratio is within healthy range (60%).',
            ),
            _buildDriverExpansionTile(
              driverName: 'Liabilities',
              points: '40',
              percentageStr: '13%',
              percentage: 0.13,
              statusText: 'Moderate',
              statusColor: AppColors.warningAmber,
              explanation: 'Your liabilities are moderate relative to revenue. Consider reducing outstanding loans.',
            ),
            _buildDriverExpansionTile(
              driverName: 'Business Stability',
              points: '35',
              percentageStr: '12%',
              percentage: 0.12,
              statusText: 'Fair',
              statusColor: AppColors.dangerRed,
              explanation: 'Your business has been operating for 5 years. Longer operation history would improve this factor.',
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
      ),
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
