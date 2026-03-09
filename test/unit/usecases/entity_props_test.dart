import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/domain/entities/category_entity.dart';
import 'package:pet_adoption_app/domain/entities/pet_entity.dart';
import 'package:pet_adoption_app/domain/entities/user_entity.dart';

void main() {
  group('Entity props and equality', () {
    test('PetEntity equality uses all fields', () {
      final now = DateTime.now();
      final pet1 = PetEntity(
        id: 'p1',
        name: 'Buddy',
        description: 'Friendly dog',
        type: 'available',
        category: 'dog',
        location: 'NYC',
        mediaUrl: 'url1',
        mediaType: 'photo',
        breed: 'Labrador',
        age: 24,
        gender: 'male',
        size: 'large',
        healthStatus: 'healthy',
        isAdopted: false,
        postedBy: 'shelter1',
        postedByName: 'Shelter',
        createdAt: now,
      );

      final pet2 = PetEntity(
        id: 'p1',
        name: 'Buddy',
        description: 'Friendly dog',
        type: 'available',
        category: 'dog',
        location: 'NYC',
        mediaUrl: 'url1',
        mediaType: 'photo',
        breed: 'Labrador',
        age: 24,
        gender: 'male',
        size: 'large',
        healthStatus: 'healthy',
        isAdopted: false,
        postedBy: 'shelter1',
        postedByName: 'Shelter',
        createdAt: now,
      );

      expect(pet1.props, equals(pet2.props));
    });

    test('CategoryEntity props include all fields', () {
      final cat = CategoryEntity(
        id: 'cat1',
        name: 'Dogs',
        description: 'All dog breeds',
        icon: 'dog_icon',
      );

      expect(cat.props.length, 4);
      expect(cat.props.contains('Dogs'), isTrue);
    });

    test('UserEntity props handles optional role field', () {
      final user1 = UserEntity(
        id: 'u1',
        name: 'User Name',
        email: 'user@example.com',
        username: 'username',
        phoneNumber: '123',
        createdAt: DateTime.now(),
        role: 'admin',
      );

      final user2 = UserEntity(
        id: 'u1',
        name: 'User Name',
        email: 'user@example.com',
        username: 'username',
        phoneNumber: '123',
        createdAt: user1.createdAt,
        role: null,
      );

      expect(user1.props.length, user2.props.length);
    });
  });
}
