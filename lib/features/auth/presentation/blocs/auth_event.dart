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

class SignupEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const SignupEvent({required this.name, required this.email, required this.password});

  @override
  List<Object?> get props => [name, email, password];
}

class SubmitSmeProfileEvent extends AuthEvent {
  // This event captures all the onboarding data from the multi-step form.
  final Map<String, dynamic> profileData;

  const SubmitSmeProfileEvent(this.profileData);

  @override
  List<Object?> get props => [profileData];
}
