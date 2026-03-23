import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/analysis_cubit/analysis_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/analysis_cubit/analysis_state.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/credibility_dashboard_page.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';

class AnalysisStatePage extends StatelessWidget {
  final bool isDocumentUpload;

  const AnalysisStatePage({super.key, this.isDocumentUpload = false});

  String _getStepName(int step) {
    if (isDocumentUpload) {
      if (step == 1) return 'Document Validation';
      if (step == 2) return 'Data Extraction';
      if (step == 3) return 'Model Inference';
      return 'Score Finalization';
    } else {
      if (step == 1) return 'Validating Inputs';
      if (step == 2) return 'Running AI Models';
      return 'Score Finalization';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalysisCubit(
        profileCubit: context.read<SmeProfileCubit>(),
        authBloc: context.read<AuthBloc>(),
        scoreCubit: context.read<ScoreCubit>(),
        isDocumentUpload: isDocumentUpload,
      ),
      child: BlocConsumer<AnalysisCubit, AnalysisState>(
        listener: (context, state) {
          if (state.isComplete) {
            uiService.clearAndNavigateTo(const CredibilityDashboardPage());
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background(context),
            body: Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 24),
                            const Spacer(),

                            if (state.isError) ...[
                              const Icon(
                                LucideIcons.alertCircle,
                                size: 64,
                                color: AppColors.dangerRed,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Analysis encountered an issue.',
                                style: AppTypography.textTheme.bodyLarge?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.errorMessage ?? 'Please check back in a few minutes or try again.',
                                style: AppTypography.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              CustomButton(
                                text: 'Go Back',
                                onPressed: () => uiService.goBack(),
                                variant: ButtonVariant.secondary,
                              ),
                            ] else ...[
                              const Center(child: NumberStreamAnimation()),
                              const SizedBox(height: 32),

                              Text(
                                isDocumentUpload
                                    ? 'Analyzing your financial data...'
                                    : 'Generating your credibility score...',
                                style: AppTypography.textTheme.bodyLarge?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isDocumentUpload
                                    ? 'Extracting documents. This typically takes 30–60 seconds.'
                                    : 'Applying AI models. This will only take a moment.',
                                style: AppTypography.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 48),

                              Text(
                                'Step ${state.step} of ${state.totalSteps}: ${_getStepName(state.step)}',
                                style: AppTypography.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSecondary(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),

                              Center(
                                child: Container(
                                  width: 200,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: AppColors.border(context),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 800),
                                      curve: Curves.easeOutCubic,
                                      width: 200 * (state.progress / 100),
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: AppColors.trustBlue,
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            const Spacer(),
                            if (!state.isError)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24.0, left: 12.0, right: 12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.lock,
                                      size: 14,
                                      color: AppColors.textSecondary(context),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Your data is secure. Never shared without your consent.',
                                        style: AppTypography.textTheme.bodySmall?.copyWith(
                                          fontSize: 11,
                                          color: AppColors.textSecondary(context),
                                          letterSpacing: 0,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NEW: ANIMATED NUMBER STREAM WIDGET
// ---------------------------------------------------------------------------
class _NumberStreamData {
  final String id;
  final String value;
  final double fontSize;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double angle;
  final Color color;
  final FontWeight fontWeight;

  _NumberStreamData({
    required this.id,
    required this.value,
    required this.fontSize,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.angle,
    required this.color,
    required this.fontWeight,
  });
}

class NumberStreamAnimation extends StatefulWidget {
  const NumberStreamAnimation({super.key});
  @override
  State<NumberStreamAnimation> createState() => _NumberStreamAnimationState();
}

class _NumberStreamAnimationState extends State<NumberStreamAnimation> {
  final List<_NumberStreamData> _numbers = [];
  Timer? _spawnTimer;
  final math.Random _random = math.Random();

  List<Color> _colors = [];

  @override
  void initState() {
    super.initState();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted || _colors.isEmpty) return;
      // Keep around 3-4 items on screen
      if (_numbers.length < 4) {
        _spawnNumber(_numbers.length);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colors = [
      AppColors.trustBlue,
      AppColors.trustBlue.withValues(alpha: 0.5),
      AppColors.warningOrange,
      AppColors.successGreen,
      AppColors.textSecondary(context).withValues(alpha: 0.6),
      AppColors.textSecondary(context).withValues(alpha: 0.4),
    ];
    // Start initial numbers if they are not already there
    if (_numbers.isEmpty) {
      _spawnNumber(0);
      _spawnNumber(1);
    }
  }

  void _spawnNumber(int salt) {
    if (!mounted) return;
    final id = '${DateTime.now().microsecondsSinceEpoch}_${salt}_${_random.nextInt(1000)}';
    
    // Randomize visual properties
    final value = _random.nextInt(90) + 10; // 10 to 99
    final sizes = [32.0, 16.0, 24.0, 48.0, 20.0, 12.0, 40.0];
    final fontSize = sizes[_random.nextInt(sizes.length)];
    final weights = [FontWeight.w600, FontWeight.w700, FontWeight.w800, FontWeight.w900, FontWeight.bold];
    final fontWeight = weights[_random.nextInt(weights.length)];

    final color = _colors[_random.nextInt(_colors.length)];
    final angle = (_random.nextDouble() * 0.8) - 0.4; // -0.4 to 0.4 radians

    // Randomize movement path (keep completely within bounds -0.8 to 0.8 to avoid edges)
    final startX = (_random.nextDouble() * 1.6) - 0.8;
    final startY = (_random.nextDouble() * 1.6) - 0.8;
    
    // End coordinate drifts away from start coordinate slightly
    final endX = startX + ((_random.nextDouble() * 0.4) - 0.2);
    final endY = startY + ((_random.nextDouble() * 0.4) - 0.2);

    setState(() {
      _numbers.add(
        _NumberStreamData(
          id: id,
          value: value.toString(),
          fontSize: fontSize,
          startX: startX,
          startY: startY,
          endX: endX.clamp(-1.9, 1.9),
          endY: endY.clamp(-1.9, 1.9),
          angle: angle,
          color: color,
          fontWeight: fontWeight,
        ),
      );
    });

    // Remove element after its animation finishes
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _numbers.removeWhere((n) => n.id == id);
        });
      }
    });
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface(context), // Brighter box
        borderRadius: BorderRadius.circular(AppRadius.xl), // Softer corners
        border: Border.all(
          color: AppColors.border(context),
          width: AppSizes.borderMedium,
        ),
        boxShadow: [
          BoxShadow(
              color: AppColors.trustBlue.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: _numbers
            .map(
              (numData) => _AnimatedNumberItem(
                key: ValueKey(numData.id),
                data: numData,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _AnimatedNumberItem extends StatefulWidget {
  final _NumberStreamData data;
  const _AnimatedNumberItem({super.key, required this.data});
  @override
  State<_AnimatedNumberItem> createState() => _AnimatedNumberItemState();
}

class _AnimatedNumberItemState extends State<_AnimatedNumberItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _alignment;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    // Movement drift
    _alignment = AlignmentTween(
      begin: Alignment(widget.data.startX, widget.data.startY),
      end: Alignment(widget.data.endX, widget.data.endY),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    
    // Scale jumps in then settles
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.1), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 75),
    ]).animate(_controller);

    // Fade in and out
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Align(
          alignment: _alignment.value,
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Transform.rotate(
                angle: widget.data.angle,
                child: Text(
                  widget.data.value,
                  style: AppTypography.displayHero.copyWith(
                    fontWeight: widget.data.fontWeight,
                    fontSize: widget.data.fontSize,
                    color: widget.data.color,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
