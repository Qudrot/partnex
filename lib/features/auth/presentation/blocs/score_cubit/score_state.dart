import 'package:equatable/equatable.dart';
import 'package:partnest/features/auth/data/models/credibility_score.dart';

abstract class ScoreState extends Equatable {
  const ScoreState();
  
  @override
  List<Object?> get props => [];
}

class ScoreInitial extends ScoreState {}

class ScoreLoading extends ScoreState {}

class ScoreLoadedSuccess extends ScoreState {
  final CredibilityScore score;

  const ScoreLoadedSuccess({required this.score});

  @override
  List<Object?> get props => [score];
}

class ScoreError extends ScoreState {
  final String message;

  const ScoreError({required this.message});

  @override
  List<Object?> get props => [message];
}
