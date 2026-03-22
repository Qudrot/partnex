import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_sizes.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/credibility_dashboard_page.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';

class AnalysisStatePage extends StatefulWidget {
  final bool isDocumentUpload;

  const AnalysisStatePage({super.key, this.isDocumentUpload = false});

  @override
  State<AnalysisStatePage> createState() => _AnalysisStatePageState();
}

class _AnalysisStatePageState extends State<AnalysisStatePage> {
  int _step = 1;
  double _progress = 0.0;
  Timer? _progressTimer;
  Timer? _timeoutTimer;
  bool _isError = false;

  // Sync Locks to ensure the transition doesn't happen too fast
  bool _minimumTimeElapsed = false;
  bool _apiComplete = false;
  int get _totalSteps => widget.isDocumentUpload ? 4 : 3;

  @override
  void initState() {
    super.initState();
    _startAnalysis();

    // FORCE the page to stay here for at least 4.5 seconds for visual effect
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (!mounted) return;
      _minimumTimeElapsed = true;
      _checkAndNavigate();
    });
  }

  void _startAnalysis() async {
    final profileCubit = context.read<SmeProfileCubit>();
    final authBloc = context.read<AuthBloc>();
    final scoreCubit = context.read<ScoreCubit>();

    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      setState(() {
        double increment = widget.isDocumentUpload ? 1.5 : 10.0;

        // Cap visual progress at 90% until the API actually finishes
        if (_progress < 90) {
          _progress += increment;
        }

        if (widget.isDocumentUpload) {
          if (_progress < 25) {
            _step = 1;
          } else if (_progress < 50) {
            _step = 2;
          } else if (_progress < 75) {
            _step = 3;
          } else {
            _step = 4;
          }
        } else {
          if (_progress < 33) {
            _step = 1;
          } else if (_progress < 66) {
            _step = 2;
          } else {
            _step = 3;
          }
        }
      });
    });

    _timeoutTimer = Timer(const Duration(minutes: 5), () {
      if (!mounted) return;
      setState(() => _isError = true);
      _progressTimer?.cancel();
    });

    if (profileCubit.state.csvProcessingStatus ==
        CsvProcessingStatus.processing) {
      await for (final state in profileCubit.stream) {
        if (state.csvProcessingStatus == CsvProcessingStatus.success ||
            state.csvProcessingStatus == CsvProcessingStatus.error) {
          break;
        }
      }
    }

    if (profileCubit.state.csvProcessingStatus == CsvProcessingStatus.error) {
      _handleError(
        profileCubit.state.csvErrorMessage ??
            'Financial document analysis failed',
      );
      return;
    }

    if (authBloc.state is! SmeProfileSubmittedSuccess) {
      authBloc.add(SubmitSmeProfileEvent(profileCubit.state.toMap()));
    }

    final currentState = authBloc.state;
    if (currentState is SmeProfileSubmittedSuccess) {
      _markApiComplete(scoreCubit, currentState.score);
      return;
    } else if (currentState is SmeProfileSubmissionError) {
      _handleError(currentState.message);
      return;
    }

    await for (final state in authBloc.stream) {
      if (!mounted) return;
      if (state is SmeProfileSubmittedSuccess) {
        _markApiComplete(scoreCubit, state.score);
        break;
      } else if (state is SmeProfileSubmissionError) {
        _handleError(state.message);
        break;
      }
    }
  }

  void _markApiComplete(ScoreCubit scoreCubit, dynamic score) {
    if (!mounted) return;
    _apiComplete = true;
    scoreCubit.loadScore(score); // Load it in the background immediately

    // Jump progress to 95% while we wait for the 4.5s timer to finish
    setState(() {
      _progress = 95.0;
      _step = _totalSteps;
    });

    _checkAndNavigate();
  }

  void _checkAndNavigate() {
    // Only navigate when BOTH the API is done AND the minimum visual time has passed
    if (_apiComplete && _minimumTimeElapsed) {
      _progressTimer?.cancel();
      _timeoutTimer?.cancel();

      setState(() {
        _progress = 100.0;
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        uiService.clearAndNavigateTo(const CredibilityDashboardPage());
      });
    }
  }

  void _handleError(String message) {
    if (!mounted) return;
    _progressTimer?.cancel();
    _timeoutTimer?.cancel();
    setState(() => _isError = true);
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  String _getStepName(int step) {
    if (widget.isDocumentUpload) {
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
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Spacer(),

                  if (_isError) ...[
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
                      'Please check back in a few minutes or try again.',
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
                      widget.isDocumentUpload
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
                      widget.isDocumentUpload
                          ? 'Extracting documents. This typically takes 30–60 seconds.'
                          : 'Applying AI models. This will only take a moment.',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    Text(
                      'Step $_step of $_totalSteps: ${_getStepName(_step)}',
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
                            width: 200 * (_progress / 100),
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
                  if (!_isError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0, left: 12.0, right: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
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
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NEW: FLOATING METRICS BACKGROUND
// ---------------------------------------------------------------------------

class _FloatingMetricData {
  final String id;
  final String text;
  final Color color;
  final double startX;
  final double startY;
  final double angle;
  _FloatingMetricData({
    required this.id,
    required this.text,
    required this.color,
    required this.startX,
    required this.startY,
    required this.angle,
  });
}

class FloatingMetricsBackground extends StatefulWidget {
  const FloatingMetricsBackground({super.key});
  @override
  State<FloatingMetricsBackground> createState() =>
      _FloatingMetricsBackgroundState();
}

class _FloatingMetricsBackgroundState extends State<FloatingMetricsBackground> {
  final List<_FloatingMetricData> _items = [];
  Timer? _spawnTimer;
  final math.Random _random = math.Random();

  final List<String> _pool = [
    '+15%',
    '₦2.4M',
    '89%',
    '60%',
    'Low Risk',
    'Moderate',
    'On Time',
    '98',
    '-5%',
    'Healthy',
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 4; i++) {
      _spawnItem(i); // Initial burst
    }
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (_items.length < 8) _spawnItem(0); // Keep max 8 on screen
    });
  }

  void _spawnItem(int index) {
    if (!mounted) return;
    final id = '${DateTime.now().microsecondsSinceEpoch}_${index}_${_random.nextInt(100000)}';
    final text = _pool[_random.nextInt(_pool.length)];

    // Assign Colors based on Partnex Signal Rules
    Color color = AppColors.slate400;
    if (text == 'High' ||
        text == 'Medium' ||
        text == 'Low Risk' ||
        text == 'On Time') {
      color = AppColors.successGreen.withValues(alpha: 0.3);
    } else if (text.contains('-') || text == '89%') {
      color = AppColors.dangerRed.withValues(alpha: 0.3);
    } else if (text == 'Moderate' || text == '60%') {
      color = AppColors.warningOrange.withValues(alpha: 0.3);
    } else {
      color = AppColors.trustBlue.withValues(alpha: 0.2); // Default numbers
    }

    setState(() {
      _items.add(
        _FloatingMetricData(
          id: id,
          text: text,
          color: color,
          startX: _random.nextDouble(), // 0.0 to 1.0 (screen width)
          startY: _random.nextDouble(), // 0.0 to 1.0 (screen height)
          angle: (_random.nextDouble() * 0.5) - 0.25, // Slight tilt
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 6000), () {
      if (mounted) setState(() => _items.removeWhere((item) => item.id == id));
    });
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: _items
            .map((data) => _AnimatedDrifter(key: ValueKey(data.id), data: data))
            .toList(),
      ),
    );
  }
}

class _AnimatedDrifter extends StatefulWidget {
  final _FloatingMetricData data;
  const _AnimatedDrifter({super.key, required this.data});
  @override
  State<_AnimatedDrifter> createState() => _AnimatedDrifterState();
}

class _AnimatedDrifterState extends State<_AnimatedDrifter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _translateY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    // Drifts upwards slowly
    _translateY = Tween<double>(
      begin: 30,
      end: -60,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width > 0 ? size.width : 400.0;
    final h = size.height > 0 ? size.height : 800.0;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.data.startX * w,
          top: (widget.data.startY * h) + _translateY.value,
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.rotate(
              angle: widget.data.angle,
              child: Text(
                widget.data.text,
                style: AppTypography.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: widget.data.color,
                ),
              ),
            ),
          ),
        );
      },
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

  final List<Color> _colors = [
    AppColors.trustBlue,
    AppColors.trustBlue.withValues(alpha: 0.5),
    AppColors.warningOrange,
    AppColors.successGreen,
    AppColors.textSecondary(context).withValues(alpha: 0.6),
    AppColors.textSecondary(context).withValues(alpha: 0.4),
  ];

  @override
  void initState() {
    super.initState();
    // Start with 2 numbers
    _spawnNumber(0);
    _spawnNumber(1);

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) return;
      // Keep around 3-4 items on screen
      if (_numbers.length < 4) {
        _spawnNumber(_numbers.length);
      }
    });
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
