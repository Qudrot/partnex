import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnest/core/theme/app_colors.dart';
import 'package:partnest/core/theme/app_typography.dart';
import 'package:partnest/core/theme/widgets/custom_button.dart';
import 'package:partnest/features/auth/presentation/pages/dashboard/score_drivers_detail_page.dart';
import 'package:partnest/features/auth/presentation/pages/dashboard/profile_management_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnest/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnest/features/auth/presentation/blocs/score_cubit/score_state.dart';
import 'package:partnest/features/auth/data/models/credibility_score.dart';
import 'package:intl/intl.dart';

class CredibilityDashboardPage extends StatelessWidget {
  const CredibilityDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScoreCubit, ScoreState>(
      builder: (context, state) {
        if (state is ScoreLoading || state is ScoreInitial) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ScoreError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: Text('Error loading score: ${state.message}')),
          );
        }

        final scoreData = (state as ScoreLoadedSuccess).score;

        String riskLevelString = 'High Risk';
        Color riskColor = AppColors.dangerRed;

        if (scoreData.riskLevel == RiskLevel.low) {
          riskLevelString = 'Low Risk';
          riskColor = AppColors.successGreen;
        } else if (scoreData.riskLevel == RiskLevel.medium) {
          riskLevelString = 'Medium Risk';
          riskColor = AppColors.warningAmber;
        }

        final formattedDate = DateFormat('MMM d, yyyy \\at h:mm a').format(scoreData.calculatedAt);

        return Scaffold(
          backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Credibility Score',
          style: AppTypography.textTheme.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.menu, color: AppColors.slate900),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileManagementPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Section: Score Circle
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: riskColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: riskColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          scoreData.totalScore.toInt().toString(),
                          style: AppTypography.textTheme.displayLarge?.copyWith(
                            fontSize: 56,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: riskColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        riskLevelString,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.calendar, size: 16, color: AppColors.slate400),
                        const SizedBox(width: 6),
                        Text(
                          'Generated on $formattedDate',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.slate600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Key Metrics Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _MetricCard(
                      label: 'Revenue Trend',
                      value: '+15% YoY',
                      trendText: 'Positive',
                      trendColor: AppColors.successGreen,
                      icon: LucideIcons.trendingUp,
                      iconColor: AppColors.successGreen,
                    ),
                    _MetricCard(
                      label: 'Expense Ratio',
                      value: '60%',
                      trendText: 'Healthy',
                      trendColor: AppColors.trustBlue,
                      icon: LucideIcons.pieChart,
                      iconColor: AppColors.trustBlue,
                    ),
                    _MetricCard(
                      label: 'Liabilities',
                      value: '₦200,000',
                      trendText: 'Moderate',
                      trendColor: AppColors.warningAmber,
                      icon: LucideIcons.alertCircle,
                      iconColor: AppColors.warningAmber,
                    ),
                    _MetricCard(
                      label: 'Payment History',
                      value: 'On Time',
                      trendText: 'Positive',
                      trendColor: AppColors.successGreen,
                      icon: LucideIcons.checkCircle,
                      iconColor: AppColors.successGreen,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Score Drivers Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What Drives Your Score',
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Top 3 factors contributing to your credibility',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.slate600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (scoreData.topContributingFactors.isNotEmpty)
                      _DriverCard(
                        rank: '1st',
                        title: 'Years of Operation',
                        contribution: 'High Impact',
                        contributionColor: AppColors.successGreen,
                        icon: LucideIcons.calendarClock,
                        iconColor: AppColors.successGreen,
                        status: 'Positive',
                        explanation: scoreData.topContributingFactors[0],
                      ),
                    const SizedBox(height: 12),
                    if (scoreData.topContributingFactors.length > 1)
                      _DriverCard(
                        rank: '2nd',
                        title: 'Company Scale',
                        contribution: 'High Impact',
                        contributionColor: AppColors.trustBlue,
                        icon: LucideIcons.users,
                        iconColor: AppColors.trustBlue,
                        status: 'Neutral',
                        explanation: scoreData.topContributingFactors[1],
                      ),
                    const SizedBox(height: 12),
                    if (scoreData.generalExplanation?.isNotEmpty == true)
                      _DriverCard(
                        rank: 'Data Notice',
                        title: 'AI MVP Boundary',
                        contribution: 'Limited Data Scope',
                        contributionColor: AppColors.warningAmber,
                        icon: LucideIcons.info,
                        iconColor: AppColors.warningAmber,
                        status: 'Notice',
                        explanation: scoreData.generalExplanation ?? '',
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomButton(
                      text: 'View Detailed Breakdown',
                      variant: ButtonVariant.primary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScoreDriversDetailPage(),
                          ),
                        );
                      },
                      // Add trailing icon for chevron inside CustomButton logic if needed,
                      // or just use standard button
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Download Report',
                      variant: ButtonVariant.secondary,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Share Score',
                      variant: ButtonVariant.tertiary,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
     );
    },
   );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String trendText;
  final Color trendColor;
  final IconData icon;
  final Color iconColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.trendText,
    required this.trendColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.slate600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.slate900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trendText,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: trendColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverCard extends StatefulWidget {
  final String rank;
  final String title;
  final String contribution;
  final Color contributionColor;
  final IconData icon;
  final Color iconColor;
  final String status;
  final String explanation;

  const _DriverCard({
    required this.rank,
    required this.title,
    required this.contribution,
    required this.contributionColor,
    required this.icon,
    required this.iconColor,
    required this.status,
    required this.explanation,
  });

  @override
  State<_DriverCard> createState() => _DriverCardState();
}

class _DriverCardState extends State<_DriverCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _isExpanded ? AppColors.trustBlue : AppColors.slate200,
          width: _isExpanded ? 2.0 : 1.0,
        ),
        boxShadow: [
          if (_isExpanded)
            BoxShadow(
              color: AppColors.slate200.withValues(alpha: 0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.rank,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.slate600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTypography.textTheme.headlineSmall?.copyWith(
                          fontSize: 16,
                          color: AppColors.slate900,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                      color: AppColors.slate400,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(widget.icon, size: 20, color: widget.iconColor),
                    const SizedBox(width: 8),
                    Text(
                      widget.contribution,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: widget.contributionColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.status,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: widget.contributionColor,
                      ),
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 16),
                  Divider(color: AppColors.slate200),
                  const SizedBox(height: 12),
                  Text(
                    widget.explanation,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.slate700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Mini chart placeholder
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '[ Chart Visualization ]',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.slate400,
                        ),
                      ),
                    ),
                  )
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
