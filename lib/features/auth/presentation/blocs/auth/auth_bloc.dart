import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SmeProfileCubit smeProfileCubit;

  AuthBloc({
    required this.authRepository,
    required this.smeProfileCubit,
  }) : super(AuthInitial()) {
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
      
      // Transfer basic info to SmeProfileCubit
      smeProfileCubit.updateContactInfo(
        name: user.name,
        email: user.email,
        position: user.position,
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(msg));
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
        position: event.position,
      );

      // Transfer signup info to SmeProfileCubit
      smeProfileCubit.updateContactInfo(
        name: user.name,
        email: user.email,
        position: user.position,
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(msg));
    }
  }

  Future<void> _onSubmitSmeProfile(SubmitSmeProfileEvent event, Emitter<AuthState> emit) async {
    emit(SmeProfileSubmitting());
    try {
      // Merge current SmeProfileCubit state (bio, socials, contact info) into the submission payload
      final fullData = {
        ...smeProfileCubit.state.toMap(),
        ...event.profileData,
      };
      
      // The profileData map will be sent to the repository's API call
      final score = await authRepository.submitSmeProfile(fullData);
      emit(SmeProfileSubmittedSuccess(score));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(SmeProfileSubmissionError(msg));
    }
  }

  Future<void> _onSubmitInvestorProfile(SubmitInvestorProfileEvent event, Emitter<AuthState> emit) async {
    emit(InvestorProfileSubmitting());
    try {
      await authRepository.submitInvestorProfile(event.profileData);
      emit(InvestorProfileSubmittedSuccess());
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(InvestorProfileSubmissionError(msg));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(msg));
    }
  }
}
