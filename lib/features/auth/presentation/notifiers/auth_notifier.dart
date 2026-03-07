import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/core/services/api/api_client.dart';
import 'package:pet_adoption_app/core/services/api/api_service.dart';
import 'package:pet_adoption_app/core/services/hive/hive_service.dart';
import 'package:pet_adoption_app/features/auth/data/models/auth_hive_model.dart';
import 'package:pet_adoption_app/features/auth/domain/entities/auth_entity.dart';
import 'package:pet_adoption_app/presentation/providers/api_providers.dart';

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
  final ApiService apiService;

  AuthNotifier({
    required this.apiClient,
    required this.hiveService,
    required this.apiService,
  });

  Future<AuthState> login(String email, String password) async {
    try {
      final response = await apiClient.post(
        '/adopters/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 🔍 DEBUG: Log entire API response
        debugPrint('\n🔍 LOGIN API RESPONSE:');
        debugPrint('Full response.data: ${response.data}');
        debugPrint('response.data type: ${response.data.runtimeType}');
        
        // Handle different response formats
        dynamic tokenRaw =
            response.data['token'] ??
            response.data['accessToken'] ??
            response.data;
        String? token;
        if (tokenRaw is String) {
          token = tokenRaw;
        } else if (tokenRaw is Map) {
          token =
              tokenRaw['token'] ??
              tokenRaw['accessToken'] ??
              tokenRaw.values.firstWhere((v) => v is String, orElse: () => null)
                  as String?;
        } else {
          token = tokenRaw?.toString();
        }

        if (token == null || token.isEmpty) {
          return AuthState(
            isLoading: false,
            error: 'No token in response from server',
          );
        }

        final userData = response.data['user'] ?? response.data;
        debugPrint('🔍 userData extracted: $userData');
        if (userData == null || userData is! Map) {
          return AuthState(
            isLoading: false,
            error: 'Invalid user data in response',
          );
        }

        // Save token in both Hive and ApiService secure storage (for interceptor)
        await hiveService.saveToken(token);
        await apiService.saveToken(token);

        // Try to get full user profile with GET request to fetch all fields
        // First try with userId, or fallback to email
        String userId =
            userData['id'] ?? userData['_id'] ?? userData['userId'] ?? '';
        
        debugPrint('🔍 Extracted userId from login response: "$userId"');
        debugPrint('  - userData["id"]: ${userData['id']}');
        debugPrint('  - userData["_id"]: ${userData['_id']}');
        debugPrint('  - userData["userId"]: ${userData['userId']}');

        // If no ID, use a generic endpoint or the email field we have
        var fullUserData = userData;

        if (userId.isNotEmpty) {
          try {
            final profileResponse = await apiClient.get('/adopters/$userId');
            if (profileResponse.statusCode == 200) {
              fullUserData =
                  profileResponse.data['data'] ??
                  profileResponse.data['user'] ??
                  profileResponse.data;
            }
          } catch (e) {
            // If profile fetch fails, just use the login response data
          }
        } else {
          // No userId found in login response
        }

        // Get firstName and lastName - try multiple field names
        String firstName =
            fullUserData['firstName'] ??
            fullUserData['first_name'] ??
            fullUserData['name'] ??
            '';
        String lastName =
            fullUserData['lastName'] ?? fullUserData['last_name'] ?? '';
        String phoneNumber =
            fullUserData['phoneNumber'] ??
            fullUserData['phone_number'] ??
            fullUserData['phone'] ??
            '';
        // Normalize address (server may return Map or String)
        final dynamic rawAddress = fullUserData['address'];
        String address;
        if (rawAddress == null) {
          address = '';
        } else if (rawAddress is String) {
          address = rawAddress;
        } else if (rawAddress is Map) {
          address = (rawAddress['address'] ?? rawAddress['fullAddress'] ?? '')
              .toString();
        } else {
          address = rawAddress.toString();
        }

        // If firstName is the full name and lastName is empty, try to split
        if (firstName.contains(' ') && lastName.isEmpty) {
          final parts = firstName.split(' ');
          firstName = parts.first;
          lastName = parts.skip(1).join(' ');
        }

        // Create user entity
        final user = AuthEntity(
          authId:
              fullUserData['id'] ?? fullUserData['_id'] ?? userId ?? 'unknown',
          firstName: firstName.isNotEmpty ? firstName : 'User',
          lastName: lastName,
          email: fullUserData['email'] ?? email ?? '',
          phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
          address: address.isNotEmpty ? address : null,
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

        // Verify what was saved
        await hiveService.getAuthData();

        return AuthState(isAuthenticated: true, isLoading: false, user: user);
      } else {
        final errorMsg =
            response.data['message'] ??
            response.data['error'] ??
            'Login failed';
        return AuthState(isLoading: false, error: errorMsg);
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
      // Clear any old cached data first
      await hiveService.deleteAuthData();

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

      if (response.statusCode == 201 || response.statusCode == 200) {
        // 🔍 DEBUG: Log entire API response
        debugPrint('\n🔍 REGISTER API RESPONSE:');
        debugPrint('Full response.data: ${response.data}');
        debugPrint('response.data type: ${response.data.runtimeType}');
        
        dynamic tokenRaw =
            response.data['token'] ??
            response.data['accessToken'] ??
            response.data;
        String? token;
        if (tokenRaw is String) {
          token = tokenRaw;
        } else if (tokenRaw is Map) {
          token =
              tokenRaw['token'] ??
              tokenRaw['accessToken'] ??
              tokenRaw.values.firstWhere((v) => v is String, orElse: () => null)
                  as String?;
        } else {
          token = tokenRaw?.toString();
        }

        // Save token if provided (persist to Hive and ApiService secure storage)
        if (token != null && token.isNotEmpty) {
          await hiveService.saveToken(token);
          await apiService.saveToken(token);
        }

        // Get user ID from response
        String userId =
            response.data['user']?['id'] ??
            response.data['user']?['_id'] ??
            response.data['id'] ??
            response.data['_id'] ??
            'unknown';
        
        debugPrint('🔍 Extracted userId from register response: "$userId"');
        debugPrint('  - response.data["user"]["id"]: ${response.data['user']?['id']}');
        debugPrint('  - response.data["user"]["_id"]: ${response.data['user']?['_id']}');
        debugPrint('  - response.data["id"]: ${response.data['id']}');
        debugPrint('  - response.data["_id"]: ${response.data['_id']}');

        // Try to fetch full user profile from backend
        var userData = response.data['user'] ?? response.data;
        if (userId != 'unknown' && userId.isNotEmpty) {
          try {
            final profileResponse = await apiClient.get('/adopters/$userId');
            if (profileResponse.statusCode == 200) {
              userData =
                  profileResponse.data['data'] ??
                  profileResponse.data['user'] ??
                  profileResponse.data;
            }
          } catch (e) {
            // Ignore profile fetch errors during signup
          }
        }

        // Normalize address from backend if present (server may return Map)
        final dynamic rawRespAddress = userData['address'];
        String addressFromResponse;
        if (rawRespAddress == null) {
          addressFromResponse = address;
        } else if (rawRespAddress is String) {
          addressFromResponse = rawRespAddress;
        } else if (rawRespAddress is Map) {
          addressFromResponse =
              (rawRespAddress['address'] ?? rawRespAddress['fullAddress'] ?? '')
                  .toString();
        } else {
          addressFromResponse = rawRespAddress.toString();
        }

        // Create user entity with firstName, lastName, phoneNumber, address
        final user = AuthEntity(
          authId: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: userData['phoneNumber'] ?? phoneNumber,
          address: addressFromResponse,
        );

        // Save user data to Hive
        final hiveModel = AuthHiveModel(
          authId: user.authId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: user.phoneNumber ?? phoneNumber,
          address: addressFromResponse,
        );
        await hiveService.saveAuthData(hiveModel);

        // Verify what was saved
        await hiveService.getAuthData();

        return AuthState(isAuthenticated: true, isLoading: false, user: user);
      } else {
        final errorMsg = response.data['message'] ?? 'Registration failed';
        return AuthState(isLoading: false, error: errorMsg);
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
        // Only restore if we have meaningful data
        if ((hiveUser.firstName.isNotEmpty) ||
            (hiveUser.lastName.isNotEmpty) ||
            (hiveUser.address.isNotEmpty)) {
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
          return AuthState(
            isLoading: false,
            isAuthenticated: false,
            user: null,
          );
        }
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

  Future<void> updateUserProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    String? profilePicture,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (email != null) updateData['email'] = email;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (address != null) updateData['address'] = address;
      if (profilePicture != null) updateData['profilePicture'] = profilePicture;
      if (firstName != null || lastName != null) {
        final f = firstName ?? '';
        final l = lastName ?? '';
        updateData['name'] = ('$f $l').trim();
      }

      // Make API call to update user profile using authenticated endpoint
      final response = await apiService.putAuth(
        '/adopters/$userId',
        data: updateData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
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

final authNotifierProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(
    apiClient: apiClient,
    hiveService: hiveService,
    apiService: apiService,
  );
});
