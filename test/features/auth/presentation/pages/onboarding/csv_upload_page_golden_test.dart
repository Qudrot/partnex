import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/pages/onboarding/csv_upload_page.dart';

import '../../../../../helpers/pump_app.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class MockSmeProfileCubit extends Mock implements SmeProfileCubit {}
class MockScoreCubit extends Mock implements ScoreCubit {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockSmeProfileCubit mockSmeCubit;
  late MockScoreCubit mockScoreCubit;

  setUpAll(() {
    registerFallbackValue(AuthInitial());
    registerFallbackValue(SmeProfileState());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockSmeCubit = MockSmeProfileCubit();
    mockScoreCubit = MockScoreCubit();

    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockSmeCubit.state).thenReturn(SmeProfileState());
    when(() => mockSmeCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockScoreCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  group('CsvUploadPage Golden Tests', () {
    testGoldens('CsvUploadPage - Empty State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(
          const CsvUploadPage(),
          authBloc: mockAuthBloc,
          smeProfileCubit: mockSmeCubit,
          scoreCubit: mockScoreCubit,
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'csv_upload_page_empty');
    });

    testGoldens('CsvUploadPage - Error State', (tester) async {
      when(() => mockSmeCubit.state).thenReturn(
        SmeProfileState(
          csvProcessingStatus: CsvProcessingStatus.error,
          csvErrorMessage: 'Invalid CSV Format',
        ),
      );

      await tester.pumpWidgetBuilder(
        pumpApp(
          const CsvUploadPage(),
          authBloc: mockAuthBloc,
          smeProfileCubit: mockSmeCubit,
          scoreCubit: mockScoreCubit,
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'csv_upload_page_error');
    });
  });
}
