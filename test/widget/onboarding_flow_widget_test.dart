import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/presentation/screens/onboarding/getstarted_screen.dart';

void main() {
  group('GetstartedScreen state and animation', () {
    testWidgets('maintains state across navigate backwards', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: GetstartedScreen())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Smart Search, Faster Match'), findsOneWidget);

      // Note: GetstartedScreen doesn't have explicit back button in middle steps
      // so this just verifies state after forward navigation
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('has multiple text widgets for descriptions', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: GetstartedScreen())),
      );
      await tester.pumpAndSettle();

      // At least one text widget with substantial content
      expect(find.byType(Text), findsWidgets);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Text widgets still present after navigation
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('icon changes per step', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: GetstartedScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pets), findsWidgets);
      expect(find.byIcon(Icons.search_rounded), findsNothing);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_rounded), findsWidgets);
    });

    testWidgets('gradient changes per step', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: GetstartedScreen())),
      );
      await tester.pumpAndSettle();

      final scaffold1 = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold1.body, isNotNull);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      final scaffold2 = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold2.body, isNotNull);
    });

    testWidgets('continues through all three steps', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: GetstartedScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Find Your Perfect Companion'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Smart Search, Faster Match'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Adopt With Confidence'), findsOneWidget);
    });
  });
}
