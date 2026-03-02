import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_state.dart';
import 'package:partnex/features/auth/data/models/credibility_score.dart';
import 'package:partnex/features/auth/data/repositories/auth_repository.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/core/utils/financial_metrics_calculator.dart';

class ScoreCubit extends Cubit<ScoreState> {
  final AuthRepository authRepository;

  ScoreCubit({required this.authRepository}) : super(ScoreInitial());

  Future<void> fetchDashboardData() async {
    emit(ScoreLoading());
    try {
      final smeProfile = await authRepository.getMySmeProfile();
      final score = await authRepository.getMyScore();
      
      final profileState = SmeProfileState.fromMap(smeProfile);
      final metrics = FinancialMetricsCalculator.calculate(profileState);
      
      emit(ScoreLoadedSuccess(score: score, smeProfile: smeProfile, financialMetrics: metrics));
    } catch (e) {
      emit(ScoreError(message: e.toString()));
    }
  }

  void loadScore(CredibilityScore credibilityScore) {
    emit(ScoreLoadedSuccess(score: credibilityScore, smeProfile: const {}));
  }
  
  void reset() {
    emit(ScoreInitial());
  }
}
