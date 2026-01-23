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
      print('📤 Attempting login with email: $email');
      final response = await apiClient.post(
        '/adopters/login',
        data: {'email': email, 'password': password},
      );

      print('✅ Login response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle different response formats
        final token = response.data['token'] ?? response.data['accessToken'];
        if (token == null) {
          return AuthState(
            isLoading: false,
            error: 'No token in response from server',
          );
        }

        final userData = response.data['user'] ?? response.data;
        if (userData == null || userData is! Map) {
          return AuthState(
            isLoading: false,
            error: 'Invalid user data in response',
          );
        }

        // Save token
        await hiveService.saveToken(token);

        // Create user entity
        final user = AuthEntity(
          authId: userData['id'] ?? userData['_id'] ?? 'unknown',
          firstName: userData['firstName'] ?? userData['first_name'] ?? '',
          lastName: userData['lastName'] ?? userData['last_name'] ?? '',
          email: userData['email'] ?? email ?? '',
          phoneNumber: userData['phoneNumber'] ?? userData['phone_number'],
          address: userData['address'] ?? '',
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

        print('✅ Login successful for: ${user.email}');
        return AuthState(isAuthenticated: true, isLoading: false, user: user);
      } else {
        final errorMsg =
            response.data['message'] ??
            response.data['error'] ??
            'Login failed';
        print('❌ Login failed with status ${response.statusCode}: $errorMsg');
        return AuthState(isLoading: false, error: errorMsg);
      }
    } catch (e) {
      print('❌ Login Error: $e');
      print('   Stack trace: ${StackTrace.current}');
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
      print('📤 Attempting registration for email: $email');
      final response = await apiClient.post(
        '/adopters',
        data: {
          'username': email, // Backend expects username
          'name': '$firstName $lastName', // Combine first and last name
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'address': address,
        },
      );

      print('✅ Registration response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final token = response.data['token'] ?? response.data['accessToken'];

        // Save token if provided
        if (token != null) {
          await hiveService.saveToken(token);
        }

        // Create user entity
        final userData = response.data['user'] ?? response.data;
        final user = AuthEntity(
          authId: userData['id'] ?? userData['_id'] ?? 'unknown',
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

        print('✅ Registration successful for: $email');
        return AuthState(isAuthenticated: true, isLoading: false, user: user);
      } else {
        final errorMsg = response.data['message'] ?? 'Registration failed';
        print(
          '❌ Registration failed with status ${response.statusCode}: $errorMsg',
        );
        return AuthState(isLoading: false, error: errorMsg);
      }
    } catch (e) {
      print('❌ Register Error: $e');
      print('   Stack trace: ${StackTrace.current}');
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
      await apiClient.post('/adopters/logout', data: {});
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
