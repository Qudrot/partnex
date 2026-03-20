import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LogoutEvent extends AuthEvent {}

class RestoreSessionEvent extends AuthEvent {}

class SignupEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;
  final String position;

  const SignupEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.position = '',
  });

  @override
  List<Object?> get props => [name, email, password, role, position];
}

class SubmitSmeProfileEvent extends AuthEvent {
  // This event captures all the onboarding data from the multi-step form.
  final Map<String, dynamic> profileData;
  final bool shouldGenerateScore;

  const SubmitSmeProfileEvent(this.profileData, {this.shouldGenerateScore = true});

  @override
  List<Object?> get props => [profileData, shouldGenerateScore];
}

class SubmitInvestorProfileEvent extends AuthEvent {
  final Map<String, dynamic> profileData;
  final bool isEditing;

  const SubmitInvestorProfileEvent(this.profileData, {this.isEditing = false});

  @override
  List<Object?> get props => [profileData, isEditing];
}
