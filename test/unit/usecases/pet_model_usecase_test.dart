import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/data/models/pet_model.dart';

void main() {
  group('PetModel parsing use cases', () {
    test('uses first media entry when media is a list', () {
      final model = PetModel.fromJson({
        '_id': '1',
        'itemName': 'Milo',
        'media': ['https://cdn.example.com/pet.png'],
      });

      expect(model.name, 'Milo');
      expect(model.mediaUrl, 'https://cdn.example.com/pet.png');
    });

    test('falls back to species when category is empty', () {
      final model = PetModel.fromJson({
        '_id': '1',
        'name': 'Nora',
        'species': 'cat',
      });

      expect(model.category, 'cat');
    });

    test('applies defaults for type mediaType and healthStatus', () {
      final model = PetModel.fromJson({'_id': '2', 'name': 'Rex'});

      expect(model.type, 'available');
      expect(model.mediaType, 'photo');
      expect(model.healthStatus, 'healthy');
    });

    test('marks model adopted when adoptionStatus is adopted', () {
      final model = PetModel.fromJson({
        '_id': '3',
        'name': 'Luna',
        'adoptionStatus': 'adopted',
      });

      expect(model.isAdopted, isTrue);
    });
  });
}
