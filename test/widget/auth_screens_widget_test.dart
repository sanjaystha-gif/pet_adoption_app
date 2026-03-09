import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/presentation/screens/auth/admin_login_screen.dart';
import 'package:pet_adoption_app/presentation/screens/auth/login_screen.dart';

Future<void> _pumpLogin(WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: LoginScreen())),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpAdmin(WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: AdminLoginScreen())),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Auth screen widgets', () {
    testWidgets('LoginScreen shows key labels', (tester) async {
      await _pumpLogin(tester);

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Admin Login'), findsOneWidget);
    });

    testWidgets('LoginScreen validation for empty fields', (tester) async {
      await _pumpLogin(tester);

      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('LoginScreen validation for invalid inputs', (tester) async {
      await _pumpLogin(tester);

      await tester.enterText(find.byType(TextField).at(0), 'abc');
      await tester.enterText(find.byType(TextField).at(1), '123');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter a valid email (e.g., example@gmail.com)'),
        findsOneWidget,
      );
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
    });

    testWidgets('AdminLoginScreen shows title and button', (tester) async {
      await _pumpAdmin(tester);

      expect(find.text('Admin Login'), findsOneWidget);
      expect(find.text('Login as Admin'), findsOneWidget);
    });

    testWidgets('AdminLoginScreen validation for empty fields', (tester) async {
      await _pumpAdmin(tester);

      await tester.tap(find.text('Login as Admin'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });
  });
}
