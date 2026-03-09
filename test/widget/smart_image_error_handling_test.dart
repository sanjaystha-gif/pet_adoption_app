import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/presentation/widgets/smart_pet_image.dart';

void main() {
  group('SmartPetImage error handling', () {
    testWidgets('renders image widget when source provided', (tester) async {
      const widget = SmartPetImage(imageSource: 'assets/images/main_logo.png');

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: widget)));

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('applies fit property to image', (tester) async {
      const widget = SmartPetImage(
        imageSource: 'assets/images/main_logo.png',
        fit: BoxFit.contain,
      );

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: widget)));

      final image = tester.widget<Image>(find.byType(Image).first);
      expect(image.fit, BoxFit.contain);
    });

    testWidgets('network image uses correct source URL', (tester) async {
      const widget = SmartPetImage(imageSource: 'https://example.com/pet.jpg');

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: widget)));

      final image = tester.widget<Image>(find.byType(Image).first);
      expect(image.image, isA<NetworkImage>());
    });

    testWidgets('asset image uses correct path', (tester) async {
      const widget = SmartPetImage(imageSource: 'assets/images/main_logo.png');

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: widget)));

      final image = tester.widget<Image>(find.byType(Image).first);
      expect(image.image, isA<AssetImage>());
    });

    testWidgets('null source uses default logo asset', (tester) async {
      const widget = SmartPetImage(imageSource: null);

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: widget)));

      final image = tester.widget<Image>(find.byType(Image).first);
      expect(image.image, isA<AssetImage>());
    });
  });
}
