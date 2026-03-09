import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/data/models/booking_model.dart';

void main() {
  group('BookingModel parsing use cases', () {
    test('reads nested user and pet objects', () {
      final model = BookingModel.fromJson({
        '_id': 'b1',
        'status': 'PENDING',
        'user': {
          '_id': 'u1',
          'name': 'Ava',
          'email': 'ava@example.com',
          'phone': '9841',
        },
        'pet': {
          '_id': 'p1',
          'name': 'Bruno',
          'photos': ['img.jpg'],
        },
        'createdAt': '2024-01-01T00:00:00.000Z',
      });

      expect(model.userId, 'u1');
      expect(model.userName, 'Ava');
      expect(model.petId, 'p1');
      expect(model.petImageUrl, 'img.jpg');
    });

    test('normalizes status to lower case', () {
      final model = BookingModel.fromJson({'_id': 'b2', 'status': 'APPROVED'});
      expect(model.status, 'approved');
    });

    test('toJson writes ISO date strings', () {
      final model = BookingModel.fromJson({
        '_id': 'b3',
        'userId': 'u2',
        'userName': 'User',
        'userEmail': 'u@example.com',
        'userPhone': '123',
        'petId': 'p2',
        'petName': 'Pet',
        'petImageUrl': 'image',
        'status': 'pending',
        'createdAt': '2024-01-01T00:00:00.000Z',
      });

      final json = model.toJson();
      expect(json['createdAt'], isA<String>());
      expect((json['createdAt'] as String).contains('T'), isTrue);
    });

    test('uses current time when createdAt is invalid', () {
      final before = DateTime.now().subtract(const Duration(seconds: 2));
      final model = BookingModel.fromJson({
        '_id': 'b4',
        'createdAt': 'invalid',
      });
      final after = DateTime.now().add(const Duration(seconds: 2));

      expect(model.createdAt.isAfter(before), isTrue);
      expect(model.createdAt.isBefore(after), isTrue);
    });
  });
}
