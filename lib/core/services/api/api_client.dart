import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pet_adoption_app/core/error/failure.dart';

class ApiClient {
  static const String _apiBaseUrlFromEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static final String baseUrl = _apiBaseUrlFromEnv.isNotEmpty
      ? _apiBaseUrlFromEnv
      : _resolveDefaultBaseUrl();

  late Dio _dio;

  static String _resolveDefaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:5000/api/v1';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:5000/api/v1';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://localhost:5000/api/v1';
    }
  }

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor for requests/responses
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  /// Get the Dio instance
  Dio get dio => _dio;

  /// Perform POST request
  Future<Response> post(
    String endpoint, {
    required Map<String, dynamic> data,
    String? token,
  }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      final response = await _dio.post(endpoint, data: data, options: options);

      return response;
    } on DioException catch (e) {
      String errorMessage = 'API Error';

      // Try to extract error message from response
      if (e.response?.data is Map) {
        errorMessage =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            e.message ??
            'API Error';
      } else if (e.response?.data is String) {
        errorMessage = e.response?.data ?? e.message ?? 'API Error';
      } else {
        errorMessage = e.message ?? 'Unknown error';
      }

      throw ApiFailure(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Perform GET request
  Future<Response> get(String endpoint, {String? token}) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      final response = await _dio.get(endpoint, options: options);

      return response;
    } on DioException catch (e) {
      String errorMessage = 'API Error';

      if (e.response?.data is Map) {
        errorMessage =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            e.message ??
            'API Error';
      } else if (e.response?.data is String) {
        errorMessage = e.response?.data ?? e.message ?? 'API Error';
      } else {
        errorMessage = e.message ?? 'Unknown error';
      }

      throw ApiFailure(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Perform PUT request
  Future<Response> put(
    String endpoint, {
    required Map<String, dynamic> data,
    String? token,
  }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      final response = await _dio.put(endpoint, data: data, options: options);

      return response;
    } on DioException catch (e) {
      String errorMessage = 'API Error';

      if (e.response?.data is Map) {
        errorMessage =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            e.message ??
            'API Error';
      } else if (e.response?.data is String) {
        errorMessage = e.response?.data ?? e.message ?? 'API Error';
      } else {
        errorMessage = e.message ?? 'Unknown error';
      }

      throw ApiFailure(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Perform DELETE request
  Future<Response> delete(String endpoint, {String? token}) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      final response = await _dio.delete(endpoint, options: options);

      return response;
    } on DioException catch (e) {
      String errorMessage = 'API Error';

      if (e.response?.data is Map) {
        errorMessage =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            e.message ??
            'API Error';
      } else if (e.response?.data is String) {
        errorMessage = e.response?.data ?? e.message ?? 'API Error';
      } else {
        errorMessage = e.message ?? 'Unknown error';
      }

      throw ApiFailure(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }
}
