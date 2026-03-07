import 'package:flutter/material.dart';
import 'user_model.dart';
import 'package:pet_adoption_app/features/auth/domain/entities/auth_entity.dart';

class UserProvider extends ChangeNotifier {
  late UserModel _user;

  UserProvider({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? bio,
  }) {
    _user = UserModel(
      firstName: (firstName != null && firstName.isNotEmpty)
          ? firstName
          : 'User',
      lastName: (lastName != null && lastName.isNotEmpty) ? lastName : '',
      email: (email != null && email.isNotEmpty) ? email : 'user@example.com',
      phone: (phone != null && phone.isNotEmpty) ? phone : '',
      address: (address != null && address.isNotEmpty) ? address : '',
      bio: (bio != null && bio.isNotEmpty)
          ? bio
          : 'Pet lover and animal enthusiast',
    );
  }

  // Factory constructor to create from AuthEntity
  factory UserProvider.fromAuthEntity(AuthEntity authEntity) {
    return UserProvider(
      firstName: authEntity.firstName,
      lastName: authEntity.lastName,
      email: authEntity.email,
      phone: authEntity.phoneNumber,
      address: authEntity.address,
      bio: 'Pet lover and animal enthusiast',
    );
  }

  UserModel get user => _user;

  void updateUser(UserModel newUser) {
    _user = newUser;
    notifyListeners();
  }

  void updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? bio,
  }) {
    _user = _user.copyWith(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      bio: bio,
    );
    notifyListeners();
  }

  void reset() {
    _user = UserModel(
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      phone: '+977-9841234567',
      address: 'Kathmandu, Nepal',
      bio: 'Pet lover and animal enthusiast',
    );
    notifyListeners();
  }
}
