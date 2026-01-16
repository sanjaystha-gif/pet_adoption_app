import 'package:hive/hive.dart';
import 'package:pet_adoption_app/core/constants/hive_table_constant.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class AuthHiveModel {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String? phoneNumber;

  @HiveField(5)
  final String address;

  @HiveField(6)
  final String? password;

  AuthHiveModel({
    this.authId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    required this.address,
    this.password,
  });
}
