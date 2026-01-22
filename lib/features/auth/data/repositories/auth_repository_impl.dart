import 'package:dartz/dartz.dart';
import 'package:pet_adoption_app/core/error/failure.dart';
import 'package:pet_adoption_app/core/services/api/api_client.dart';
import 'package:pet_adoption_app/core/services/hive/hive_service.dart';
import 'package:pet_adoption_app/features/auth/data/models/auth_hive_model.dart';
import 'package:pet_adoption_app/features/auth/domain/entities/auth_entity.dart';
import 'package:pet_adoption_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final ApiClient apiClient;
  final HiveService hiveService;

  AuthRepositoryImpl({required this.apiClient, required this.hiveService});

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        data: {
          'firstName': user.firstName,
          'lastName': user.lastName,
          'email': user.email,
          'phoneNumber': user.phoneNumber,
          'address': user.address,
          'password': user.password,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Save token if provided
        final token = response.data['token'];
        if (token != null) {
          await hiveService.saveToken(token);
        }
        return const Right(true);
      }

      return Left(
        ApiFailure(
          message: response.data['message'] ?? 'Registration failed',
          statusCode: response.statusCode,
        ),
      );
    } on ApiFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'] as String;
        final userData = response.data['user'] as Map<String, dynamic>;

        // Save token
        await hiveService.saveToken(token);

        // Save user data
        final user = AuthEntity(
          authId: userData['id'] ?? userData['_id'],
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          email: userData['email'] ?? '',
          phoneNumber: userData['phoneNumber'],
          address: userData['address'],
        );

        // Save to Hive
        final hiveModel = AuthHiveModel(
          authId: user.authId,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          phoneNumber: user.phoneNumber,
          address: user.address ?? '',
        );

        await hiveService.saveAuthData(hiveModel);

        return Right(user);
      }

      return Left(
        ApiFailure(
          message: response.data['message'] ?? 'Login failed',
          statusCode: response.statusCode,
        ),
      );
    } on ApiFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final token = await hiveService.getToken();

      if (token == null) {
        return Left(ApiFailure(message: 'No token found'));
      }

      final response = await apiClient.get('/auth/me', token: token);

      if (response.statusCode == 200) {
        final userData = response.data['user'] as Map<String, dynamic>;

        final user = AuthEntity(
          authId: userData['id'] ?? userData['_id'],
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          email: userData['email'] ?? '',
          phoneNumber: userData['phoneNumber'],
          address: userData['address'],
        );

        return Right(user);
      }

      return Left(
        ApiFailure(
          message: response.data['message'] ?? 'Failed to get user',
          statusCode: response.statusCode,
        ),
      );
    } on ApiFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final token = await hiveService.getToken();

      if (token != null) {
        await apiClient.post('/auth/logout', data: {}, token: token);
      }

      // Clear local data
      await hiveService.clearAuthData();
      await hiveService.deleteToken();

      return const Right(true);
    } catch (e) {
      // Clear local data even on exception
      await hiveService.clearAuthData();
      await hiveService.deleteToken();
      return const Right(true);
    }
  }
}
