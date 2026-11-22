import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/screens/auth/auth_validators.dart';
import 'package:expense_tracker/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _app() => ChangeNotifierProvider(
  create: (_) => ExpenseProvider(),
  child: const MaterialApp(home: LoginScreen()),
);

void main() {
  group('AuthValidators', () {
    test('email must be filled and well formed', () {
      expect(AuthValidators.email(''), isNotNull);
      expect(AuthValidators.email('abc'), isNotNull);
      expect(AuthValidators.email('a@b.com'), isNull);
    });

    test('signup password needs at least 8 characters', () {
      expect(AuthValidators.signupPassword('1234567'), isNotNull);
      expect(AuthValidators.signupPassword('12345678'), isNull);
    });

    test('confirm password must match', () {
      expect(AuthValidators.confirmPassword('abc', 'abd'), isNotNull);
      expect(AuthValidators.confirmPassword('abc', 'abc'), isNull);
    });
  });

  group('Login screen', () {
    testWidgets('shows inline errors on empty submit', (tester) async {
      await tester.pumpWidget(_app());
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('valid login opens the dashboard', (tester) async {
      await tester.pumpWidget(_app());
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'a@b.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('can switch to sign-up and back', (tester) async {
      await tester.pumpWidget(_app());
      await tester.tap(find.text("Don't have an account? Sign up"));
      await tester.pumpAndSettle();
      expect(find.text('Create account'), findsOneWidget);

      await tester.tap(find.text('Already have an account? Log in'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('does not overflow on a small screen with keyboard', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = const FakeViewPadding(bottom: 200);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
