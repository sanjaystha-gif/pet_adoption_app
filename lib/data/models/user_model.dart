import 'package:pet_adoption_app/domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String username;
  final String phoneNumber;
  final String? profilePicture;
  final DateTime createdAt;
  final String? role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.phoneNumber,
    this.profilePicture,
    required this.createdAt,
    this.role,
  });

  /// Convert from JSON response from API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profilePicture: json['profilePicture'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      role: json['role'],
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'role': role,
    };
  }

  /// Convert to Entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      username: username,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      createdAt: createdAt,
      role: role,
    );
  }
}
