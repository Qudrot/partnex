import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_state.dart';
import 'package:partnex/features/auth/data/models/credibility_score.dart';
import 'package:partnex/features/auth/data/repositories/auth_repository.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/core/utils/financial_metrics_calculator.dart';

class ScoreCubit extends Cubit<ScoreState> {
  final AuthRepository authRepository;
  final SmeProfileCubit smeProfileCubit;

  ScoreCubit({required this.authRepository, required this.smeProfileCubit}) : super(ScoreInitial());

  Future<void> fetchDashboardData() async {
    emit(ScoreLoading());
    try {
      // 1. Fetch score — This endpoint ALSO returns basic profile data in our backend.
      // Calling getMyScore ensures we have the latest calculation from the server.
      final score = await authRepository.getMyScore();

      // 2. Fetch profile from backend — consolidated.
      // We grab both server data and local cache to ensure zero data loss.
      final serverProfile = await authRepository.getMySmeProfile();
      final cachedProfile = await authRepository.getCachedSmeProfile();

      // 3. AGGRESSIVE MERGE: ensure even unsynced local changes are preserved.
      final Map<String, dynamic> mergedProfile = {...cachedProfile, ...serverProfile};
      final profileState = SmeProfileState.fromMap(mergedProfile);

      // 4. Sync to SmeProfileCubit for "Add new" and profile editing flows
      smeProfileCubit.updateFromMap(mergedProfile);

      // 5. Calculate metrics from the unified state
      final metrics = FinancialMetricsCalculator.calculate(profileState);

      emit(ScoreLoadedSuccess(
        score: score,
        smeProfile: mergedProfile,
        financialMetrics: metrics,
      ));
    } catch (e) {
      emit(ScoreError(message: e.toString()));
    }
  }

  void loadScore(CredibilityScore credibilityScore) {
    final profileState = smeProfileCubit.state;
    final metrics = FinancialMetricsCalculator.calculate(profileState);
    
    emit(ScoreLoadedSuccess(
      score: credibilityScore, 
      smeProfile: profileState.toMap(),
      financialMetrics: metrics
    ));
  }
  
  void reset() {
    emit(ScoreInitial());
  }
}
