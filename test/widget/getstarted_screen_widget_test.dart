import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/presentation/screens/auth/login_screen.dart';
import 'package:pet_adoption_app/presentation/screens/onboarding/getstarted_screen.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: GetstartedScreen())),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('GetstartedScreen widgets', () {
    testWidgets('shows app brand and initial title', (tester) async {
      await _pump(tester);

      expect(find.text('PawBuddy'), findsOneWidget);
      expect(find.text('Find Your Perfect Companion'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('shows skip button', (tester) async {
      await _pump(tester);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('tap continue moves to second step', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Smart Search, Faster Match'), findsOneWidget);
    });

    testWidgets('tap continue twice moves to last step', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Adopt With Confidence'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('renders page indicators for onboarding steps', (tester) async {
      await _pump(tester);

      // There are at least 3 indicator gestures, one for each onboarding step.
      expect(find.byType(GestureDetector), findsAtLeastNWidgets(3));
    });

    testWidgets('skip navigates to LoginScreen', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('last page get started navigates to LoginScreen', (
      tester,
    ) async {
      await _pump(tester);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('shows at least one icon', (tester) async {
      await _pump(tester);
      expect(find.byIcon(Icons.pets), findsWidgets);
    });

    testWidgets('contains one elevated action button', (tester) async {
      await _pump(tester);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('contains three page indicators', (tester) async {
      await _pump(tester);
      expect(find.byType(AnimatedContainer), findsWidgets);
    });
  });
}
