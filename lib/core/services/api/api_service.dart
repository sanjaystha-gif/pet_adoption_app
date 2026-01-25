import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pet_adoption_app/core/error/failure.dart';

/// Enhanced API Service with authentication and interceptor support
///
/// This service handles all API communication for the Pet Adoption App.
/// It includes JWT token management, request/response logging, error handling,
/// and rate limiting support following the Node.js API architecture.
class ApiService {
  // API Configuration - matches Node.js backend
  static const String baseUrl = 'http://10.0.2.2:5000/api/v1';
  // For Android Emulator: 10.0.2.2 points to host computer
  // For physical device or web: use your actual backend URL
  // Example: 'https://your-api.com/api/v1'

  static const String apiVersion = '/v1';
  static const int connectionTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds

  late Dio _dio;
  late Dio _dioWithAuth;
  late FlutterSecureStorage _secureStorage;
  String? _cachedToken;

  // Singleton instance
  static final ApiService _instance = ApiService._internal();

  ApiService._internal() {
    _secureStorage = const FlutterSecureStorage();
    _initializeDio();
  }

  factory ApiService() {
    return _instance;
  }

  /// Initialize Dio instances with base configuration
  void _initializeDio() {
    // Basic Dio instance (no auth required)
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: connectionTimeout),
        receiveTimeout: const Duration(milliseconds: receiveTimeout),
        contentType: 'application/json',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Dio instance with auth interceptor
    _dioWithAuth = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: connectionTimeout),
        receiveTimeout: const Duration(milliseconds: receiveTimeout),
        contentType: 'application/json',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      _createLoggingInterceptor(),
      _createErrorHandlingInterceptor(),
    ]);

    _dioWithAuth.interceptors.addAll([
      _createAuthInterceptor(),
      _createLoggingInterceptor(),
      _createErrorHandlingInterceptor(),
    ]);
  }

  /// Create authentication interceptor that adds Bearer token
  InterceptorsWrapper _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getStoredToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          print(
            '✅ Token added to request: Bearer ${token.substring(0, 20)}...',
          );
        } else {
          print(
            '⚠️ NO TOKEN FOUND - Request will fail if endpoint requires auth',
          );
        }
        return handler.next(options);
      },
    );
  }

  /// Create logging interceptor for debugging
  InterceptorsWrapper _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // Debug logging - uncomment for development
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📤 REQUEST');
        print('Method: ${options.method.toUpperCase()}');
        print('Path: ${options.path}');
        print('Query: ${options.queryParameters}');
        if (options.data != null) {
          print('Data: ${options.data}');
        }
        print('Headers: ${options.headers}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Debug logging - uncomment for development
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📥 RESPONSE: ${response.statusCode}');
        print('Path: ${response.requestOptions.path}');
        print('Data: ${response.data}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return handler.next(response);
      },
      onError: (error, handler) {
        // Debug logging - uncomment for development
        // print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        // print('❌ ERROR');
        // print('Message: ${error.message}');
        // print('Status: ${error.response?.statusCode}');
        // print('Data: ${error.response?.data}');
        // print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return handler.next(error);
      },
    );
  }

  /// Create error handling interceptor
  InterceptorsWrapper _createErrorHandlingInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired or unauthorized - clear token
          _secureStorage.delete(key: 'auth_token');
          _cachedToken = null;
        }
        return handler.next(error);
      },
    );
  }

  // ==================== TOKEN MANAGEMENT ====================

  /// Save authentication token securely
  Future<void> saveToken(String token) async {
    try {
      _cachedToken = token;
      await _secureStorage.write(key: 'auth_token', value: token);
      print('💾 Token saved successfully: ${token.substring(0, 30)}...');
    } catch (e) {
      // Debug logging - uncomment for development
      print('Error saving token: $e');
      rethrow;
    }
  }

  /// Retrieve stored authentication token
  Future<String?> getStoredToken() async {
    try {
      if (_cachedToken != null) {
        print('📦 Token from cache: ${_cachedToken!.substring(0, 20)}...');
        return _cachedToken;
      }
      _cachedToken = await _secureStorage.read(key: 'auth_token');
      if (_cachedToken != null) {
        print('📦 Token from storage: ${_cachedToken!.substring(0, 20)}...');
      } else {
        print('📦 No token found in storage');
      }
      return _cachedToken;
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  /// Clear authentication token
  Future<void> clearToken() async {
    try {
      _cachedToken = null;
      await _secureStorage.delete(key: 'auth_token');
    } catch (e) {
      // Debug logging - uncomment for development
      // print('Error clearing token: $e');
      rethrow;
    }
  }

  /// Get the authenticated Dio instance with auth interceptor
  Dio get dio => _dioWithAuth;

  // ==================== HTTP METHODS ====================

  /// Perform POST request (Public - No Auth)
  /// Used for login, signup, public item creation
  Future<Response> post(
    String endpoint, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw ApiFailure(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Perform POST request (Protected - Requires Auth)
  /// Automatically adds Bearer token from secure storage
  Future<Response> postAuth(
    String endpoint, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dioWithAuth.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw ApiFailure(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Perform GET request (Public - No Auth)
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw ApiFailure(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Perform GET request (Protected - Requires Auth)
  Future<Response> getAuth(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dioWithAuth.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw ApiFailure(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Perform PUT request (Protected - Requires Auth)
  Future<Response> putAuth(
    String endpoint, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dioWithAuth.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw ApiFailure(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Perform PUT request (Public - No Auth)
  Future<Response> put(
    String endpoint, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw ApiFailure(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Perform DELETE request (Protected - Requires Auth)
  Future<Response> deleteAuth(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dioWithAuth.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw ApiFailure(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Perform DELETE request (Public - No Auth)
  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw ApiFailure(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ==================== FILE UPLOAD ====================

  /// Upload file with authentication
  Future<Response> uploadFileAuth(
    String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalFields,
  }) async {
    try {
      final file = await MultipartFile.fromFile(filePath);

      final formData = FormData.fromMap({
        fieldName: file,
        if (additionalFields != null) ...additionalFields,
      });

      final response = await _dioWithAuth.post(endpoint, data: formData);
      return response;
    } on DioException catch (e) {
      throw ApiFailure(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Upload file without authentication
  Future<Response> uploadFile(
    String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalFields,
  }) async {
    try {
      final file = await MultipartFile.fromFile(filePath);

      final formData = FormData.fromMap({
        fieldName: file,
        if (additionalFields != null) ...additionalFields,
      });

      final response = await _dio.post(endpoint, data: formData);
      return response;
    } on DioException catch (e) {
      throw ApiFailure(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ==================== ERROR HANDLING ====================

  /// Extract error message from various error formats
  String _extractErrorMessage(DioException error) {
    // Check response data for error message
    if (error.response?.data is Map) {
      final data = error.response?.data as Map<String, dynamic>;
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
      if (data.containsKey('error')) {
        return data['error'].toString();
      }
    }

    // Check Dio error message
    if (error.message != null && error.message!.isNotEmpty) {
      return error.message!;
    }

    // Default error messages based on status code
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. The server took too long to respond.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return _getErrorMessageForStatus(error.response?.statusCode ?? 0);
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.badCertificate:
        return 'Bad certificate error.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      case DioExceptionType.unknown:
        return 'An unknown error occurred.';
    }
  }

  /// Get user-friendly error message for HTTP status codes
  String _getErrorMessageForStatus(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'Forbidden. You do not have permission to access this resource.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. This resource already exists.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // ==================== UTILITIES ====================

  /// Check if token is still valid (not expired)
  Future<bool> isTokenValid() async {
    final token = await getStoredToken();
    return token != null && token.isNotEmpty;
  }

  /// Get current base URL
  String getBaseUrl() => baseUrl;

  /// Update base URL (for switching environments)
  void setBaseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
    _dioWithAuth.options.baseUrl = newUrl;
  }

  /// Clear all cached data
  Future<void> clearAll() async {
    await clearToken();
    _dio.close();
    _dioWithAuth.close();
    _initializeDio();
  }
}
