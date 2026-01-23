import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String username;
  final String phoneNumber;
  final String? profilePicture;
  final DateTime createdAt;
  final String? role; // Optional: admin, user, etc.

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.phoneNumber,
    this.profilePicture,
    required this.createdAt,
    this.role,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    username,
    phoneNumber,
    profilePicture,
    createdAt,
    role,
  ];
}
