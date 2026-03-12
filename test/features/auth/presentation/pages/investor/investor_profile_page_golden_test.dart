import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/data/models/user_model.dart';
import 'package:partnex/features/auth/presentation/pages/investor/investor_profile_page.dart';

import '../../../../../helpers/pump_app.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();

    final testUser = UserModel(
      id: 'inv_123',
      email: 'investor@example.com',
      name: 'Jane Smith',
      role: UserRole.investor,
      profileCompleted: true,
      investorType: 'Venture Capital',
      company: 'Tech Fund Partners',
      investmentRange: '₦100M - ₦500M',
      sectors: const ['Technology', 'Healthcare', 'Agriculture'],
    );
    
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(testUser));
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  group('InvestorProfilePage Golden Tests', () {
    testGoldens('InvestorProfilePage - Completed State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(
          const InvestorProfilePage(),
          authBloc: mockAuthBloc,
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'investor_profile_page_completed');
    });

    testGoldens('InvestorProfilePage - Uncompleted State', (tester) async {
      final uncompletedUser = UserModel(
        id: 'inv_124',
        email: 'investor2@example.com',
        name: 'Bob Johnson',
        role: UserRole.investor,
        profileCompleted: false,
      );
      
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(uncompletedUser));

      await tester.pumpWidgetBuilder(
        pumpApp(
          const InvestorProfilePage(),
          authBloc: mockAuthBloc,
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'investor_profile_page_uncompleted');
    });
  });
}
