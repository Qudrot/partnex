import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/data/repositories/auth_repository.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/credibility_dashboard_page.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_discovery_feed_page.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/input_method_selection_page.dart';
import 'package:partnex/features/auth/presentation/pages/investor/investor_onboarding_page.dart';
import 'package:partnex/features/auth/presentation/pages/investor/investor_profile_page.dart';
import 'package:partnex/features/auth/presentation/pages/login_page.dart';
import 'package:partnex/features/auth/presentation/pages/signup_page.dart';
import 'package:partnex/features/auth/data/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<SignupEvent>(_onSignup);
    on<SubmitSmeProfileEvent>(_onSubmitSmeProfile);
    on<SubmitInvestorProfileEvent>(_onSubmitInvestorProfile);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
      if (user.role == UserRole.investor) {
        uiService.replaceWith(const SmeDiscoveryFeedPage());
      } else {
        if (user.profileCompleted) {
          uiService.replaceWith(const CredibilityDashboardPage());
        } else {
          uiService.replaceWith(const InputMethodSelectionPage());
        }
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(msg));
      if (msg.contains('REGISTRATION_REDIRECT')) {
        final displayMsg = msg.split('|')[0];
        uiService.showSnackBar(displayMsg);
        uiService.replaceWith(SignupPage(emailPrefill: event.email));
      } else {
        uiService.showSnackBar(msg, isError: true);
      }
    }
  }

  Future<void> _onSignup(SignupEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signup(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role,
      );
      emit(AuthAuthenticated(user));
      if (user.role == UserRole.investor) {
        uiService.replaceWith(const InvestorOnboardingPage());
      } else {
        uiService.replaceWith(const InputMethodSelectionPage());
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(msg));
      uiService.showSnackBar(msg, isError: true);
    }
  }

  Future<void> _onSubmitSmeProfile(SubmitSmeProfileEvent event, Emitter<AuthState> emit) async {
    emit(SmeProfileSubmitting());
    try {
      // The profileData map will be sent to the repository's API call
      final score = await authRepository.submitSmeProfile(event.profileData);
      emit(SmeProfileSubmittedSuccess(score));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(SmeProfileSubmissionError(msg));
      uiService.showSnackBar(msg, isError: true);
    }
  }

  Future<void> _onSubmitInvestorProfile(SubmitInvestorProfileEvent event, Emitter<AuthState> emit) async {
    emit(InvestorProfileSubmitting());
    try {
      await authRepository.submitInvestorProfile(event.profileData);
      emit(InvestorProfileSubmittedSuccess());
      if (event.isEditing) {
        uiService.showSnackBar('Criteria updated successfully');
        uiService.replaceWith(const InvestorProfilePage());
      } else {
        uiService.replaceWith(const SmeDiscoveryFeedPage());
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(InvestorProfileSubmissionError(msg));
      uiService.showSnackBar(msg, isError: true);
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(AuthUnauthenticated());
      uiService.clearAndNavigateTo(const LoginPage());
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(msg));
      uiService.showSnackBar(msg, isError: true);
    }
  }
}
