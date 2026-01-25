class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String bio;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.bio,
  });

  // Create a copy with modifications
  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? bio,
  }) {
    return UserModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      bio: bio ?? this.bio,
    );
  }

  // Get full name
  String get fullName => '$firstName $lastName';
}
