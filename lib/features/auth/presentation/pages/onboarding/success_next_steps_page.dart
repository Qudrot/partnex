import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/credibility_dashboard_page.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_state.dart';
import 'package:partnex/features/auth/data/models/credibility_score.dart';

class SuccessNextStepsPage extends StatefulWidget {
  const SuccessNextStepsPage({super.key});

  @override
  State<SuccessNextStepsPage> createState() => _SuccessNextStepsPageState();
}

enum ProcessingStage { validation, engineering, inference, finalization, complete }

class _SuccessNextStepsPageState extends State<SuccessNextStepsPage> with SingleTickerProviderStateMixin {
  ProcessingStage _currentStage = ProcessingStage.validation;
  int _secondsRemaining = 120; // Starts at 2 minutes 0 seconds for simulation

  late AnimationController _shimmerController;
  late Animation<Alignment> _shimmerAlignment;
  
  bool _isPhase1 = true;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _shimmerAlignment = Tween<Alignment>(
      begin: const Alignment(-2.0, 0.0),
      end: const Alignment(2.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _startSimulation();
  }

  void _startSimulation() async {
    // Stage 1 (0-1.5s)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() { _currentStage = ProcessingStage.engineering; _secondsRemaining = 90; });

    // Stage 2 (1.5-3s)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() { _currentStage = ProcessingStage.inference; _secondsRemaining = 60; });

    // Stage 3 (3-4.5s)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() { _currentStage = ProcessingStage.finalization; _secondsRemaining = 30; });

    // Stage 4 (4.5-6s)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _currentStage = ProcessingStage.complete;
        _secondsRemaining = 0;
        _isPhase1 = false;
      });
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isPhase1 ? _buildPhase1() : _buildPhase2(),
        ),
      ),
    );
  }

  Widget _buildPhase1() {
    return Padding(
      key: const ValueKey('phase1'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          // Logo Header
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.hexagon, color: AppColors.trustBlue, size: 32),
                const SizedBox(width: 8),
                Text(
                  'PARTNEX',
                  style: AppTypography.textTheme.displayMedium?.copyWith(
                    color: AppColors.trustBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Animated Icon Placeholder
          Center(
            child: AnimatedBuilder(
              animation: _shimmerAlignment,
              builder: (context, child) {
                return Container(
                  width: 200,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: AppColors.slate100,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.trustBlue.withOpacity(0.1),
                        AppColors.trustBlue.withOpacity(0.7),
                        AppColors.trustBlue.withOpacity(0.1),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      begin: const Alignment(-1.0, 0.0),
                      end: const Alignment(1.0, 0.0),
                      transform: GradientRotation(_shimmerAlignment.value.x),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Analyzing Your Credibility',
            style: AppTypography.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.slate900,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re processing your financial data and computing your credibility score. This typically takes 2-5 minutes.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.slate600, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Timeline
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                   _buildTimelineStep(
                    title: 'Data Validation',
                    stepStage: ProcessingStage.validation,
                    pendingIcon: LucideIcons.checkCircle,
                  ),
                  _buildTimelineStep(
                    title: 'Feature Engineering',
                    stepStage: ProcessingStage.engineering,
                    pendingIcon: LucideIcons.hourglass,
                  ),
                  _buildTimelineStep(
                    title: 'Model Inference',
                    stepStage: ProcessingStage.inference,
                    pendingIcon: LucideIcons.zap,
                  ),
                  _buildTimelineStep(
                    title: 'Score Finalization',
                    stepStage: ProcessingStage.finalization,
                    pendingIcon: LucideIcons.star,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              'Your score will be ready in approximately ${_secondsRemaining ~/ 60} minutes ${_secondsRemaining % 60} seconds',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Footer Reassurance
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.lock, size: 16, color: AppColors.slate400),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Your data is securely encrypted and processed on our servers.',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.slate600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required ProcessingStage stepStage,
    required IconData pendingIcon,
  }) {
    final isCompleted = _currentStage.index > stepStage.index;
    final isCurrent = _currentStage == stepStage;

    Color iconColor;
    IconData icon;
    Color textColor;
    FontWeight textWeight;
    String statusText;

    if (isCompleted) {
      iconColor = AppColors.successGreen;
      icon = LucideIcons.checkCircle;
      textColor = AppColors.slate900;
      textWeight = FontWeight.w600;
      statusText = 'Completed';
    } else if (isCurrent) {
      iconColor = AppColors.trustBlue;
      icon = pendingIcon;
      textColor = AppColors.trustBlue;
      textWeight = FontWeight.w600;
      statusText = 'In Progress';
    } else {
      iconColor = AppColors.slate400;
      icon = pendingIcon;
      textColor = AppColors.slate600;
      textWeight = FontWeight.w400;
      statusText = 'Pending';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? AppColors.successGreen.withOpacity(0.1) 
                  : (isCurrent ? AppColors.trustBlue.withOpacity(0.1) : AppColors.slate100),
              shape: BoxShape.circle,
            ),
            child: isCurrent
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.trustBlue,
                    ),
                  )
                : Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: textWeight,
                    fontSize: 14,
                  ),
                ),
                if (isCurrent || isCompleted) ...[
                  const SizedBox(height: 2),
                  Text(
                    statusText,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: isCompleted ? AppColors.successGreen : AppColors.trustBlue,
                      fontSize: 12,
                    ),
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPhase2() {
    return BlocBuilder<ScoreCubit, ScoreState>(
      key: const ValueKey('phase2'),
      builder: (context, state) {
        if (state is! ScoreLoadedSuccess) {
          return const Center(child: CircularProgressIndicator());
        }

        final scoreData = state.score;
        String riskLevelString = 'High Risk';
        Color riskColor = AppColors.dangerRed;

        if (scoreData.riskLevel == RiskLevel.low) {
          riskLevelString = 'Low Risk';
          riskColor = AppColors.successGreen;
        } else if (scoreData.riskLevel == RiskLevel.medium) {
          riskLevelString = 'Medium Risk';
          riskColor = AppColors.warningAmber;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Your Credibility Score is Ready!',
                  style: AppTypography.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your score has been calculated based on your financial data.',
                style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.slate600, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Score Circle
              Center(
                child: Column(
                  children: [
                    Container(
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
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Key Metrics Area
              Row(
                children: [
                  Expanded(
                    child: _buildMetricMiniCard(
                      label: 'Revenue Trend',
                      value: '↑ 22% YoY',
                      icon: LucideIcons.trendingUp,
                      statusColor: AppColors.successGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricMiniCard(
                      label: 'Expense Ratio',
                      value: '60%',
                      icon: LucideIcons.pieChart,
                      statusColor: AppColors.successGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricMiniCard(
                      label: 'Liabilities',
                      value: '₦200K',
                      icon: LucideIcons.alertCircle,
                      statusColor: AppColors.warningAmber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricMiniCard(
                      label: 'Payment History',
                      value: 'On Time ✓',
                      icon: LucideIcons.checkCircle,
                      statusColor: AppColors.successGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // CTA Actions
              CustomButton(
                text: 'View Dashboard',
                variant: ButtonVariant.primary,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const CredibilityDashboardPage()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Download Report',
                variant: ButtonVariant.secondary,
                onPressed: () {},
                // TODO update generic CustomButton to be able to accept Icons as well easily
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Share Score',
                variant: ButtonVariant.tertiary,
                onPressed: () {},
              ),
              const SizedBox(height: 24),
            ],
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: statusColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        color: AppColors.slate600,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
