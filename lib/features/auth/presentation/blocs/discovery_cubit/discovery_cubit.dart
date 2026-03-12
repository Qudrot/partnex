import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/features/auth/data/repositories/auth_repository.dart';
import 'discovery_state.dart';
import 'package:flutter/foundation.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_profile_expanded_page.dart';
import 'package:partnex/features/auth/presentation/pages/investor/deep_dive_evidence_page.dart';
import 'package:partnex/features/auth/data/models/sme_profile_data.dart';

class DiscoveryCubit extends Cubit<DiscoveryState> {
  final AuthRepository authRepository;

  DiscoveryCubit({required this.authRepository}) : super(DiscoveryInitial());

  void viewSmeProfile(SmeCardData sme) {
    uiService.navigateTo(SmeProfileExpandedPage(sme: sme));
  }

  void viewDeepDiveEvidence() {
    uiService.navigateTo(const DeepDiveEvidencePage());
  }

  Future<void> loadSmes() async {
    emit(DiscoveryLoading());
    try {
      final dataList = await authRepository.getInvestorSmes();
      
      // if (kDebugMode && dataList.isNotEmpty) {
      //   print('DISCOVERY FEED FIRST ITEM: ${dataList.first}');
      // }
      
      // Explicitly typed to avoid JS runtime type mismatch on Flutter Web
      final List<SmeCardData> mappedSmes = [
        for (final map in dataList) SmeCardData.fromMap(map),
      ];
      emit(DiscoveryLoaded(smes: mappedSmes));
    } catch (e) {
      // if (kDebugMode) print('DiscoveryCubit Error: $e');
      
      // Clean up Exception prefix if it's there
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11); // remove 'Exception: '
      }
      
      emit(DiscoveryError('Failed to load SMEs:\n$errorMessage'));
    }
  }

  void reset() {
    emit(DiscoveryInitial());
  }
}
