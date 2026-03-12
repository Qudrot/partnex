import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/pages/login_page.dart';
import 'package:partnex/core/theme/widgets/custom_input_field.dart';

import '../../../../helpers/pump_app.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(AuthInitial());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  group('LoginPage Golden Tests', () {
    testGoldens('LoginPage - Empty State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(const LoginPage(), authBloc: mockAuthBloc),
        surfaceSize: const Size(393, 852),
      );
      await screenMatchesGolden(tester, 'login_page_empty');
    });

    testGoldens('LoginPage - Error State (Validation Errors)', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(const LoginPage(), authBloc: mockAuthBloc),
        surfaceSize: const Size(393, 852),
      );

      final loginButtonFinder = find.text('Sign In').last;
      await tester.ensureVisible(loginButtonFinder);
      await tester.tap(loginButtonFinder);
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'login_page_validation_error');
    });

    testGoldens('LoginPage - Error State (Auth Failed Snackbar)', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthError('Invalid credentials'));

      await tester.pumpWidgetBuilder(
        pumpApp(const LoginPage(), authBloc: mockAuthBloc),
        surfaceSize: const Size(393, 852),
      );

      await screenMatchesGolden(tester, 'login_page_auth_error');
    });

    testGoldens('LoginPage - Editing State (Filled Form)', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(const LoginPage(), authBloc: mockAuthBloc),
        surfaceSize: const Size(393, 852),
      );

      final emailField = find.widgetWithText(CustomInputField, 'Email Address');
      await tester.enterText(emailField, 'test@example.com');

      final passwordField = find.widgetWithText(CustomInputField, 'Password');
      await tester.enterText(passwordField, 'Password123');
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'login_page_editing');
    });
  });
}
