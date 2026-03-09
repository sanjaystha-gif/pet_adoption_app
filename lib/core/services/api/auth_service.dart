import 'package:pet_adoption_app/core/error/failure.dart';
import 'package:pet_adoption_app/core/services/api/api_service.dart';
import 'package:pet_adoption_app/data/models/user_model.dart';
import 'package:pet_adoption_app/domain/entities/user_entity.dart';

/// Authentication Service
///
/// Handles user authentication including:
/// - User registration/signup
/// - User login with JWT token management
/// - Token refresh
/// - User logout and session management
class AuthService {
  final ApiService _apiService;

  // API endpoints matching Node.js backend routes
  static const String _studentsEndpoint = '/students';
  static const String _loginEndpoint = '/students/login';
  static const String _uploadProfileEndpoint = '/pets/items/upload-photo';
  static const String _uploadProfileEndpointAlt =
      '/adopters/upload-profile-picture';

  AuthService({required ApiService apiService}) : _apiService = apiService;

  /// Create user account (signup)
  ///
  /// Creates a new user account with provided credentials.
  /// Returns the created user entity if successful.
  Future<UserEntity> signup({
    required String name,
    required String email,
    required String username,
    required String password,
    required String phoneNumber,
    required String batchId, // Corresponds to organization/group ID
  }) async {
    try {
      final response = await _apiService.post(
        _studentsEndpoint,
        data: {
          'name': name,
          'email': email,
          'username': username,
          'password': password,
          'phoneNumber': phoneNumber,
          'batchId': batchId,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final userModel = UserModel.fromJson(
          response.data['data'] ?? response.data,
        );
        return userModel.toEntity();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Signup failed',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Signup error: ${e.toString()}');
    }
  }

  /// Login user with email and password
  ///
  /// Authenticates user with provided credentials and stores JWT token.
  /// Returns authenticated user entity with token stored securely.
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        _loginEndpoint,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Extract token and user data
        final token = data['token'] ?? data['data']?['token'];
        final userData = data['data'] ?? data;

        if (token != null && token.toString().isNotEmpty) {
          // Save token securely
          await _apiService.saveToken(token.toString());
        }

        // Parse user data
        final userModel = UserModel.fromJson(userData);
        return userModel.toEntity();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Login failed',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Login error: ${e.toString()}');
    }
  }

  /// Get current user profile
  ///
  /// Fetches the authenticated user's profile information.
  /// Requires authentication token.
  Future<UserEntity> getCurrentUser({required String userId}) async {
    try {
      final response = await _apiService.getAuth('$_studentsEndpoint/$userId');

      if (response.statusCode == 200) {
        final userModel = UserModel.fromJson(
          response.data['data'] ?? response.data,
        );
        return userModel.toEntity();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Failed to fetch user profile',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Get user error: ${e.toString()}');
    }
  }

  /// Get all users
  ///
  /// Fetches list of all users (admin/public endpoint).
  /// Optionally requires authentication based on API configuration.
  Future<List<UserEntity>> getAllUsers() async {
    try {
      final response = await _apiService.get(_studentsEndpoint);

      if (response.statusCode == 200) {
        final List<dynamic> users = response.data['data'] ?? response.data;
        return users
            .map((user) => UserModel.fromJson(user).toEntity())
            .toList();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Failed to fetch users',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Get all users error: ${e.toString()}');
    }
  }

  /// Get user by ID
  ///
  /// Fetches a specific user's profile by their ID.
  Future<UserEntity> getUserById({required String userId}) async {
    try {
      final response = await _apiService.get('$_studentsEndpoint/$userId');

      if (response.statusCode == 200) {
        final userModel = UserModel.fromJson(
          response.data['data'] ?? response.data,
        );
        return userModel.toEntity();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'User not found',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Get user by ID error: ${e.toString()}');
    }
  }

  /// Update user profile
  ///
  /// Updates authenticated user's profile information.
  /// Only the authenticated user can update their own profile.
  Future<UserEntity> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? username,
    String? phoneNumber,
    String? profilePicture,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (username != null) data['username'] = username;
      if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
      if (profilePicture != null) data['profilePicture'] = profilePicture;

      final response = await _apiService.putAuth(
        '$_studentsEndpoint/$userId',
        data: data,
      );

      if (response.statusCode == 200) {
        final userModel = UserModel.fromJson(
          response.data['data'] ?? response.data,
        );
        return userModel.toEntity();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Profile update failed',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Update profile error: ${e.toString()}');
    }
  }

  /// Delete user account
  ///
  /// Permanently deletes the user account.
  /// Requires authentication.
  Future<void> deleteAccount({required String userId}) async {
    try {
      final response = await _apiService.deleteAuth(
        '$_studentsEndpoint/$userId',
      );

      if (response.statusCode != 200) {
        throw ApiFailure(
          message: response.data['message'] ?? 'Account deletion failed',
          statusCode: response.statusCode,
        );
      }
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Delete account error: ${e.toString()}');
    }
  }

  /// Logout user
  ///
  /// Clears the authentication token and logs out the user.
  Future<void> logout() async {
    try {
      await _apiService.clearToken();
    } catch (e) {
      throw ApiFailure(message: 'Logout error: ${e.toString()}');
    }
  }

  /// Check if user is authenticated
  ///
  /// Verifies if a valid authentication token exists.
  Future<bool> isAuthenticated() async {
    return await _apiService.isTokenValid();
  }

  /// Upload profile picture
  ///
  /// Uploads a profile picture for the authenticated user.
  Future<String> uploadProfilePicture({required String filePath}) async {
    // ignore: avoid_print
    print('🖼️ AuthService: Uploading profile picture from: $filePath');

    final attempts = <({String endpoint, String fieldName})>[
      (endpoint: _uploadProfileEndpointAlt, fieldName: 'profilePicture'),
      (endpoint: _uploadProfileEndpointAlt, fieldName: 'media'),
      (endpoint: _uploadProfileEndpoint, fieldName: 'media'),
      (endpoint: _uploadProfileEndpoint, fieldName: 'profilePicture'),
    ];

    ApiFailure? lastFailure;

    for (final attempt in attempts) {
      try {
        // ignore: avoid_print
        print(
          '🖼️ AuthService: Trying endpoint=${attempt.endpoint}, field=${attempt.fieldName}',
        );

        final response = await _apiService.uploadFileAuth(
          attempt.endpoint,
          filePath: filePath,
          fieldName: attempt.fieldName,
          timeout: const Duration(seconds: 20),
        );

        // ignore: avoid_print
        print(
          '🖼️ AuthService: Upload response status: ${response.statusCode}',
        );
        // ignore: avoid_print
        print('🖼️ AuthService: Upload response data: ${response.data}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;

          dynamic url;
          if (data is Map<String, dynamic>) {
            url =
                data['data'] ??
                data['url'] ??
                data['mediaUrl'] ??
                data['profilePicture'];

            if (url is Map<String, dynamic>) {
              url =
                  url['url'] ??
                  url['mediaUrl'] ??
                  url['profilePicture'] ??
                  url['secure_url'];
            }
          }

          // ignore: avoid_print
          print('🖼️ AuthService: Extracted URL: $url');

          if (url != null && url.toString().trim().isNotEmpty) {
            return url.toString();
          }

          throw ApiFailure(
            message:
                'Upload succeeded but no URL field found in response for ${attempt.endpoint}',
            statusCode: response.statusCode,
          );
        }

        throw ApiFailure(
          message: 'Profile picture upload failed (${response.statusCode})',
          statusCode: response.statusCode,
        );
      } on ApiFailure catch (e) {
        lastFailure = e;
        // ignore: avoid_print
        print(
          '🖼️ AuthService: Attempt failed endpoint=${attempt.endpoint}, field=${attempt.fieldName}, error=${e.message}',
        );
      } catch (e) {
        lastFailure = ApiFailure(
          message: 'Upload profile picture error: ${e.toString()}',
        );
        // ignore: avoid_print
        print(
          '🖼️ AuthService: Attempt exception endpoint=${attempt.endpoint}, field=${attempt.fieldName}, error=$e',
        );
      }
    }

    throw lastFailure ??
        ApiFailure(message: 'Profile picture upload failed after all attempts');
  }
}
