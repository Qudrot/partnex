import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnest/features/auth/presentation/blocs/score_cubit/score_state.dart';
import 'package:partnest/features/auth/data/models/credibility_score.dart';

class ScoreCubit extends Cubit<ScoreState> {
  ScoreCubit() : super(ScoreInitial());

  /// Currently, the score is retrieved when the SME profile is submitted
  /// via the AuthBloc -> AuthRepository. 
  /// So when that flow succeeds, we can inject that new score straight into here!
  void loadScore(CredibilityScore credibilityScore) {
    emit(ScoreLoading());
    // In a real flow where you fetch this directly without submitting first:
    // try {
    //   final score = await authRepository.getMyScore();
    //   emit(ScoreLoadedSuccess(score: score));
    // } catch (e) {
    //   emit(ScoreError(message: e.toString()));
    // }
    
    // For now we just inject the one we successfully created:
    emit(ScoreLoadedSuccess(score: credibilityScore));
  }
}
