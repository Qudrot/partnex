import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/credibility_dashboard_page.dart';

class AnalysisStatePage extends StatefulWidget {
  const AnalysisStatePage({super.key});

  @override
  State<AnalysisStatePage> createState() => _AnalysisStatePageState();
}

enum ProcessingStage { validation, engineering, inference, finalization, complete }

class _AnalysisStatePageState extends State<AnalysisStatePage> with SingleTickerProviderStateMixin {
  ProcessingStage _currentStage = ProcessingStage.validation;
  int _secondsRemaining = 5;

  late AnimationController _shimmerController;
  late Animation<Alignment> _shimmerAlignment;

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
    // 5 seconds total simulation
    
    // Data Validation (0-1s)
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _currentStage = ProcessingStage.engineering;
        _secondsRemaining = 4;
      });
    }

    // Feature Engineering (1-2s)
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _currentStage = ProcessingStage.inference;
        _secondsRemaining = 3;
      });
    }

    // Model Inference (2-4s)
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _currentStage = ProcessingStage.finalization;
        _secondsRemaining = 1;
      });
    }

    // Score Finalization (4-5s)
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _currentStage = ProcessingStage.complete;
        _secondsRemaining = 0;
      });
      _navigateToDashboard();
    }
  }

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const CredibilityDashboardPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Widget _buildStep({
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
      icon = pendingIcon; // Can be animated
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? AppColors.successGreen.withValues(alpha: 0.1) 
                  : (isCurrent ? AppColors.trustBlue.withValues(alpha: 0.1) : AppColors.slate100),
              shape: BoxShape.circle,
            ),
            child: isCurrent
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.trustBlue),
                    ),
                  )
                : Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: textWeight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: isCompleted ? AppColors.successGreen : (isCurrent ? AppColors.trustBlue : AppColors.slate500),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              
              // Header Placeholder
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

              const SizedBox(height: 48),

              // Animated Shimmer Bar
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
                            AppColors.trustBlue.withValues(alpha: 0.1),
                            AppColors.trustBlue.withValues(alpha: 0.7),
                            AppColors.trustBlue.withValues(alpha: 0.1),
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

              const SizedBox(height: 32),

              // Hero Text
              Text(
                'Analyzing Your Credibility',
                style: AppTypography.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We\'re processing your financial data and computing your credibility score.',
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: AppColors.slate600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Processing Steps
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildStep(
                        title: 'Data Validation',
                        stepStage: ProcessingStage.validation,
                        pendingIcon: LucideIcons.checkCircle,
                      ),
                      _buildStep(
                        title: 'Feature Engineering',
                        stepStage: ProcessingStage.engineering,
                        pendingIcon: LucideIcons.hourglass,
                      ),
                      _buildStep(
                        title: 'Model Inference',
                        stepStage: ProcessingStage.inference,
                        pendingIcon: LucideIcons.zap,
                      ),
                      _buildStep(
                        title: 'Score Finalization',
                        stepStage: ProcessingStage.finalization,
                        pendingIcon: LucideIcons.star,
                      ),
                    ],
                  ),
                ),
              ),

              // Estimated Time
              Center(
                child: Text(
                  'Your score will be ready in approximately $_secondsRemaining seconds',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.slate600,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Reassurance
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.lock, size: 16, color: AppColors.slate500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your data is securely encrypted and processed on our servers.',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.slate600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
