import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/circular_score_ring.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/theme/widgets/metric_mini_card.dart'; // <-- Added Import
import 'package:partnex/features/auth/presentation/pages/dashboard/score_drivers_detail_page.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/profile_management_page.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_discovery_feed_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_state.dart';
import 'package:partnex/features/auth/data/models/financial_metrics.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/input_method_selection_page.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart'; 
import 'package:intl/intl.dart';

class CredibilityDashboardPage extends StatefulWidget {
  const CredibilityDashboardPage({super.key});

  @override
  State<CredibilityDashboardPage> createState() =>
      _CredibilityDashboardPageState();
}

class _CredibilityDashboardPageState extends State<CredibilityDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ScoreCubit>();
      if (cubit.state is ScoreInitial) {
        cubit.fetchDashboardData();
      }
    });
  }

  Color _getStatusColor(MetricStatus status) {
    switch (status) {
      case MetricStatus.positive:
        return AppColors.successGreen;
      case MetricStatus.moderate:
        return AppColors.warningOrange;
      case MetricStatus.concerning:
        return AppColors.dangerRed;
      case MetricStatus.critical:
        return AppColors.dangerRed;
    }
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScoreCubit, ScoreState>(
      builder: (context, state) {
        if (state is ScoreLoading) {
          return const Scaffold(
            backgroundColor: AppColors.neutralWhite,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.trustBlue),
            ),
          );
        }

        if (state is ScoreInitial) {
          return Scaffold(
            backgroundColor: AppColors.neutralWhite,
            appBar: AppBar(
              backgroundColor: AppColors.neutralWhite,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(
                  LucideIcons.menu,
                  size: 24,
                  color: AppColors.slate900,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileManagementPage(),
                    ),
                  );
                },
              ),
              title: Text(
                'Dashboard',
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  color: AppColors.slate900,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.trustBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.barChart2,
                        size: 40,
                        color: AppColors.trustBlue,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    Text(
                      'Welcome to Partnex!',
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: AppColors.slate900,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSpacing.smd),
                    Text(
                      'No credibility score yet. Submit your business profile to generate your AI-powered credibility score.',
                      textAlign: TextAlign.center,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.slate600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxl),
                    CustomButton(
                      text: 'Explore SMEs (Investor)',
                      variant: ButtonVariant.primary,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SmeDiscoveryFeedPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is ScoreError) {
          // Strip the Dart "Exception: " prefix if present so users see a clean message.
          final rawMsg = state.message.startsWith('Exception: ')
              ? state.message.substring('Exception: '.length)
              : state.message;
          return Scaffold(
            backgroundColor: AppColors.neutralWhite,
            body: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.wifiOff, size: 48, color: AppColors.slate400),
                    SizedBox(height: AppSpacing.lg),
                    Text(
                      rawMsg,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.slate600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.xl),
                    CustomButton(
                      text: 'Try again',
                      variant: ButtonVariant.primary,
                      onPressed: () => context.read<ScoreCubit>().fetchDashboardData(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is! ScoreLoadedSuccess) {
          return const Scaffold(backgroundColor: AppColors.neutralWhite);
        }

        final scoreData = state.score;
        String riskLevelString = 'HIGH RISK';
        Color riskColor = AppColors.dangerRed;

        final String lowerRisk = scoreData.riskLevel.toString().toLowerCase();

        if (lowerRisk.contains('low')) {
          riskLevelString = 'LOW RISK';
          riskColor = AppColors.successGreen;
        } else if (lowerRisk.contains('medium')) {
          riskLevelString = 'MEDIUM RISK';
          riskColor = AppColors.warningOrange;
        }

        final now = DateTime.now();
        final isToday = scoreData.calculatedAt.year == now.year &&
            scoreData.calculatedAt.month == now.month &&
            scoreData.calculatedAt.day == now.day;
            
        final formattedDate = isToday 
            ? 'Today at ${DateFormat('h:mm a').format(scoreData.calculatedAt)}'
            : DateFormat('MMM d, yyyy h:mm a').format(scoreData.calculatedAt);

        return Scaffold(
          backgroundColor: AppColors.neutralWhite,
          appBar: AppBar(
            backgroundColor: AppColors.neutralWhite,
            elevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(
                LucideIcons.menu,
                size: 24,
                color: AppColors.slate900,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileManagementPage(),
                ),
              ),
            ),
            title: Text(
              'Credibility Score',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                color: AppColors.slate900,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              CustomButton(
                text: 'Add new',
                variant: ButtonVariant.tertiary,
                icon: const Icon(
                  LucideIcons.plus,
                  size: 16,
                  color: AppColors.trustBlue,
                ),
                onPressed: () {
                  // SECURE FIX: Grab the current values from the state
                  final currentProfileState = context.read<SmeProfileCubit>().state;
                  
                  // Re-inject them with Failsafes (so AI never gets a 0)
                  context.read<SmeProfileCubit>().updateBusinessProfile(
                    businessName: currentProfileState.businessName.isNotEmpty ? currentProfileState.businessName : 'My Business',
                    industry: currentProfileState.industry.isNotEmpty ? currentProfileState.industry : 'Technology',
                    location: currentProfileState.location.isNotEmpty ? currentProfileState.location : 'Nigeria',
                    // Failsafe: If years/employees are 0, default to 1 so the AI math doesn't break
                    yearsOfOperation: currentProfileState.yearsOfOperation > 0 ? currentProfileState.yearsOfOperation : 1,
                    numberOfEmployees: currentProfileState.numberOfEmployees > 0 ? currentProfileState.numberOfEmployees : 1,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InputMethodSelectionPage(isUpdatingRecord: true),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ScoreDriversDetailPage(),
                            ),
                          ),
                          child: CircularScoreRing(
                            score: scoreData.totalScore.toInt(),
                            size: 190.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: riskColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            riskLevelString,
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.neutralWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Generated on $formattedDate',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.slate600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (state.financialMetrics != null) ...[
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4, 
                      children: [
                        // Card 1 - Replaced with custom widget
                        MetricMiniCard(
                          label: 'Revenue Trend',
                          value: '${state.financialMetrics!.yoyGrowth > 0 ? '+' : ''}${state.financialMetrics!.yoyGrowth.toStringAsFixed(state.financialMetrics!.yoyGrowth % 1 == 0 ? 0 : 1)}% YoY',
                          status: state.financialMetrics!.yoyGrowth >= 15
                              ? 'Positive'
                              : (state.financialMetrics!.yoyGrowth >= 0
                                    ? 'Moderate'
                                    : 'Declining'),
                          statusColor: state.financialMetrics!.yoyGrowth >= 15
                              ? AppColors.successGreen
                              : (state.financialMetrics!.yoyGrowth >= 0
                                    ? AppColors.warningOrange
                                    : AppColors.dangerRed),
                        ),
                        // Card 2 - Replaced with custom widget
                        MetricMiniCard(
                          label: 'Expense Ratio',
                          value: '${state.financialMetrics!.expenseRatio.toStringAsFixed(state.financialMetrics!.expenseRatio % 1 == 0 ? 0 : 1)}%',
                          status: state.financialMetrics!.expenseRatio <= 60
                              ? 'Healthy'
                              : (state.financialMetrics!.expenseRatio <= 75
                                    ? 'Moderate'
                                    : 'High'),
                          statusColor: state.financialMetrics!.expenseRatio <= 60
                              ? AppColors.trustBlue
                              : (state.financialMetrics!.expenseRatio <= 75
                                    ? AppColors.warningOrange
                                    : AppColors.dangerRed),
                        ),
                        // Card 3 - Replaced with custom widget
                        MetricMiniCard(
                          label: 'Profit Margin',
                          value: '${state.financialMetrics!.profitMargin.toStringAsFixed(state.financialMetrics!.profitMargin % 1 == 0 ? 0 : 1)}%',
                          status: state.financialMetrics!.profitMargin >= 15
                              ? 'Healthy'
                              : (state.financialMetrics!.profitMargin >= 0
                                    ? 'Moderate'
                                    : 'Negative'),
                          statusColor: state.financialMetrics!.profitMargin >= 15
                              ? AppColors.successGreen
                              : (state.financialMetrics!.profitMargin >= 0
                                    ? AppColors.warningOrange
                                    : AppColors.dangerRed),
                        ),
                        // Card 4 - Replaced with custom widget
                        MetricMiniCard(
                          label: 'Impact Score',
                          value: scoreData.impactScore.toStringAsFixed(1),
                          status: scoreData.impactScore >= 0.8
                              ? 'Excellent'
                              : (scoreData.impactScore >= 0.5
                                    ? 'Good'
                                    : 'Low'),
                          statusColor: scoreData.impactScore >= 0.8
                              ? AppColors.trustBlue
                              : (scoreData.impactScore >= 0.5
                                    ? AppColors.successGreen
                                    : AppColors.dangerRed),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),

                  Text(
                    'What Drives Your Score',
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      color: AppColors.slate900,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Top 3 factors contributing to your credibility score',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.slate600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (state.financialMetrics != null) ...[
                    Column(
                      children: state.financialMetrics!.rankedDrivers
                          .take(3)
                          .map((driver) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: _buildDriverBar(
                                driverName: driver.name,
                                percentage: (driver.scoreValue.clamp(0.0, 100.0)) / 100.0,
                                displayValue: driver.rawDisplayValue,
                                statusColor: _getStatusColor(driver.status),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Apply for Funding',
                    variant: ButtonVariant.primary,
                    isFullWidth: true,
                    onPressed: () => _showComingSoonBottomSheet(context),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'View Detailed Breakdown',
                    variant: ButtonVariant.secondary,
                    isFullWidth: true,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScoreDriversDetailPage(),
                      ),
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

  void _showComingSoonBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.neutralWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.trustBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.rocket,
                size: 48,
                color: AppColors.trustBlue,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Coming Soon!',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                color: AppColors.slate900,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'We\'re working with top institutional investors to bring you the best funding opportunities directly on Partnex.',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate600,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
            CustomButton(
              text: 'Got it, thanks!',
              variant: ButtonVariant.primary,
              isFullWidth: true,
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverBar({
    required String driverName,
    required double percentage,
    required String displayValue,
    required Color statusColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        border: Border.all(color: AppColors.slate200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            driverName,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.slate900,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: AppColors.slate100,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                displayValue,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate900,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}