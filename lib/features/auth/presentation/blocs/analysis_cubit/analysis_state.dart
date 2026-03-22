import 'package:equatable/equatable.dart';

class AnalysisState extends Equatable {
  final double progress;
  final int step;
  final int totalSteps;
  final bool isError;
  final String? errorMessage;
  final bool isComplete;

  const AnalysisState({
    this.progress = 0.0,
    this.step = 1,
    this.totalSteps = 3,
    this.isError = false,
    this.errorMessage,
    this.isComplete = false,
  });

  AnalysisState copyWith({
    double? progress,
    int? step,
    int? totalSteps,
    bool? isError,
    String? errorMessage,
    bool? isComplete,
  }) {
    return AnalysisState(
      progress: progress ?? this.progress,
      step: step ?? this.step,
      totalSteps: totalSteps ?? this.totalSteps,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  List<Object?> get props => [progress, step, totalSteps, isError, errorMessage, isComplete];
}
