import 'package:flutter/material.dart';
import 'user_model.dart';

class UserProvider extends ChangeNotifier {
  late UserModel _user;

  UserProvider({
    String firstName = 'John',
    String lastName = 'Doe',
    String email = 'john.doe@example.com',
    String phone = '+977-9841234567',
    String address = 'Kathmandu, Nepal',
    String bio = 'Pet lover and animal enthusiast',
  }) {
    _user = UserModel(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      bio: bio,
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
