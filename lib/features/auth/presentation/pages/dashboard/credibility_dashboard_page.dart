import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/score_drivers_detail_page.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/profile_management_page.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_discovery_feed_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_state.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/auth_event.dart';
import 'package:partnex/features/auth/presentation/pages/login_page.dart';
import 'package:partnex/features/auth/data/models/credibility_score.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/input_method_selection_page.dart';
import 'package:intl/intl.dart';

class CredibilityDashboardPage extends StatefulWidget {
  const CredibilityDashboardPage({super.key});

  @override
  State<CredibilityDashboardPage> createState() => _CredibilityDashboardPageState();
}

class _CredibilityDashboardPageState extends State<CredibilityDashboardPage> {

  // Helper function to dynamically derive monthly revenue since it is now optional
  double getCalculatedMonthlyRev(Map<String, dynamic> profile) {
    double mRev = double.tryParse(profile['monthly_revenue']?.toString() ?? '0') ?? 0.0;
    if (mRev <= 0) {
      // Fallback to average of submitted annual revenues / 12
      double a1 = double.tryParse(profile['annual_revenue_amount_1']?.toString() ?? '0') ?? 0.0;
      double a2 = double.tryParse(profile['annual_revenue_amount_2']?.toString() ?? '0') ?? 0.0;
      double a3 = double.tryParse(profile['annual_revenue_amount_3']?.toString() ?? '0') ?? 0.0;
      int validYears = 0;
      double tRev = 0;
      if (a1 > 0) { tRev += a1; validYears++; }
      if (a2 > 0) { tRev += a2; validYears++; }
      if (a3 > 0) { tRev += a3; validYears++; }
      
      if (validYears > 0) {
        mRev = (tRev / validYears) / 12;
      }
    }
    return mRev;
  }

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScoreCubit, ScoreState>(
      builder: (context, state) {
        // Active loading (score fetch in progress) — show spinner
        if (state is ScoreLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: AppColors.trustBlue)),
          );
        }

        // No score submitted yet — show welcome dashboard
        if (state is ScoreInitial) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(LucideIcons.menu, size: 24, color: AppColors.slate900),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileManagementPage()),
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
              actions: [
                TextButton.icon(
                  icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.trustBlue),
                  label: Text('Add new', style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.trustBlue)),
                  onPressed: () {
                    // Navigate to the InputMethodSelectionPage with isUpdatingRecord = true
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthUnauthenticated) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                      child: const Icon(LucideIcons.barChart2, size: 40, color: AppColors.trustBlue),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to Partnex!',
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: AppColors.slate900,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No credibility score yet. Submit your business profile to generate your AI-powered credibility score.',
                      textAlign: TextAlign.center,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.slate600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Explore SMEs (Investor)',
                      variant: ButtonVariant.primary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SmeDiscoveryFeedPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            ),
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

        final formattedDate = DateFormat('MMM d, yyyy h:mm a').format(scoreData.calculatedAt);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 16,
            centerTitle: false,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileManagementPage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(LucideIcons.menu, size: 24, color: AppColors.slate900),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Credibility Score',
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      color: AppColors.slate900,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.trustBlue),
                label: Text('Add new', style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.trustBlue)),
                onPressed: () {
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
          body: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Primary Score Area
                  const SizedBox(height: 8),
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ScoreDriversDetailPage()),
                            );
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: riskColor,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.1),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                scoreData.totalScore.toInt().toString(),
                                style: AppTypography.textTheme.displayLarge?.copyWith(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
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
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.clock, size: 14, color: AppColors.slate400),
                            const SizedBox(width: 4),
                            Text(
                              'Generated on $formattedDate',
                              style: AppTypography.textTheme.bodySmall?.copyWith(
                                color: AppColors.slate600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Key Metrics Area
                  if (state.financialMetrics != null) ...[
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      children: [
                        _buildMetricMiniCard(
                          label: 'Revenue Trend',
                          value: '${state.financialMetrics!.yoyGrowth > 0 ? '+' : ''}${state.financialMetrics!.yoyGrowth.toStringAsFixed(0)}% YoY',
                          status: state.financialMetrics!.yoyGrowth >= 0 ? 'Positive' : 'Negative',
                          statusColor: state.financialMetrics!.yoyGrowth >= 0 ? AppColors.successGreen : AppColors.dangerRed,
                        ),
                        _buildMetricMiniCard(
                          label: 'Expense Ratio',
                          value: '${state.financialMetrics!.expenseRatio.toStringAsFixed(0)}%',
                          status: state.financialMetrics!.expenseRatio <= 60 ? 'Healthy' : (state.financialMetrics!.expenseRatio <= 85 ? 'Moderate' : 'Stressed'),
                          statusColor: state.financialMetrics!.expenseRatio <= 60 ? AppColors.trustBlue : (state.financialMetrics!.expenseRatio <= 85 ? AppColors.warningAmber : AppColors.dangerRed),
                        ),
                        _buildMetricMiniCard(
                          label: 'Liabilities',
                          value: '₦${state.financialMetrics!.debtToRevenueRatio >= 1000 ? '${(state.financialMetrics!.debtToRevenueRatio/1000).toStringAsFixed(1)}K' : state.financialMetrics!.debtToRevenueRatio.toStringAsFixed(0)}',
                          status: state.financialMetrics!.debtToRevenueRatio <= 30 ? 'Low' : (state.financialMetrics!.debtToRevenueRatio <= 70 ? 'Moderate' : 'High'),
                          statusColor: state.financialMetrics!.debtToRevenueRatio <= 30 ? AppColors.successGreen : (state.financialMetrics!.debtToRevenueRatio <= 70 ? AppColors.warningAmber : AppColors.dangerRed),
                        ),
                        _buildMetricMiniCard(
                          label: 'Payment History',
                          value: state.financialMetrics!.onTimePaymentRate >= 95 ? 'On Time' : '${state.financialMetrics!.onTimePaymentRate.toStringAsFixed(0)}% On Time',
                          status: state.financialMetrics!.onTimePaymentRate >= 90 ? 'Positive' : 'Attention',
                          statusColor: state.financialMetrics!.onTimePaymentRate >= 90 ? AppColors.successGreen : AppColors.warningAmber,
                        ),
                      ],
                    ),
                  ] else ...[
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      children: [
                        _buildMetricMiniCard(label: 'Revenue Trend', value: 'N/A', status: 'N/A', statusColor: AppColors.slate400),
                        _buildMetricMiniCard(label: 'Expense Ratio', value: 'N/A', status: 'N/A', statusColor: AppColors.slate400),
                        _buildMetricMiniCard(label: 'Liabilities', value: 'N/A', status: 'N/A', statusColor: AppColors.slate400),
                        _buildMetricMiniCard(label: 'Payment History', value: 'N/A', status: 'N/A', statusColor: AppColors.slate400),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Score Drivers Area
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
                      children: state.financialMetrics!.rankedDrivers.take(3).map((driver) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildDriverBar(
                            driverName: driver.name,
                            percentage: driver.score / 100,
                            statusColor: driver.score >= 80 ? AppColors.successGreen : (driver.score >= 50 ? AppColors.warningAmber : AppColors.dangerRed),
                          ),
                        );
                      }).toList(),
                    ),
                  ] else ...[
                    Column(
                      children: [
                        _buildDriverBar(driverName: 'Payment History', percentage: 0.5, statusColor: AppColors.slate300),
                        const SizedBox(height: 12),
                        _buildDriverBar(driverName: 'Revenue Trend', percentage: 0.5, statusColor: AppColors.slate300),
                        const SizedBox(height: 12),
                        _buildDriverBar(driverName: 'Expense Ratio', percentage: 0.5, statusColor: AppColors.slate300),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Actions Area
                  CustomButton(
                    text: 'Apply for Funding',
                    variant: ButtonVariant.primary,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'View Detailed Breakdown',
                    variant: ButtonVariant.secondary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScoreDriversDetailPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _buildMetricMiniCard({
    required String label,
    required String value,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.slate200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.slate600,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.slate900,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          Text(
            status,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverBar({
    required String driverName,
    required double percentage,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.slate200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              driverName,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate900,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
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
          const SizedBox(width: 16),
          Text(
            '${(percentage * 100).toInt()}%',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.slate900,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }


}
