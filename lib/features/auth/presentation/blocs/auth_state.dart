import 'package:equatable/equatable.dart';
import 'package:partnex/features/auth/data/models/user_model.dart';
import 'package:partnex/features/auth/data/models/credibility_score.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Special states for SME Onboarding submission
class SmeProfileSubmitting extends AuthState {}

class SmeProfileSubmittedSuccess extends AuthState {
  final CredibilityScore score;

  const SmeProfileSubmittedSuccess(this.score);

  @override
  List<Object?> get props => [score];
}

class SmeProfileSubmissionError extends AuthState {
  final String message;

  const SmeProfileSubmissionError(this.message);

  @override
  List<Object?> get props => [message];
}

// Special states for Investor Onboarding submission
class InvestorProfileSubmitting extends AuthState {}

class InvestorProfileSubmittedSuccess extends AuthState {}

class InvestorProfileSubmissionError extends AuthState {
  final String message;

  const InvestorProfileSubmissionError(this.message);

  @override
  List<Object?> get props => [message];
}
