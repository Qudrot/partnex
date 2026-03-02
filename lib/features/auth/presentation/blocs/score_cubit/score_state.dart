import 'package:equatable/equatable.dart';
import 'package:partnex/features/auth/data/models/credibility_score.dart';
import 'package:partnex/features/auth/data/models/financial_metrics.dart';

abstract class ScoreState extends Equatable {
  const ScoreState();
  
  @override
  List<Object?> get props => [];
}

class ScoreInitial extends ScoreState {}

class ScoreLoading extends ScoreState {}

class ScoreLoadedSuccess extends ScoreState {
  final CredibilityScore score;
  final Map<String, dynamic> smeProfile;
  final FinancialMetrics? financialMetrics;

  const ScoreLoadedSuccess({
    required this.score,
    required this.smeProfile,
    this.financialMetrics,
  });

  @override
  List<Object?> get props => [score, smeProfile, financialMetrics];
}

class ScoreError extends ScoreState {
  final String message;

  const ScoreError({required this.message});

  @override
  List<Object?> get props => [message];
}
