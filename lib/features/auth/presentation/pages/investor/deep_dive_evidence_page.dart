import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';

class DeepDiveEvidencePage extends StatelessWidget {
  const DeepDiveEvidencePage({super.key});

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
          IconButton(
            icon: const Icon(LucideIcons.download, size: 20, color: AppColors.slate900),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          children: [
            // Score Summary / Assessment Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.successGreen),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.successGreen),
                        ),
                        child: Text(
                          'Low Risk',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Acme Manufacturing demonstrates strong financial health, consistent revenue growth, and reliable payment behavior. Low risk profile suitable for investment.',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.slate700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Evidence Sections (Expandable)
            _buildEvidenceSection(
              title: 'Revenue Consistency',
              contribution: '+15% impact on score',
              evidenceExplanation: 'Strong revenue consistency with low volatility across 3 years.',
              chartPlaceholderText: '[Line Chart: Year 1: ₦500K, Year 2: ₦600K, Year 3: ₦750K]',
              metrics: [
                {'YoY Growth': '+22%'},
                {'Monthly Avg': '₦1.2M'},
              ],
            ),
            const SizedBox(height: 12),
            _buildEvidenceSection(
              title: 'Expense Ratio',
              contribution: '-5% impact',
              contributionColor: AppColors.dangerRed,
              evidenceExplanation: 'Operating expenses have grown slightly faster than revenue.',
              chartPlaceholderText: '[Pie Chart: COGS 40%, OpEx 35%, Admin 15%, Other 10%]',
              metrics: [
                {'Monthly Revenue': '₦1.2M'},
                {'Monthly Expenses': '₦800K'},
                {'Profit Margin': '33%'},
              ],
            ),
            const SizedBox(height: 12),
            _buildEvidenceSection(
              title: 'Repayment Behavior',
              contribution: '+10% impact',
              evidenceExplanation: 'Perfect payment history; 24 of 24 payments on time.',
              chartPlaceholderText: '[Bar Chart: Timeline Jan-Dec 100% on time]',
              metrics: [
                {'Total Obligations': '24'},
                {'On-Time Payments': '24 (100%)'},
                {'Reliability Score': '100/100'},
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
              'Income Statement (Last 3 Years)',
              ['Metric', 'Year 1', 'Year 2', 'Year 3'],
              [
                ['Revenue', '500,000', '600,000', '750,000'],
                ['COGS', '200,000', '240,000', '300,000'],
                ['Gross Profit', '300,000', '360,000', '450,000'],
                ['Op. Expenses', '150,000', '180,000', '210,000'],
                ['Net Profit', '150,000', '180,000', '240,000'],
              ],
            ),
            const SizedBox(height: 24),
            _buildFinancialTableGroup(
              'Balance Sheet',
              ['Metric', 'Current', 'Non-Current', 'Total'],
              [
                ['Assets', '400,000', '800,000', '1,200,000'],
                ['Liabilities', '150,000', '250,000', '400,000'],
                ['Equity', '250,000', '550,000', '800,000'],
              ],
            ),
            const SizedBox(height: 24),
            _buildFinancialTableGroup(
              'Cash Flow',
              ['Metric', 'Year 1', 'Year 2', 'Year 3'],
              [
                ['Operating', '80,000', '110,000', '150,000'],
                ['Investing', '(50,000)', '(60,000)', '(80,000)'],
                ['Financing', '0', '0', '0'],
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
            _buildDocumentCard(
              title: 'Bank Statement (Oct - Dec)',
              metadata: '2.3 MB • Feb 20, 2026',
              iconData: LucideIcons.fileText,
            ),
            _buildDocumentCard(
              title: 'CAC Certificate',
              metadata: '1.8 MB • Feb 18, 2026',
              iconData: LucideIcons.image,
            ),

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
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
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
                color: Colors.white,
                border: Border.all(color: AppColors.slate200),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  chartPlaceholderText,
                  style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.slate400),
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
                 padding: const EdgeInsets.only(bottom: 6.0),
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

  Widget _buildFinancialTableGroup(String title, List<String> columns, List<List<String>> rows) {
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
            color: Colors.white,
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
              columns: columns.map((col) => DataColumn(
                label: Text(
                  col,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate900,
                  ),
                ),
              )).toList(),
              rows: rows.map((rowCells) {
                return DataRow(
                  cells: rowCells.map((cellValue) {
                    final isFirstCol = rowCells.indexOf(cellValue) == 0;
                    return DataCell(
                      Text(
                        cellValue,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          fontWeight: isFirstCol ? FontWeight.w600 : FontWeight.w400,
                          color: isFirstCol ? AppColors.slate900 : AppColors.slate700,
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

  Widget _buildDocumentCard({required String title, required String metadata, IconData iconData = LucideIcons.fileText}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
             icon: const Icon(LucideIcons.download, size: 20, color: AppColors.trustBlue),
             onPressed: () {},
          ),
        ],
      ),
    );
  }
}
