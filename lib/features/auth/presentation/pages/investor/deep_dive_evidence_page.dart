import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';

import 'package:partnex/features/auth/data/models/sme_profile_data.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:intl/intl.dart';

class DeepDiveEvidencePage extends StatelessWidget {
  final SmeCardData sme;
  const DeepDiveEvidencePage({super.key, required this.sme});

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
        title: Text(
          'Evidence & Details',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.slate900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          if (sme.dataSource != DataSource.selfReported)
            IconButton(
              icon: const Icon(
                LucideIcons.download,
                size: 20,
                color: AppColors.slate900,
              ),
              onPressed: () {},
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          children: [
            // Score Summary / Assessment Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: sme.scoreColor.withValues(alpha: 0.1),
                border: Border.all(color: sme.scoreColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Overall Assessment',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.slate900,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.neutralWhite.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: sme.scoreColor),
                        ),
                        child: Text(
                          sme.riskLevel,
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: sme.scoreColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${sme.companyName} demonstrates ${sme.riskLevel.toLowerCase()} risk based on current ${sme.dataSource == DataSource.selfReported ? 'manual data' : 'Bank data'} indicators. ${sme.bio ?? ""}',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.slate700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (sme.allowSharing) ...[
              // Evidence Sections (Expandable)
              _buildEvidenceSection(
                title: 'Revenue Consistency',
                contribution: sme.revenueTrendText,
                contributionColor: sme.revenueTrendColor,
                evidenceExplanation:
                    'Revenue trajectory based on ${sme.dataSource == DataSource.selfReported ? 'manual data' : 'Bank data'} analysis.',
                chartPlaceholderText:
                    '[Trend: ${sme.revenueTrendSignal} | Avg: ₦${(sme.annualRevenue / 12).toStringAsFixed(0)}]',
                metrics: [
                  {'YoY Trajectory': sme.revenueTrendText},
                  {'Annual Revenue': '₦${NumberFormat('#,###').format(sme.annualRevenue)}'},
                ],
              ),
              const SizedBox(height: 12),
              _buildEvidenceSection(
                title: 'Expense Ratio',
                contribution: sme.expenseRatioText,
                contributionColor: sme.expenseRatioColor,
                evidenceExplanation:
                    'Operating efficiency and profit margin calculated from ${sme.dataSource == DataSource.selfReported ? 'manual data' : 'Bank data'} outflows.',
                chartPlaceholderText:
                    '[Profit Margin: ${sme.profitMargin.toStringAsFixed(1)}%]',
                metrics: [
                  {'Monthly Expenses': '₦${NumberFormat('#,###').format(sme.monthlyExpenses)}'},
                  {'Profit Margin': '${sme.profitMargin.toStringAsFixed(1)}%'},
                ],
              ),
              const SizedBox(height: 12),
              _buildEvidenceSection(
                title: 'Repayment Behavior',
                contribution: sme.liabilitiesRatioText,
                contributionColor: sme.liabilitiesRatioColor,
                evidenceExplanation:
                    'Debt obligations and repayment history as ${sme.dataSource == DataSource.selfReported ? 'declared by the SME' : 'verified via Bank data'}.',
                chartPlaceholderText:
                    '[Liabilities Ratio: ${sme.liabilitiesRatio.toStringAsFixed(1)}%]',
                metrics: [
                  {'Total Liabilities': '₦${NumberFormat('#,###').format(sme.liabilities)}'},
                  {'Risk Signal': sme.liabilitiesRatioSignal},
                ],
              ),

              const SizedBox(height: 32),

              // Financial Statements
              Text(
                'Financial Statements',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.slate900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _buildFinancialTableGroup(
                'Key Financial Metrics (${sme.dataSource == DataSource.selfReported ? 'Manual Data' : 'Bank Data'})',
                ['Metric', 'Amount'],
                [
                  ['Annual Revenue', '₦${NumberFormat('#,###').format(sme.annualRevenue)}'],
                  ['Monthly Expenses', '₦${NumberFormat('#,###').format(sme.monthlyExpenses)}'],
                  ['Total Liabilities', '₦${NumberFormat('#,###').format(sme.liabilities)}'],
                  ['Net Profit (Est)', '₦${NumberFormat('#,###').format(sme.annualRevenue - (sme.monthlyExpenses * 12))}'],
                ],
              ),

              const SizedBox(height: 32),

              // Supporting Documents
              Text(
                'Supporting Documents',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.slate900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              
              if (sme.dataSource != DataSource.selfReported) ...[
                _buildDocumentCard(
                  title: 'Bank Statement (Extracted)',
                  metadata: 'Verified • ${DateFormat('MMM d, yyyy').format(sme.generatedAt)}',
                  iconData: LucideIcons.fileText,
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'This profile is based on manual data entry. No bank statements were provided for auto-extraction.',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.slate500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ] else ...[
              // Privacy Lock State
               Container(
                 margin: const EdgeInsets.only(top: 8),
                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                 decoration: BoxDecoration(
                   color: AppColors.slate50,
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: AppColors.slate200),
                 ),
                 child: Column(
                   children: [
                     const Icon(LucideIcons.lock, size: 36, color: AppColors.slate400),
                     const SizedBox(height: 16),
                     Text(
                       'Financial Data is Private',
                       style: AppTypography.textTheme.bodyLarge?.copyWith(
                         fontWeight: FontWeight.w600,
                         color: AppColors.slate900,
                       ),
                       textAlign: TextAlign.center,
                     ),
                     const SizedBox(height: 8),
                     Text(
                       '${sme.companyName} has chosen to keep their detailed financial records private at this time. If you are interested in exploring further, please initiate a conversation to request access.',
                       style: AppTypography.textTheme.bodyMedium?.copyWith(
                         color: AppColors.slate600,
                         height: 1.5,
                       ),
                       textAlign: TextAlign.center,
                     ),
                   ],
                 ),
               ),
            ],

            const SizedBox(height: 32),
            CustomButton(
              text: 'Back to Discovery',
              variant: ButtonVariant.secondary,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceSection({
    required String title,
    required String contribution,
    Color contributionColor = AppColors.trustBlue,
    required String evidenceExplanation,
    required String chartPlaceholderText,
    required List<Map<String, String>> metrics,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slate50,
        border: Border.all(color: AppColors.slate200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.slate600,
          collapsedIconColor: AppColors.slate600,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.slate900,
                ),
              ),
              Text(
                contribution,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: contributionColor,
                ),
              ),
            ],
          ),
          childrenPadding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
            top: 0,
          ),
          children: [
            Text(
              evidenceExplanation,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),

            // Visual Chart Placeholder
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                border: Border.all(color: AppColors.slate200),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  chartPlaceholderText,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.slate400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Key Metrics Breakdown
            ...metrics.map((m) {
              String key = m.keys.first;
              String val = m.values.first;
              return Padding(
                padding: EdgeInsets.only(bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      key,
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        color: AppColors.slate600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      val,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.slate900,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialTableGroup(
    String title,
    List<String> columns,
    List<List<String>> rows,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: AppTypography.textTheme.headlineSmall?.copyWith(
            color: AppColors.slate900,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.neutralWhite,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.slate200),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.slate50),
              dataRowMinHeight: 40,
              dataRowMaxHeight: 40,
              headingRowHeight: 40,
              columns: columns
                  .map(
                    (col) => DataColumn(
                      label: Text(
                        col,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate900,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              rows: rows.map((rowCells) {
                return DataRow(
                  cells: rowCells.map((cellValue) {
                    final isFirstCol = rowCells.indexOf(cellValue) == 0;
                    return DataCell(
                      Text(
                        cellValue,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          fontWeight: isFirstCol
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isFirstCol
                              ? AppColors.slate900
                              : AppColors.slate700,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String metadata,
    IconData iconData = LucideIcons.fileText,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          Icon(iconData, size: 24, color: AppColors.slate400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metadata,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.slate600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              LucideIcons.download,
              size: 20,
              color: AppColors.trustBlue,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
