import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/features/auth/data/models/sme_profile_data.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';

// Advanced Charts Imports
import 'package:partnex/core/theme/widgets/advanced_charts/circular_rings_chart.dart';
import 'package:partnex/core/theme/widgets/advanced_charts/cagr_timeline_chart.dart';
import 'package:partnex/core/theme/widgets/advanced_charts/horizontal_bar_chart.dart';
import 'package:partnex/core/theme/widgets/advanced_charts/donut_chart.dart';
import 'package:partnex/core/theme/widgets/advanced_charts/gauge_chart.dart';
import 'package:partnex/core/theme/widgets/advanced_charts/column_chart.dart';
import 'package:partnex/core/theme/widgets/advanced_charts/timeline_chart.dart';

class BusinessInsightsPage extends StatelessWidget {
  final SmeCardData sme;
  final bool isSmeView;

  const BusinessInsightsPage({
    super.key, 
    required this.sme,
    this.isSmeView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.neutralWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Business Insights',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.slate900,
          ),
        ),
        centerTitle: true,
        actions: [
          if (sme.dataSource != DataSource.selfReported)
            IconButton(
              icon: const Icon(LucideIcons.download, size: 20, color: AppColors.slate900),
              onPressed: () {},
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    // Dynamic Display Logic
    final bool hasHistory = sme.previousAnnualRevenue > 0;
    final bool hasRevenue = sme.annualRevenue > 0;
    final bool hasExpenses = sme.monthlyExpenses > 0;
    final bool hasLiabilities = sme.liabilities > 0;
    final bool hasEmployees = sme.numberOfEmployees > 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isDesktop = width > 1024;
        final int crossAxisCount = isDesktop ? 2 : 1;
        
        // Ensure child width is consistent
        final double spacing = 16.0;

        return ListView(
          padding: EdgeInsets.symmetric(horizontal: spacing, vertical: spacing),
          children: [
            _buildAssessmentBox(),
            const SizedBox(height: 24),
            
            if (!sme.allowSharing) 
              _buildPrivacyLock()
            else ...[
            Text(
              'Performance Metrics',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.slate900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                // Revenue Metrics
                if (hasHistory) ...[
                  _wrapItem(crossAxisCount, spacing, _buildYoYGrowthCard()),
                  _wrapItem(crossAxisCount, spacing, _buildCAGRCard()),
                ],
                if (hasRevenue && hasEmployees)
                  _wrapItem(crossAxisCount, spacing, _buildRevenuePerEmployeeCard()),

                // Profitability
                if (hasExpenses && hasRevenue) ...[
                  _wrapItem(crossAxisCount, spacing, _buildExpenseRatioCard()),
                  _wrapItem(crossAxisCount, spacing, _buildProfitMarginCard()),
                  _wrapItem(crossAxisCount, spacing, _buildMonthlyProfitCard()),
                ],

                // Debt
                if (hasLiabilities && hasRevenue) ...[
                  _wrapItem(crossAxisCount, spacing, _buildLiabilitiesToRevenueCard()),
                  _wrapItem(crossAxisCount, spacing, _buildDebtServiceRatioCard()),
                ],
                if (hasLiabilities && hasEmployees)
                  _wrapItem(crossAxisCount, spacing, _buildLiabilitiesPerEmployeeCard()),
                if (hasLiabilities && (sme.annualRevenue - sme.monthlyExpenses * 12) > 0)
                  _wrapItem(crossAxisCount, spacing, _buildLiabilitiesCoverageCard()),

                // Maturity
                _wrapItem(crossAxisCount, spacing, _buildYearsOfOperationCard()),
                if (hasEmployees)
                  _wrapItem(crossAxisCount, spacing, _buildEmployeesPerYearCard()),

                // Efficiency
                if (hasHistory && hasEmployees)
                  // Full width for this one if we want, or regular item. Spec says full width on row 7.
                  _wrapItem(1, spacing, _buildRevenueGrowthPerEmployeeCard()),
              ],
            ),
            const SizedBox(height: 32),
            _buildFinancialStatementsRow(),
            ],
          ],
        );
      },
    );
  }

  Widget _wrapItem(int columns, double spacing, Widget child) {
    if (columns == 1) return SizedBox(width: double.infinity, child: child);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          // Subtract padding between columns
          width: (constraints.maxWidth - spacing) / 2, 
          child: child,
        );
      }
    );
  }

  Widget _buildAssessmentBox() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.successGreen),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Assessment',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neutralWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.successGreen),
                ),
                child: Text(
                  sme.riskLevel.toUpperCase(),
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.successGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ExpandableAssessmentText(text: sme.getFinancialAssessment(isOwnProfile: isSmeView)),
        ],
      ),
    );
  }

  // 1.1 YoY Revenue Growth
  Widget _buildYoYGrowthCard() {
    return _buildMetricCard(
      title: 'YoY Revenue Growth',
      subtitle: 'Year-over-year growth visualization',
      chart: CircularRingsChart(
        data: CircularRingsChartData(
          baseLabel: sme.annualRevenueYear2 > 0 ? '${sme.annualRevenueYear2}' : 'Year 1',
          baseValue: sme.previousAnnualRevenue,
          finalLabel: sme.annualRevenueYear1 > 0 ? '${sme.annualRevenueYear1}' : 'Year 2',
          finalValue: sme.annualRevenue,
          thirdLabel: sme.annualRevenueYear3 > 0 ? '${sme.annualRevenueYear3}' : null,
          thirdValue: sme.annualRevenueYear3 > 0 ? sme.annualRevenueAmount3 : null,
        ),
        positiveColor: AppColors.successGreen,
        negativeColor: AppColors.dangerRed,
        baseColor: AppColors.trustBlue,
        thirdColor: AppColors.slate400,
      ),
      summary: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Growth Rate', style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.slate600)),
              Text('${sme.yoyGrowth > 0 ? '+' : ''}${sme.yoyGrowth.toStringAsFixed(1)}% YoY', 
                style: AppTypography.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: sme.revenueTrendColor)),
            ],
          ),
        ],
      ),
    );
  }

  // 1.2 CAGR
  Widget _buildCAGRCard() {
    double nYears = 1.0;
    double totalMultiplier = 1.0;
    
    if (sme.annualRevenueAmount3 > 0 && sme.annualRevenueYear3 > 0 && sme.annualRevenueYear1 > 0) {
      nYears = (sme.annualRevenueYear1 - sme.annualRevenueYear3).toDouble().clamp(1.0, 100.0);
      totalMultiplier = sme.annualRevenue / sme.annualRevenueAmount3;
    } else if (sme.previousAnnualRevenue > 0 && sme.annualRevenueYear2 > 0 && sme.annualRevenueYear1 > 0) {
      nYears = (sme.annualRevenueYear1 - sme.annualRevenueYear2).toDouble().clamp(1.0, 100.0);
      totalMultiplier = sme.annualRevenue / sme.previousAnnualRevenue;
    } else if (sme.previousAnnualRevenue > 0) {
      nYears = 1.0;
      totalMultiplier = sme.annualRevenue / sme.previousAnnualRevenue;
    }

    final double cagr = totalMultiplier > 0 ? (math.pow(totalMultiplier, 1 / nYears) - 1) * 100 : 0.0;
    final double projectedYNext = sme.annualRevenue * math.pow(1 + (cagr / 100), 1);

    final List<CAGRTimelinePoint> timelinePoints = [];

    // Add Year 3 (Earliest) if exists
    if (sme.annualRevenueAmount3 > 0) {
      timelinePoints.add(CAGRTimelinePoint(
        yearLabel: sme.annualRevenueYear3 > 0 ? '${sme.annualRevenueYear3}' : 'Year 1',
        revenue: sme.annualRevenueAmount3,
        growthRate: null,
      ));
    }

    // Add Year 2 (Middle)
    timelinePoints.add(CAGRTimelinePoint(
      yearLabel: sme.annualRevenueYear2 > 0 ? '${sme.annualRevenueYear2}' : (timelinePoints.isEmpty ? 'Year 1' : 'Year 2'),
      revenue: sme.previousAnnualRevenue,
      growthRate: timelinePoints.isNotEmpty
          ? ((sme.previousAnnualRevenue - timelinePoints.last.revenue) / timelinePoints.last.revenue) * 100
          : null,
    ));

    // Add Year 1 (Latest Activity)
    timelinePoints.add(CAGRTimelinePoint(
      yearLabel: sme.annualRevenueYear1 > 0 ? '${sme.annualRevenueYear1}' : 'Year ${timelinePoints.length + 1}',
      revenue: sme.annualRevenue,
      growthRate: ((sme.annualRevenue - sme.previousAnnualRevenue) / sme.previousAnnualRevenue) * 100,
    ));

    // Add Projected Year
    if (sme.annualRevenue > 0) {
      timelinePoints.add(CAGRTimelinePoint(
        yearLabel: sme.annualRevenueYear1 > 0 ? '${sme.annualRevenueYear1 + 1}' : 'Projected',
        revenue: projectedYNext,
        growthRate: cagr,
        isProjected: true,
      ));
    }

    return _buildMetricCard(
      title: 'CAGR',
      subtitle: 'Compound annual growth rate trajectory',
      chart: CAGRTimelineChart(
        points: timelinePoints,
        positiveColor: AppColors.successGreen,
        negativeColor: AppColors.dangerRed,
        baseColor: AppColors.trustBlue,
      ),
      summary: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Compounded Rate', style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.slate600)),
          Text(
            '${cagr > 0 ? '+' : ''}${cagr.toStringAsFixed(1)}% / yr',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cagr >= 0 ? AppColors.successGreen : AppColors.dangerRed,
            ),
          ),
        ],
      ),
    );
  }

  // 1.3 Revenue per Employee
  Widget _buildRevenuePerEmployeeCard() {
    final double revPerEmp = sme.annualRevenue / sme.numberOfEmployees;
    final double benchmark = 2000000; // 2M NGN benchmark
    final Color color = revPerEmp >= benchmark ? AppColors.successGreen : AppColors.warningOrange;
    return _buildMetricCard(
      title: 'Revenue per Employee',
      subtitle: 'Revenue efficiency per workforce member',
      chart: HorizontalBarChart(
        currentValue: revPerEmp,
        benchmarkValue: benchmark,
        statusColor: color,
        maxValue: benchmark * 1.5,
        currentLabel: '₦${(revPerEmp/1000000).toStringAsFixed(2)}M',
      ),
      summary: Text('Employees: ${sme.numberOfEmployees} | Status: ${revPerEmp >= benchmark ? 'Positive' : 'Concerning'}', style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.slate600)),
    );
  }

  // 2.1 Expense Ratio
  Widget _buildExpenseRatioCard() {
    return _buildMetricCard(
      title: 'Expense Ratio',
      subtitle: 'Operating efficiency and profit margin',
      chart: Center(
        child: DonutChart(
          primaryPercentage: sme.expenseRatio,
          secondaryPercentage: sme.profitMargin.clamp(0, 100),
          primaryColor: sme.expenseRatioColor,
          secondaryColor: sme.expenseRatioColor.withValues(alpha: 0.2),
          centerLabel: '${sme.expenseRatio.toStringAsFixed(0)}%',
          centerSubLabel: 'Expenses',
        ),
      ),
      summary: Text('Monthly Expenses: ₦${NumberFormat('#,###').format(sme.monthlyExpenses)}', style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.slate600)),
    );
  }

  // 2.2 Profit Margin
  Widget _buildProfitMarginCard() {
    return _buildMetricCard(
      title: 'Profit Margin',
      subtitle: 'Percentage of revenue remaining as profit',
      chart: GaugeChart(
        currentValue: sme.profitMargin,
        targetValue: 20,
        zones: [
          GaugeZone(startValue: 0, endValue: 5, color: AppColors.dangerRed, label: 'Critical'),
          GaugeZone(startValue: 5, endValue: 10, color: AppColors.warningAmber, label: 'Concerning'),
          GaugeZone(startValue: 10, endValue: 20, color: AppColors.warningOrange, label: 'Moderate'),
          GaugeZone(startValue: 20, endValue: 30, color: AppColors.successGreen, label: 'Healthy'),
        ],
      ),
      summary: Text('Annual Profit: ₦${NumberFormat('#,###').format(sme.annualRevenue - sme.monthlyExpenses * 12)}', style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.slate600)),
    );
  }

  // 2.3 Monthly Profit
  Widget _buildMonthlyProfitCard() {
    final double avgProfit = (sme.annualRevenue / 12) - sme.monthlyExpenses;
    return _buildMetricCard(
      title: 'Monthly Profit',
      subtitle: 'Monthly cash profit after expenses',
      chart: HorizontalBarChart(
        currentValue: avgProfit > 0 ? avgProfit : 0,
        benchmarkValue: 0,
        statusColor: avgProfit > 0 ? AppColors.trustBlue : AppColors.dangerRed,
        maxValue: avgProfit > 0 ? avgProfit * 1.2 : 1.0,
        currentLabel: '₦${(avgProfit/1000).toStringAsFixed(0)}K',
        showBenchmarkLabels: false,
      ),
      summary: Text('Avg Monthly Profit: ₦${NumberFormat('#,###').format(avgProfit)}', style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.slate600)),
    );
  }

  // 3.1 Liabilities-to-Revenue
  Widget _buildLiabilitiesToRevenueCard() {
    return _buildMetricCard(
      title: 'Liabilities-to-Revenue',
      subtitle: 'Debt obligations relative to revenue',
      chart: GaugeChart(
        currentValue: sme.liabilitiesRatio,
        targetValue: 20,
        zones: [
          GaugeZone(startValue: 0, endValue: 20, color: AppColors.successGreen, label: 'Healthy'),
          GaugeZone(startValue: 20, endValue: 35, color: AppColors.trustBlue, label: 'Moderate'),
          GaugeZone(startValue: 35, endValue: 50, color: AppColors.warningAmber, label: 'Concerning'),
          GaugeZone(startValue: 50, endValue: 70, color: AppColors.dangerRed, label: 'Critical'),
        ],
      ),
      summary: Text('Liabilities: ₦${NumberFormat('#,###').format(sme.liabilities)}', style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.slate600)),
    );
  }

  // 3.2 Debt Service Ratio
  Widget _buildDebtServiceRatioCard() {
    final annualProfit = sme.annualRevenue - (sme.monthlyExpenses * 12);
    final ratio = annualProfit > 0 ? (sme.liabilities / annualProfit) * 100 : 300.0;
    return _buildMetricCard(
      title: 'Debt Service Ratio',
      subtitle: 'Profit needed to pay off liabilities',
      chart: GaugeChart(
        currentValue: ratio,
        targetValue: 100,
        zones: [
          GaugeZone(startValue: 0, endValue: 100, color: AppColors.successGreen, label: '1 yr'),
          GaugeZone(startValue: 100, endValue: 150, color: AppColors.trustBlue, label: '1.5 yrs'),
          GaugeZone(startValue: 150, endValue: 200, color: AppColors.warningAmber, label: '2 yrs'),
          GaugeZone(startValue: 200, endValue: 300, color: AppColors.dangerRed, label: '3+ yrs'),
        ],
      ),
      summary: Text('Ratio: ${ratio.toStringAsFixed(1)}%', style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.slate600)),
    );
  }

  // 3.3 Liabilities per Employee
  Widget _buildLiabilitiesPerEmployeeCard() {
    final double val = sme.liabilities / sme.numberOfEmployees;
    final double bench = 500000;
    return _buildMetricCard(
      title: 'Liabilities per Employee',
      subtitle: 'Debt burden per workforce member',
      chart: HorizontalBarChart(
        currentValue: val,
        benchmarkValue: bench,
        statusColor: val < bench ? AppColors.successGreen : AppColors.warningAmber,
        maxValue: bench * 2,
        currentLabel: '₦${(val/1000).toStringAsFixed(0)}K',
      ),
      summary: Text('Target: < ₦500K / employee', style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.slate600)),
    );
  }

  // 3.4 Liabilities Coverage
  Widget _buildLiabilitiesCoverageCard() {
    final annualProfit = sme.annualRevenue - (sme.monthlyExpenses * 12);
    final coverage = annualProfit / sme.liabilities;
    return _buildMetricCard(
      title: 'Liabilities Coverage',
      subtitle: 'Annual profit vs liabilities',
      chart: GaugeChart(
        currentValue: (sme.liabilities / sme.annualRevenue).clamp(0.0, 1.0) * 100, // percentage for gauge
        targetValue: 1.0,
        zones: [
          GaugeZone(startValue: 0, endValue: 0.25, color: AppColors.dangerRed, label: 'Critical'),
          GaugeZone(startValue: 0.25, endValue: 0.75, color: AppColors.warningOrange, label: 'Concerning'),
          GaugeZone(startValue: 0.75, endValue: 1.0, color: AppColors.trustBlue, label: 'Moderate'),
          GaugeZone(startValue: 1.0, endValue: 2.5, color: AppColors.successGreen, label: 'Healthy'),
        ],
      ),
      summary: Text('Coverage Ratio: ${coverage.toStringAsFixed(2)}', style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.slate600)),
    );
  }

  // 4.1 Years of Operation
  Widget _buildYearsOfOperationCard() {
    return _buildMetricCard(
      title: 'Years of Operation',
      subtitle: 'Business age and maturity stage',
      chart: TimelineChart(
        currentYear: sme.yearsOfOperation,
        statusColor: _getMaturityColor(sme.yearsOfOperation),
        milestones: [
          TimelineMilestone(year: 0, label: '0 yrs'),
          TimelineMilestone(year: 2, label: '2 yrs'),
          TimelineMilestone(year: 5, label: '5 yrs'),
        ],
      ),
      summary: Text('Current: ${sme.yearsOfOperation} years', style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.slate600)),
    );
  }

  Color _getMaturityColor(int years) {
    if (years < 1) return AppColors.dangerRed;
    if (years < 3) return AppColors.warningAmber;
    if (years < 5) return AppColors.trustBlue;
    return AppColors.successGreen;
  }

  // 4.2 Employees per Year
  Widget _buildEmployeesPerYearCard() {
    final rate = sme.numberOfEmployees / sme.yearsOfOperation.clamp(1, 100);
    return _buildMetricCard(
      title: 'Employees per Year',
      subtitle: 'Hiring and growth rate',
      chart: HorizontalBarChart(
        currentValue: rate,
        benchmarkValue: 0,
         statusColor: rate > 3 ? AppColors.successGreen : AppColors.trustBlue,
        maxValue: math.max(10.0, rate * 1.2),
        currentLabel: '${rate.toStringAsFixed(1)} / yr',
        showBenchmarkLabels: false,
      ),
      summary: Text('Avg Hiring Rate: ${rate.toStringAsFixed(1)} / year', style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.slate600)),
    );
  }

  // 5.1 Revenue Growth per Employee
  Widget _buildRevenueGrowthPerEmployeeCard() {
    final growth = sme.annualRevenue - sme.previousAnnualRevenue;
    final val = growth / sme.numberOfEmployees;
    final bench = 500000.0;
    return _buildMetricCard(
      title: 'Revenue Growth / Employee',
      subtitle: 'Growth contribution per employee',
      chart: HorizontalBarChart(
        currentValue: val,
        benchmarkValue: bench,
        statusColor: val >= bench ? AppColors.successGreen : AppColors.warningAmber,
        maxValue: bench * 2,
        currentLabel: '₦${(val/1000).toStringAsFixed(0)}K',
      ),
      summary: Text('Total Growth: ₦${NumberFormat('#,###').format(growth)}', style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.slate600)),
    );
  }

  Widget _buildFinancialStatementsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Financial Statements',
          style: AppTypography.textTheme.headlineSmall?.copyWith(color: AppColors.slate900, fontSize: 18),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.neutralWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.slate200),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.slate50),
            columns: [
              DataColumn(label: Text('Metric', style: AppTypography.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
              DataColumn(label: Text('Amount', style: AppTypography.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
            ],
            rows: [
              if (sme.annualRevenueYear1 > 0)
                DataRow(cells: [DataCell(Text('Revenue (${sme.annualRevenueYear1})')), DataCell(Text('₦${NumberFormat('#,###').format(sme.annualRevenue)}'))]),
              if (sme.annualRevenueYear2 > 0)
                DataRow(cells: [DataCell(Text('Revenue (${sme.annualRevenueYear2})')), DataCell(Text('₦${NumberFormat('#,###').format(sme.previousAnnualRevenue)}'))]),
              if (sme.annualRevenueYear3 > 0)
                DataRow(cells: [DataCell(Text('Revenue (${sme.annualRevenueYear3})')), DataCell(Text('₦${NumberFormat('#,###').format(sme.annualRevenueAmount3)}'))]),
              
              if (sme.annualRevenueYear1 == 0) // Fallback for old data
                 DataRow(cells: [DataCell(Text('Annual Revenue')), DataCell(Text('₦${NumberFormat('#,###').format(sme.annualRevenue)}'))]),

              DataRow(cells: [DataCell(Text('Monthly Expenses')), DataCell(Text('₦${NumberFormat('#,###').format(sme.monthlyExpenses)}'))]),
              DataRow(cells: [DataCell(Text('Total Liabilities')), DataCell(Text('₦${NumberFormat('#,###').format(sme.liabilities)}'))]),
              DataRow(cells: [DataCell(Text('Net Profit (Est)')), DataCell(Text('₦${NumberFormat('#,###').format(sme.annualRevenue - (sme.monthlyExpenses * 12))}'))]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyLock() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.lock, size: 48, color: AppColors.slate400),
          const SizedBox(height: 24),
          Text(
            'Financial Data is Private',
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.slate900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '${sme.companyName} has restricted access to their comprehensive financial metrics. If you see high potential in their profile, we encourage you to initiate a conversation directly to request detailed financial access and explore a partnership.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.slate600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildCardTitle(String title) {
    return Text(
      title,
      style: AppTypography.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.slate900,
      ),
    );
  }

  Widget _buildMetricCard({required String title, required String subtitle, required Widget chart, Widget? summary}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate900.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.slate500,
                  ),
                ),
                const SizedBox(height: 24),
                chart,
              ],
            ),
          ),
          if (summary != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.slate100, width: 1)),
                color: AppColors.slate50,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
              ),
              child: summary,
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpandableAssessmentText extends StatefulWidget {
  final String text;
  
  const _ExpandableAssessmentText({required this.text});

  @override
  State<_ExpandableAssessmentText> createState() => _ExpandableAssessmentTextState();
}

class _ExpandableAssessmentTextState extends State<_ExpandableAssessmentText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool needsExpansion = widget.text.length > 100;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (!isExpanded && needsExpansion) ? '${widget.text.substring(0, 100)}...' : widget.text,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.slate700,
            height: 1.5,
          ),
        ),
        if (needsExpansion) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Text(
              isExpanded ? 'Read less' : 'Read more',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.trustBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
