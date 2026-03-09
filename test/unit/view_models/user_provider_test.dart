import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/features/auth/domain/entities/auth_entity.dart';
import 'package:pet_adoption_app/presentation/providers/user_model.dart';
import 'package:pet_adoption_app/presentation/providers/user_provider.dart';

void main() {
  group('UserProvider', () {
    test('uses defaults when constructed empty', () {
      final provider = UserProvider();

      expect(provider.user.firstName, 'User');
      expect(provider.user.email, 'user@example.com');
      expect(provider.user.bio, 'Pet lover and animal enthusiast');
    });

    test('fromAuthEntity maps fields correctly', () {
      final auth = AuthEntity(
        authId: 'a1',
        firstName: 'Jamie',
        lastName: 'Fox',
        email: 'jamie@example.com',
        phoneNumber: '12345',
        address: 'Kathmandu',
      );

      final provider = UserProvider.fromAuthEntity(auth);
      expect(provider.user.firstName, 'Jamie');
      expect(provider.user.lastName, 'Fox');
      expect(provider.user.email, 'jamie@example.com');
      expect(provider.user.phone, '12345');
      expect(provider.user.address, 'Kathmandu');
    });

    test('updateProfile changes only provided fields', () {
      final provider = UserProvider(firstName: 'Old', email: 'old@example.com');

      provider.updateProfile(firstName: 'New');

      expect(provider.user.firstName, 'New');
      expect(provider.user.email, 'old@example.com');
    });

    test('updateUser replaces model and notifies listeners once', () {
      final provider = UserProvider();
      var calls = 0;
      provider.addListener(() {
        calls++;
      });

      provider.updateUser(
        UserModel(
          firstName: 'A',
          lastName: 'B',
          email: 'a@b.com',
          phone: '1',
          address: 'X',
          bio: 'Y',
        ),
      );

      expect(provider.user.email, 'a@b.com');
      expect(calls, 1);
    });

    test('reset restores predefined profile', () {
      final provider = UserProvider(firstName: 'Temp');
      provider.updateProfile(firstName: 'Changed');

      provider.reset();

      expect(provider.user.firstName, 'John');
      expect(provider.user.lastName, 'Doe');
      expect(provider.user.email, 'john.doe@example.com');
    });

    test('UserModel fullName joins names', () {
      final model = UserModel(
        firstName: 'Taylor',
        lastName: 'Swift',
        email: 't@example.com',
        phone: '123',
        address: 'NP',
        bio: 'Bio',
      );

      expect(model.fullName, 'Taylor Swift');
    });
  });
}
