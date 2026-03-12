import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/discovery_cubit/discovery_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/discovery_cubit/discovery_state.dart';
import 'package:partnex/features/auth/data/models/user_model.dart';
import 'package:partnex/features/auth/data/models/sme_profile_data.dart';
import 'package:partnex/features/auth/presentation/pages/investor/sme_discovery_feed_page.dart';

import '../../../../../helpers/pump_app.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class MockDiscoveryCubit extends Mock implements DiscoveryCubit {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockDiscoveryCubit mockDiscoveryCubit;

  setUpAll(() {
    registerFallbackValue(DiscoveryInitial());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockDiscoveryCubit = MockDiscoveryCubit();

    final testUser = UserModel(
      id: '123',
      email: 'test@test.com',
      name: 'John Doe',
      role: UserRole.investor,
      profileCompleted: true,
    );

    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(testUser));
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    
    when(() => mockDiscoveryCubit.loadSmes()).thenAnswer((_) async {});
    when(() => mockDiscoveryCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  group('SmeDiscoveryFeedPage Golden Tests', () {
    testGoldens('SmeDiscoveryFeedPage - Loading', (tester) async {
      when(() => mockDiscoveryCubit.state).thenReturn(DiscoveryLoading());

      await tester.pumpWidgetBuilder(
        pumpApp(
          const SmeDiscoveryFeedPage(),
          authBloc: mockAuthBloc,
          discoveryCubit: mockDiscoveryCubit,
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'sme_discovery_feed_loading', customPump: (tester) async {
        await tester.pump(const Duration(milliseconds: 50));
      });
    });

    testGoldens('SmeDiscoveryFeedPage - Loaded', (tester) async {
      final mockSmes = [
        SmeCardData(
          id: '1',
          companyName: 'Tech Innovators',
          industry: 'Technology',
          location: 'Lagos, Nigeria',
          score: 85,
          generatedAt: DateTime.now(),
          yearsOfOperation: 3,
          numberOfEmployees: 15,
          annualRevenue: 50000000.0,
          monthlyExpenses: 2000000.0,
          liabilities: 5000000.0,
          fundingHistory: 'Seed',
          riskLevel: 'LOW',
        ),
      ];
      
      when(() => mockDiscoveryCubit.state).thenReturn(DiscoveryLoaded(smes: mockSmes));

      await tester.pumpWidgetBuilder(
        pumpApp(
          const SmeDiscoveryFeedPage(),
          authBloc: mockAuthBloc,
          discoveryCubit: mockDiscoveryCubit,
        ),
        surfaceSize: const Size(393, 852),
      );
      
      await screenMatchesGolden(tester, 'sme_discovery_feed_loaded');
    });
  });
}
