import 'package:pet_adoption_app/core/services/api/api_client.dart';
import 'package:pet_adoption_app/core/services/api/api_service.dart';
import 'package:pet_adoption_app/core/services/hive/hive_service.dart';
import 'package:pet_adoption_app/features/auth/data/models/auth_hive_model.dart';
import 'package:pet_adoption_app/features/auth/domain/entities/auth_entity.dart';

class AdminAuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final bool isAdmin;
  final AuthEntity? user;
  final String? error;

  AdminAuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.isAdmin = false,
    this.user,
    this.error,
  });

  AdminAuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    bool? isAdmin,
    AuthEntity? user,
    String? error,
  }) {
    return AdminAuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isAdmin: isAdmin ?? this.isAdmin,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AdminAuthNotifier {
  final ApiClient apiClient;
  final HiveService hiveService;
  final ApiService apiService;

  AdminAuthNotifier({
    required this.apiClient,
    required this.hiveService,
    required this.apiService,
  });

  /// Login as admin - verifies user is admin
  Future<AdminAuthState> adminLogin(String email, String password) async {
    try {
      final response = await apiClient.post(
        '/adopters/admin/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'] ?? response.data['accessToken'];
        if (token == null) {
          return AdminAuthState(
            isLoading: false,
            error: 'No token in response from server',
          );
        }

        final userData =
            response.data['adopter'] ?? response.data['user'] ?? response.data;
        if (userData == null || userData is! Map) {
          return AdminAuthState(
            isLoading: false,
            error: 'Invalid user data in response',
          );
        }

        // Check if user is admin
        final isAdmin =
            userData['role'] == 'admin' ||
            userData['isAdmin'] == true ||
            userData['admin'] == true;

        if (!isAdmin) {
          return AdminAuthState(
            isLoading: false,
            error: 'Access denied. Only admin users can login here.',
            isAuthenticated: false,
            isAdmin: false,
          );
        }

        // Save admin token to both HiveService and ApiService
        await hiveService.saveToken(token);
        await apiService.saveToken(token);

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

        return AdminAuthState(
          isAuthenticated: true,
          isAdmin: true,
          isLoading: false,
          user: user,
        );
      } else {
        final errorMsg =
            response.data['message'] ??
            response.data['error'] ??
            'Admin login failed';
        return AdminAuthState(isLoading: false, error: errorMsg);
      }
    } catch (e) {
      return AdminAuthState(
        isLoading: false,
        error: 'Login error: ${e.toString()}',
      );
    }
  }

  /// Check if user is authenticated as admin
  Future<AdminAuthState> checkAdminAuthStatus() async {
    try {
      final token = await hiveService.getToken();

      if (token == null || token.isEmpty) {
        return AdminAuthState(
          isLoading: false,
          isAuthenticated: false,
          isAdmin: false,
          user: null,
        );
      }

      // Get user from local storage
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

        return AdminAuthState(
          isLoading: false,
          isAuthenticated: true,
          isAdmin: true,
          user: user,
        );
      } else {
        return AdminAuthState(
          isLoading: false,
          isAuthenticated: false,
          isAdmin: false,
          user: null,
        );
      }
    } catch (e) {
      return AdminAuthState(
        isLoading: false,
        isAuthenticated: false,
        isAdmin: false,
        user: null,
        error: 'Error checking admin auth status: ${e.toString()}',
      );
    }
  }

  /// Logout admin
  Future<void> adminLogout() async {
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
