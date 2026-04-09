import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'analysis_state.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';

class AnalysisCubit extends Cubit<AnalysisState> {
  final SmeProfileCubit profileCubit;
  final AuthBloc authBloc;
  final ScoreCubit scoreCubit;
  final bool isDocumentUpload;

  Timer? _progressTimer;
  Timer? _timeoutTimer;
  bool _apiComplete = false;
  bool _minimumTimeElapsed = false;

  AnalysisCubit({
    required this.profileCubit,
    required this.authBloc,
    required this.scoreCubit,
    this.isDocumentUpload = false,
  }) : super(AnalysisState(totalSteps: isDocumentUpload ? 4 : 3)) {
    _startAnalysis();
  }

  void _startAnalysis() {
    _minimumTimeElapsed = false;
    _apiComplete = false;

    Future.delayed(const Duration(milliseconds: 4500), () {
      if (isClosed) return;
      _minimumTimeElapsed = true;
      _checkAndComplete();
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (isClosed) return;
      
      double newProgress = state.progress;
      double increment = isDocumentUpload ? 1.5 : 10.0;

      if (newProgress < 90) {
        newProgress += increment;
      }

      int newStep = state.step;
      if (isDocumentUpload) {
        if (newProgress < 25) {
          newStep = 1;
        } else if (newProgress < 50) newStep = 2;
        else if (newProgress < 75) newStep = 3;
        else newStep = 4;
      } else {
        if (newProgress < 33) {
          newStep = 1;
        } else if (newProgress < 66) newStep = 2;
        else newStep = 3;
      }

      emit(state.copyWith(progress: newProgress, step: newStep));
    });

    _timeoutTimer = Timer(const Duration(minutes: 5), () {
      if (isClosed) return;
      emit(state.copyWith(isError: true, errorMessage: 'Analysis timed out'));
      _progressTimer?.cancel();
    });

    _runApiWorkflow();
  }

  Future<void> _runApiWorkflow() async {
    if (profileCubit.state.csvProcessingStatus == CsvProcessingStatus.processing) {
      await for (final pState in profileCubit.stream) {
        if (pState.csvProcessingStatus == CsvProcessingStatus.success ||
            pState.csvProcessingStatus == CsvProcessingStatus.error) {
          break;
        }
      }
    }

    if (profileCubit.state.csvProcessingStatus == CsvProcessingStatus.error) {
      _handleError(profileCubit.state.csvErrorMessage ?? 'Financial document analysis failed');
      return;
    }

    if (authBloc.state is! SmeProfileSubmittedSuccess) {
      authBloc.add(SubmitSmeProfileEvent(profileCubit.state.toMap()));
    }

    final currentState = authBloc.state;
    if (currentState is SmeProfileSubmittedSuccess) {
      _markApiComplete(currentState.score);
      return;
    } else if (currentState is SmeProfileSubmissionError) {
      _handleError(currentState.message);
      return;
    }

    await for (final aState in authBloc.stream) {
      if (isClosed) return;
      if (aState is SmeProfileSubmittedSuccess) {
        _markApiComplete(aState.score);
        break;
      } else if (aState is SmeProfileSubmissionError) {
        _handleError(aState.message);
        break;
      }
    }
  }

  void _markApiComplete(dynamic score) {
    if (isClosed) return;
    _apiComplete = true;
    scoreCubit.loadScore(score);
    
    emit(state.copyWith(
      progress: 95.0,
      step: state.totalSteps,
    ));

    _checkAndComplete();
  }

  void _checkAndComplete() {
    if (_apiComplete && _minimumTimeElapsed) {
      _progressTimer?.cancel();
      _timeoutTimer?.cancel();

      emit(state.copyWith(progress: 100.0));

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!isClosed) {
          emit(state.copyWith(isComplete: true));
        }
      });
    }
  }

  void _handleError(String message) {
    if (isClosed) return;
    _progressTimer?.cancel();
    _timeoutTimer?.cancel();
    emit(state.copyWith(isError: true, errorMessage: message));
  }

  @override
  Future<void> close() {
    _progressTimer?.cancel();
    _timeoutTimer?.cancel();
    return super.close();
  }
}
