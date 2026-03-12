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
      // 1. Fetch data from backend
      final serverProfile = await authRepository.getMySmeProfile();
      final score = await authRepository.getMyScore();
      
      // 2. Fetch data from local cache (raw UI map)
      final cachedProfile = await authRepository.getCachedSmeProfile();
      
      // 3. AGGRESSIVE MERGE: Construct a state from cache first, then overlay server data.
      // This ensures that any fields the server is missing (but were submitted) are preserved.
      final Map<String, dynamic> mergedProfile = {...cachedProfile, ...serverProfile};
      
      final profileState = SmeProfileState.fromMap(mergedProfile);
      
      // 4. Sync to SmeProfileCubit for "Add new" flow
      smeProfileCubit.updateFromMap(mergedProfile);
      
      // 5. Calculate metrics from the unified state
      final metrics = FinancialMetricsCalculator.calculate(profileState);
      
      emit(ScoreLoadedSuccess(
        score: score, 
        smeProfile: mergedProfile, 
        financialMetrics: metrics
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
