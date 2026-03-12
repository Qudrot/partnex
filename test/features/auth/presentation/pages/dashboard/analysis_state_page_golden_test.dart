import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_state.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/pages/dashboard/analysis_state_page.dart';

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

  group('AnalysisStatePage Golden Tests', () {
    testGoldens('AnalysisStatePage - Default State', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(size: Size(393, 852)),
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 393,
                height: 852,
                child: pumpApp(
                  const AnalysisStatePage(),
                  authBloc: mockAuthBloc,
                  smeProfileCubit: mockSmeCubit,
                  scoreCubit: mockScoreCubit,
                ),
              ),
            ),
          ),
        ),
      );
      
      await screenMatchesGolden(
        tester,
        'analysis_state_page_default',
        customPump: (tester) async {
          await tester.pump(const Duration(milliseconds: 50));
        },
      );
      
      // Cleanup to avoid "A Timer is still pending" exception
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle(const Duration(minutes: 6));
    });
  });
}
