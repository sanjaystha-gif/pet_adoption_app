import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/presentation/screens/auth/admin_login_screen.dart';

void main() {
  group('AdminLoginScreen error states', () {
    testWidgets('shows error on invalid email only', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AdminLoginScreen())),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'invalid');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.text('Login as Admin'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter a valid email (e.g., admin@example.com)'),
        findsOneWidget,
      );
    });

    testWidgets('shows error on weak password only', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AdminLoginScreen())),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'admin@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'short');
      await tester.tap(find.text('Login as Admin'));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
    });

    testWidgets('maintains two text input fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AdminLoginScreen())),
      );
      await tester.pumpAndSettle();

      // Always has two TextField elements
      expect(find.byType(TextField), findsNWidgets(2));

      // Can enter text into both fields
      await tester.enterText(find.byType(TextField).at(0), 'admin@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.pumpAndSettle();

      // Both fields still exist
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('password visibility toggle works', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AdminLoginScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}
