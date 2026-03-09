import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/data/models/category_model.dart';
import 'package:pet_adoption_app/data/models/pet_model.dart';
import 'package:pet_adoption_app/domain/entities/booking_entity.dart';

void main() {
  group('Entity conversion use cases', () {
    test('CategoryModel converts to json and entity', () {
      final model = CategoryModel.fromJson({
        '_id': 'c1',
        'name': 'Dogs',
        'description': 'Friendly dogs',
        'icon': 'dog',
      });

      final entity = model.toEntity();
      final json = model.toJson();

      expect(entity.id, 'c1');
      expect(entity.name, 'Dogs');
      expect(json['name'], 'Dogs');
      expect(json['icon'], 'dog');
    });

    test('PetModel toEntity maps core fields', () {
      final model = PetModel.fromJson({
        '_id': 'p1',
        'name': 'Milo',
        'description': 'Calm',
        'type': 'available',
      });

      final entity = model.toEntity();

      expect(entity.id, 'p1');
      expect(entity.name, 'Milo');
      expect(entity.type, 'available');
    });

    test('BookingEntity copyWith updates selected values', () {
      final original = BookingEntity(
        id: 'b1',
        userId: 'u1',
        userName: 'Alex',
        userEmail: 'alex@example.com',
        userPhone: '123',
        petId: 'p1',
        petName: 'Rex',
        petImageUrl: 'img',
        status: 'pending',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      final updated = original.copyWith(status: 'approved', adminNotes: 'ok');

      expect(updated.status, 'approved');
      expect(updated.adminNotes, 'ok');
      expect(updated.userId, 'u1');
    });
  });
}
