import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/pages/signup_page.dart';
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

  group('SignupPage Golden Tests', () {
    testGoldens('SignupPage - Empty State', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(const SignupPage(), authBloc: mockAuthBloc),
        surfaceSize: const Size(393, 852),
      );
      await screenMatchesGolden(tester, 'signup_page_empty');
    });

    testGoldens('SignupPage - Error State (Validation Errors)', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(const SignupPage(), authBloc: mockAuthBloc),
        surfaceSize: const Size(393, 852),
      );

      final createButtonFinder = find.text('Create Account').last;
      await tester.ensureVisible(createButtonFinder);
      await tester.tap(createButtonFinder);
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'signup_page_error');
    });

    testGoldens('SignupPage - Editing State (Filled Form)', (tester) async {
      await tester.pumpWidgetBuilder(
        pumpApp(const SignupPage(), authBloc: mockAuthBloc),
        surfaceSize: const Size(393, 852),
      );

      final nameField = find.widgetWithText(CustomInputField, 'Full Name');
      await tester.enterText(nameField, 'Jane Doe');

      final emailField = find.widgetWithText(CustomInputField, 'Email Address');
      await tester.enterText(emailField, 'jane.doe@example.com');

      final passwordField = find.widgetWithText(CustomInputField, 'Password');
      await tester.enterText(passwordField, 'Secure#123');

      final confirmPasswordField = find.widgetWithText(CustomInputField, 'Confirm Password');
      await tester.ensureVisible(confirmPasswordField);
      await tester.enterText(confirmPasswordField, 'Secure#123');

      final investorToggleFinder = find.text('Investor');
      await tester.ensureVisible(investorToggleFinder);
      await tester.tap(investorToggleFinder);
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'signup_page_editing');
    });
  });
}
