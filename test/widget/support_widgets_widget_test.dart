import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/presentation/screens/auth/login_screen.dart';
import 'package:pet_adoption_app/presentation/screens/onboarding/getstarted_screen.dart';

void main() {
  group('Support widget behavior', () {
    testWidgets('LoginScreen has two text fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('LoginScreen has one elevated button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('GetstartedScreen has skip text button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: GetstartedScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('GetstartedScreen continue button exists initially', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: GetstartedScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('GetstartedScreen has animated switchers', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: GetstartedScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedSwitcher), findsWidgets);
    });
  });
}
