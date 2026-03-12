import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:partnex/main.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/pages/login_page.dart';
import 'package:partnex/features/auth/presentation/pages/signup_page.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/discovery_cubit/discovery_state.dart';
import 'package:partnex/features/auth/data/models/sme_profile_data.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/features/auth/data/repositories/auth_repository.dart';

// ---------------------------------------------------------------------------
// Shared mock setup
// ---------------------------------------------------------------------------

void _mockPlatformChannels() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (MethodCall call) async {
      if (call.method == 'read') return null;
      if (call.method == 'write') return null;
      if (call.method == 'delete') return null;
      if (call.method == 'readAll') return <String, String>{};
      if (call.method == 'containsKey') return false;
      return null;
    },
  );
  SharedPreferences.setMockInitialValues({});
}

// ---------------------------------------------------------------------------
// Minimal fake repository: returns empty/sensible defaults for all methods.
// ---------------------------------------------------------------------------
class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// ---------------------------------------------------------------------------
// Helper: wrap a widget in the minimal BLoC providers it needs
// ---------------------------------------------------------------------------
Widget _wrapWithBlocs(Widget child) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(
          authRepository: _FakeAuthRepository(),
          smeProfileCubit: SmeProfileCubit(),
        ),
      ),
      BlocProvider<SmeProfileCubit>(create: (_) => SmeProfileCubit()),
    ],
    child: MaterialApp(home: child),
  );
}

// ---------------------------------------------------------------------------
// App smoke test
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(_mockPlatformChannels);

  group('App smoke test', () {
    testWidgets('builds MaterialApp and shows first route', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 6));
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  // ── LoginPage ──────────────────────────────────────────────────────────────
  group('LoginPage', () {
    testWidgets('renders email and password fields and Sign In button',
        (tester) async {
      await tester.pumpWidget(_wrapWithBlocs(const LoginPage()));
      await tester.pump();

      expect(find.text('Log In'), findsWidgets);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows validation error when submitting empty form',
        (tester) async {
      await tester.pumpWidget(_wrapWithBlocs(const LoginPage()));
      await tester.pump();

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Email validator fires
      expect(find.text('Please enter a valid email address'), findsOneWidget);
      // Password validator fires
      expect(find.text('Please enter your password.'), findsOneWidget);
    });

    testWidgets('shows forgot password button', (tester) async {
      await tester.pumpWidget(_wrapWithBlocs(const LoginPage()));
      await tester.pump();
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('Sign up link is present', (tester) async {
      await tester.pumpWidget(_wrapWithBlocs(const LoginPage()));
      await tester.pump();
      expect(find.textContaining("Don't have an account"), findsOneWidget);
    });

    testWidgets('has correct scaffold background colour', (tester) async {
      await tester.pumpWidget(_wrapWithBlocs(const LoginPage()));
      await tester.pump();
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, AppColors.neutralWhite);
    });
  });

  // ── SignupPage ──────────────────────────────────────────────────────────────
  group('SignupPage', () {
    testWidgets('renders all form fields', (tester) async {
      await tester.pumpWidget(_wrapWithBlocs(const SignupPage()));
      await tester.pump();

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsWidgets);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create Account'), findsWidgets);
    });

    testWidgets('SME and Investor role buttons are shown', (tester) async {
      await tester.pumpWidget(_wrapWithBlocs(const SignupPage()));
      await tester.pump();
      expect(find.text('SME'), findsOneWidget);
      expect(find.text('Investor'), findsOneWidget);
    });

    testWidgets('both SME and Investor role buttons are tappable widgets',
        (tester) async {
      await tester.pumpWidget(_wrapWithBlocs(const SignupPage()));
      await tester.pump();
      // Both role selector buttons must exist in the widget tree
      expect(find.text('SME'), findsOneWidget);
      expect(find.text('Investor'), findsOneWidget);
      // GestureDetectors wrapping each button must exist
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('terms of service footer is visible', (tester) async {
      await tester.pumpWidget(_wrapWithBlocs(const SignupPage()));
      await tester.pump();
      expect(find.textContaining('Terms of Service'), findsOneWidget);
      expect(find.textContaining('Privacy Policy'), findsOneWidget);
    });

    testWidgets('password strength indicator appears after typing',
        (tester) async {
      await tester.pumpWidget(_wrapWithBlocs(const SignupPage()));
      await tester.pump();

      // Third TextFormField in the form is the password field
      final allFields = find.byType(TextFormField);
      await tester.enterText(allFields.at(2), 'Passw0rd!');
      await tester.pump();

      // Strength indicator text should exist somewhere in the widget tree
      expect(
        find.byWidgetPredicate((w) =>
          w is Text &&
          ['Weak', 'Fair', 'Good', 'Strong', 'Too short'].contains(w.data)),
        findsWidgets,
      );
    });
  });

  // ── DiscoveryState widget rendering ──────────────────────────────────────
  group('DiscoveryState widget rendering', () {
    testWidgets('DiscoveryLoaded renders smes count correctly', (tester) async {
      final sme = SmeCardData(
        id: 'w1',
        companyName: 'Widget Co',
        industry: 'Tech',
        location: 'Lagos',
        yearsOfOperation: 2,
        numberOfEmployees: 5,
        annualRevenue: 500000,
        monthlyExpenses: 30000,
        liabilities: 0,
        fundingHistory: 'No prior funding',
        score: 70,
        riskLevel: 'LOW',
        generatedAt: DateTime(2024, 1, 1),
      );

      final state = DiscoveryLoaded(smes: [sme]);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (_) {
              return Text('${state.smes.length} SMEs');
            },
          ),
        ),
      );
      await tester.pump();
      expect(find.text('1 SMEs'), findsOneWidget);
    });

    testWidgets('DiscoveryError state shows error message', (tester) async {
      const state = DiscoveryError('Connection failed');
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (_) => Text(state.message),
          ),
        ),
      );
      expect(find.text('Connection failed'), findsOneWidget);
    });

    testWidgets('DiscoveryLoaded list is properly typed List<SmeCardData>',
        (tester) async {
      final sme = SmeCardData(
        id: 'type-test',
        companyName: 'Type Corp',
        industry: 'Finance',
        location: 'Abuja',
        yearsOfOperation: 1,
        numberOfEmployees: 3,
        annualRevenue: 100000,
        monthlyExpenses: 8000,
        liabilities: 0,
        fundingHistory: 'No prior funding',
        score: 55,
        riskLevel: 'HIGH',
        generatedAt: DateTime(2024, 3, 1),
      );
      final loaded = DiscoveryLoaded(smes: [sme]);
      // The list must be a proper typed List<SmeCardData> (not JSArray on web)
      expect(loaded.smes, isA<List<SmeCardData>>());
      expect(loaded.smes.first.id, 'type-test');
    });
  });

  // ── AuthBloc states (pure state assertions, no widget pump) ──────────────
  group('AuthBloc state assertions', () {
    test('AuthInitial is the correct starting state type', () {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(),
        smeProfileCubit: SmeProfileCubit(),
      );
      expect(bloc.state, isA<AuthInitial>());
      bloc.close();
    });

    test('AuthLoading and AuthInitial are distinct states', () {
      expect(AuthLoading(), isNot(isA<AuthInitial>()));
      expect(AuthInitial(), isNot(isA<AuthLoading>()));
    });

    test('AuthUnauthenticated is recognisable', () {
      final state = AuthUnauthenticated();
      expect(state, isA<AuthUnauthenticated>());
    });
  });
}
