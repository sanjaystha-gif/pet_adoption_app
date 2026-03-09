import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/presentation/widgets/smart_pet_image.dart';

Future<Image> _pumpAndGetImage(
  WidgetTester tester,
  SmartPetImage widget,
) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
  final imageFinder = find.byType(Image).first;
  return tester.widget<Image>(imageFinder);
}

void main() {
  group('SmartPetImage widget', () {
    testWidgets('uses fallback asset when source is null', (tester) async {
      final image = await _pumpAndGetImage(
        tester,
        const SmartPetImage(imageSource: null),
      );

      expect(image.image, isA<AssetImage>());
    });

    testWidgets('uses fallback asset when source is empty', (tester) async {
      final image = await _pumpAndGetImage(
        tester,
        const SmartPetImage(imageSource: ''),
      );

      expect(image.image, isA<AssetImage>());
    });

    testWidgets('uses network image for https url', (tester) async {
      final image = await _pumpAndGetImage(
        tester,
        const SmartPetImage(imageSource: 'https://example.com/pet.jpg'),
      );

      expect(image.image, isA<NetworkImage>());
    });

    testWidgets('uses network image for http url', (tester) async {
      final image = await _pumpAndGetImage(
        tester,
        const SmartPetImage(imageSource: 'http://example.com/pet.jpg'),
      );

      expect(image.image, isA<NetworkImage>());
    });

    testWidgets('resolves relative uploads path to network image', (
      tester,
    ) async {
      final image = await _pumpAndGetImage(
        tester,
        const SmartPetImage(imageSource: 'uploads/pet.jpg'),
      );

      expect(image.image, isA<NetworkImage>());
    });

    testWidgets('resolves slash-prefixed path to network image', (
      tester,
    ) async {
      final image = await _pumpAndGetImage(
        tester,
        const SmartPetImage(imageSource: '/uploads/pet.jpg'),
      );

      expect(image.image, isA<NetworkImage>());
    });

    testWidgets('keeps asset path source as asset image', (tester) async {
      final image = await _pumpAndGetImage(
        tester,
        const SmartPetImage(imageSource: 'assets/images/main_logo.png'),
      );

      expect(image.image, isA<AssetImage>());
    });

    testWidgets('converts plain filename to assets/images path', (
      tester,
    ) async {
      final image = await _pumpAndGetImage(
        tester,
        const SmartPetImage(imageSource: 'dog.png'),
      );

      expect(image.image, isA<AssetImage>());
    });

    testWidgets('strips bracketed source and still resolves network image', (
      tester,
    ) async {
      final image = await _pumpAndGetImage(
        tester,
        const SmartPetImage(imageSource: '[https://example.com/a.jpg]'),
      );

      expect(image.image, isA<NetworkImage>());
    });

    testWidgets('applies width and height to rendered image', (tester) async {
      const widget = SmartPetImage(
        imageSource: 'assets/images/main_logo.png',
        width: 120,
        height: 80,
      );
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: widget)));

      final image = tester.widget<Image>(find.byType(Image).first);
      expect(image.width, 120);
      expect(image.height, 80);
    });
  });
}
