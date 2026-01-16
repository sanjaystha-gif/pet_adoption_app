import 'package:pet_adoption_app/features/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthLocalDataSource {
  Future<void> register(AuthEntity user);
  Future<AuthEntity?> getUser();
  Future<void> deleteUser();
}

class AuthLocalDataSourceImpl implements IAuthLocalDataSource {
  @override
  Future<void> register(AuthEntity user) async {
    // TODO: Implement local storage
  }

  @override
  Future<AuthEntity?> getUser() async {
    // TODO: Implement getting user from local storage
    return null;
  }

  @override
  Future<void> deleteUser() async {
    // TODO: Implement delete user from local storage
  }
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthEntity> login(String email, String password);
  Future<AuthEntity> register(AuthEntity user);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  @override
  Future<AuthEntity> login(String email, String password) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<AuthEntity> register(AuthEntity user) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    // TODO: Implement API call
  }
}
