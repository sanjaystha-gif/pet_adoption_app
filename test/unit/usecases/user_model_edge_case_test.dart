import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/presentation/providers/user_model.dart';

void main() {
  group('UserModel copyWith edge cases', () {
    test('copyWith with all null args returns identical data', () {
      final original = UserModel(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        phone: '123',
        address: 'USA',
        bio: 'Bio text',
      );

      final copy = original.copyWith();
      expect(copy.firstName, original.firstName);
      expect(copy.email, original.email);
      expect(copy.bio, original.bio);
    });

    test('copyWith handles empty string inputs', () {
      final model = UserModel(
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane@example.com',
        phone: '456',
        address: 'UK',
        bio: 'Original bio',
      );

      final updated = model.copyWith(firstName: '', bio: '');
      expect(updated.firstName, '');
      expect(updated.bio, '');
    });

    test('fullName concatenates with space separator', () {
      final model = UserModel(
        firstName: 'Mary',
        lastName: 'Johnson',
        email: 'm@example.com',
        phone: '789',
        address: 'Canada',
        bio: 'Bio',
      );

      expect(model.fullName, 'Mary Johnson');
      expect(model.fullName.contains(' '), isTrue);
    });

    test('copyWith single field update preserves others', () {
      final model = UserModel(
        firstName: 'Original',
        lastName: 'Name',
        email: 'orig@example.com',
        phone: '111',
        address: 'Addr',
        bio: 'Bio',
      );

      final updated = model.copyWith(email: 'new@example.com');
      expect(updated.firstName, 'Original');
      expect(updated.lastName, 'Name');
      expect(updated.email, 'new@example.com');
    });
  });
}
