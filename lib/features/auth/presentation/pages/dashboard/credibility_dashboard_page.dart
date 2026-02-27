import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/score_drivers_detail_page.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/profile_management_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_state.dart';
import 'package:partnex/features/auth/data/models/credibility_score.dart';
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
            body: Center(child: CircularProgressIndicator(color: AppColors.trustBlue)),
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

        final formattedDate = DateFormat('MMM d, yyyy \\a\\t h:mm a').format(scoreData.calculatedAt);

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
              'Your Credibility Score',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                color: AppColors.slate900,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
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
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: [
                      _buildMetricMiniCard(
                        label: 'Revenue Trend',
                        value: '↑ 115%',
                        icon: LucideIcons.trendingUp,
                        statusColor: AppColors.successGreen,
                      ),
                      _buildMetricMiniCard(
                        label: 'Expenses',
                        value: '60%',
                        icon: LucideIcons.pieChart,
                        statusColor: AppColors.successGreen, // "Healthy" matching success green on screen 9 spec
                      ),
                      _buildMetricMiniCard(
                        label: 'Liabilities',
                        value: '₦200K',
                        icon: LucideIcons.alertCircle,
                        statusColor: AppColors.warningAmber,
                      ),
                      _buildMetricMiniCard(
                        label: 'Payment History',
                        value: 'On Time ✓',
                        icon: LucideIcons.checkCircle,
                        statusColor: AppColors.successGreen,
                      ),
                    ],
                  ),
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

                  _buildDriverBar(
                     driverName: 'Payment History',
                     points: '90',
                     percentage: 0.30,
                     statusColor: AppColors.successGreen,
                  ),
                  const SizedBox(height: 12),
                  _buildDriverBar(
                     driverName: 'Revenue Trend',
                     points: '75',
                     percentage: 0.25,
                     statusColor: AppColors.successGreen,
                  ),
                  const SizedBox(height: 12),
                  _buildDriverBar(
                     driverName: 'Expense Ratio',
                     points: '60',
                     percentage: 0.20,
                     statusColor: AppColors.warningAmber,
                  ),

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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(LucideIcons.download, size: 20, color: AppColors.trustBlue),
                        label: Text('Download', style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.trustBlue,
                          fontWeight: FontWeight.w600,
                        )),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(LucideIcons.share2, size: 20, color: AppColors.trustBlue),
                        label: Text('Share', style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.trustBlue,
                          fontWeight: FontWeight.w600,
                        )),
                      ),
                    ],
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

  Widget _buildMetricMiniCard({
    required String label,
    required String value,
    required IconData icon,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        border: Border.all(color: AppColors.slate200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                 label,
                 style: AppTypography.textTheme.labelMedium?.copyWith(
                   color: AppColors.slate600,
                   fontWeight: FontWeight.w600,
                   fontSize: 12,
                 ),
                 overflow: TextOverflow.ellipsis,
               ),
              Icon(icon, size: 20, color: statusColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.slate900,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverBar({
    required String driverName,
    required String points,
    required double percentage,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.slate200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              driverName,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate900,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                 Expanded(
                   child: Container(
                     height: 4,
                     decoration: BoxDecoration(
                       color: AppColors.slate100,
                       borderRadius: BorderRadius.circular(2),
                     ),
                     child: FractionallySizedBox(
                       alignment: Alignment.centerLeft,
                       widthFactor: 1.0, // Visual bar represents the max weight of the bar
                       child: Container(
                         decoration: BoxDecoration(
                           color: statusColor,
                           borderRadius: BorderRadius.circular(2),
                         ),
                       ),
                     ),
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
    );
  }
}
