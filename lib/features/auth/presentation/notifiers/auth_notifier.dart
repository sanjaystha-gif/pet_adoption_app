import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/core/services/api/api_client.dart';
import 'package:pet_adoption_app/core/services/hive/hive_service.dart';
import 'package:pet_adoption_app/features/auth/data/models/auth_hive_model.dart';
import 'package:pet_adoption_app/features/auth/domain/entities/auth_entity.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final AuthEntity? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    AuthEntity? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier {
  final ApiClient apiClient;
  final HiveService hiveService;

  AuthNotifier({required this.apiClient, required this.hiveService});

  Future<AuthState> login(String email, String password) async {
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

        // Create user entity
        final user = AuthEntity(
          authId: userData['id'] ?? userData['_id'],
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          email: userData['email'] ?? '',
          phoneNumber: userData['phoneNumber'],
          address: userData['address'],
        );

        // Save user data to Hive
        final hiveModel = AuthHiveModel(
          authId: user.authId,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          phoneNumber: user.phoneNumber,
          address: user.address ?? '',
        );
        await hiveService.saveAuthData(hiveModel);

        return AuthState(isAuthenticated: true, isLoading: false, user: user);
      } else {
        return AuthState(
          isLoading: false,
          error: response.data['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return AuthState(isLoading: false, error: 'Login error: ${e.toString()}');
    }
  }

  Future<AuthState> register(
    String firstName,
    String lastName,
    String email,
    String password,
    String phoneNumber,
    String address,
  ) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'address': address,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final token = response.data['token'] ?? response.data['accessToken'];

        // Save token if provided
        if (token != null) {
          await hiveService.saveToken(token);
        }

        // Create user entity
        final userData = response.data['user'] ?? response.data;
        final user = AuthEntity(
          authId: userData['id'] ?? userData['_id'],
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: phoneNumber,
          address: address,
        );

        // Save user data to Hive
        final hiveModel = AuthHiveModel(
          authId: user.authId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: phoneNumber,
          address: address,
        );
        await hiveService.saveAuthData(hiveModel);

        return AuthState(isAuthenticated: true, isLoading: false, user: user);
      } else {
        return AuthState(
          isLoading: false,
          error: response.data['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      return AuthState(
        isLoading: false,
        error: 'Registration error: ${e.toString()}',
      );
    }
  }

  Future<AuthState> checkAuthStatus() async {
    try {
      // Check if token exists
      final token = await hiveService.getToken();

      if (token == null || token.isEmpty) {
        return AuthState(isLoading: false, isAuthenticated: false, user: null);
      }

      // Try to get user from local storage
      final hiveUser = await hiveService.getAuthData();

      if (hiveUser != null) {
        final user = AuthEntity(
          authId: hiveUser.authId,
          firstName: hiveUser.firstName,
          lastName: hiveUser.lastName,
          email: hiveUser.email,
          phoneNumber: hiveUser.phoneNumber,
          address: hiveUser.address,
        );

        return AuthState(isLoading: false, isAuthenticated: true, user: user);
      } else {
        return AuthState(isLoading: false, isAuthenticated: false, user: null);
      }
    } catch (e) {
      return AuthState(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: 'Error checking auth status: ${e.toString()}',
      );
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.post('/auth/logout', data: {});
    } catch (e) {
      // Ignore API errors
    } finally {
      // Always clear local data
      await hiveService.deleteToken();
      await hiveService.deleteAuthData();
    }
  }
}

final apiClientProvider = Provider((ref) => ApiClient());
final hiveServiceProvider = Provider((ref) => HiveService());

final authNotifierProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthNotifier(apiClient: apiClient, hiveService: hiveService);
});
