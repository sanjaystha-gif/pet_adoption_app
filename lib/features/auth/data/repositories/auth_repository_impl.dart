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
        // Save token if provided (ensure String)
        final dynamic tokenRaw = response.data['token'];
        String? tokenStr;
        if (tokenRaw is String) {
          tokenStr = tokenRaw;
        } else if (tokenRaw is Map) {
          tokenStr =
              tokenRaw['token'] ??
              tokenRaw['accessToken'] ??
              tokenRaw.values.firstWhere((v) => v is String, orElse: () => null)
                  as String?;
        } else {
          tokenStr = tokenRaw?.toString();
        }
        if (tokenStr != null && tokenStr.isNotEmpty) {
          await hiveService.saveToken(tokenStr);
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
        final dynamic tokenRaw = response.data['token'];
        String? tokenStr;
        if (tokenRaw is String) {
          tokenStr = tokenRaw;
        } else if (tokenRaw is Map) {
          tokenStr =
              tokenRaw['token'] ??
              tokenRaw['accessToken'] ??
              tokenRaw.values.firstWhere((v) => v is String, orElse: () => null)
                  as String?;
        } else {
          tokenStr = tokenRaw?.toString();
        }

        final userData = response.data['user'] as Map<String, dynamic>;

        // Save token if present
        if (tokenStr != null && tokenStr.isNotEmpty) {
          await hiveService.saveToken(tokenStr);
        }

        // Save user data
        // Normalize address
        final dynamic rawAddress = userData['address'];
        String addressStr;
        if (rawAddress == null) {
          addressStr = '';
        } else if (rawAddress is String) {
          addressStr = rawAddress;
        } else if (rawAddress is Map) {
          addressStr =
              (rawAddress['address'] ?? rawAddress['fullAddress'] ?? '')
                  .toString();
        } else {
          addressStr = rawAddress.toString();
        }

        final user = AuthEntity(
          authId: userData['id'] ?? userData['_id'],
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          email: userData['email'] ?? '',
          phoneNumber: userData['phoneNumber'],
          address: addressStr,
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

        // Normalize address
        final dynamic rawAddressGet = userData['address'];
        String addressStrGet;
        if (rawAddressGet == null) {
          addressStrGet = '';
        } else if (rawAddressGet is String) {
          addressStrGet = rawAddressGet;
        } else if (rawAddressGet is Map) {
          addressStrGet =
              (rawAddressGet['address'] ?? rawAddressGet['fullAddress'] ?? '')
                  .toString();
        } else {
          addressStrGet = rawAddressGet.toString();
        }

        final user = AuthEntity(
          authId: userData['id'] ?? userData['_id'],
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          email: userData['email'] ?? '',
          phoneNumber: userData['phoneNumber'],
          address: addressStrGet,
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
