import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/data/models/user_model.dart';

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
    on<RestoreSessionEvent>(_onRestoreSession);
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

      if (user.role == UserRole.sme) {
        try {
          final profileMap = await authRepository.getMySmeProfile();
          if (profileMap.isNotEmpty) {
            smeProfileCubit.updateFromMap(profileMap);
          }
        } catch (_) {
          // Ignore error if profile hasn't been created yet
        }
      } else if (user.role == UserRole.investor) {
        try {
          final profileMap = await authRepository.getMyInvestorProfile();
          if (profileMap.isNotEmpty) {
            final updatedUser = UserModel(
              id: user.id,
              email: user.email,
              name: user.name,
              role: user.role,
              profilePicture: user.profilePicture,
              profileCompleted: user.profileCompleted,
              investorType: profileMap['role'] ?? profileMap['investorType'] ?? profileMap['investor_type'],
              company: profileMap['company'] ?? profileMap['organization'],
              investmentRange: profileMap['ticketSize'] ?? profileMap['typical_ticket_size'] ?? profileMap['investmentRange'],
              sectors: profileMap['sectors'] != null 
                  ? List<String>.from(profileMap['sectors']) 
                  : (profileMap['preferred_sectors'] != null ? List<String>.from(profileMap['preferred_sectors']) : null),
            );
            emit(AuthAuthenticated(updatedUser));
            return;
          }
        } catch (_) {}
      }

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
      final score = await authRepository.submitSmeProfile(
        fullData,
        shouldGenerateScore: event.shouldGenerateScore,
      );
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
      
      // Fetch the updated user seamlessly to restore auth state
      final updatedUser = await authRepository.getCurrentUser();
      
      emit(InvestorProfileSubmittedSuccess());
      
      if (updatedUser != null) {
        // Force the local state to match reality: they just submitted, so profile IS completed
        final forcedUser = updatedUser.copyWith(profileCompleted: true);
        emit(AuthAuthenticated(forcedUser));
      }
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

  Future<void> _onRestoreSession(RestoreSessionEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}
