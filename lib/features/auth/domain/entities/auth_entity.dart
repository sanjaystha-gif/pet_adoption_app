class AuthEntity {
  final String? authId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? password;

  AuthEntity({
    this.authId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.address,
    this.password,
  });

  @override
  String toString() {
    return 'AuthEntity(authId: $authId, firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthEntity &&
        other.authId == authId &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.address == address &&
        other.password == password;
  }

  @override
  int get hashCode {
    return authId.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode ^
        address.hashCode ^
        password.hashCode;
  }
}
