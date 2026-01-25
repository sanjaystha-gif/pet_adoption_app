import 'package:dio/dio.dart';
import 'package:pet_adoption_app/core/error/failure.dart';

class ApiClient {
  // For Android Emulator: use 10.0.2.2 (maps to host machine's localhost)
  // For physical device: use actual IP address of backend
  // For web/desktop: use localhost:5000
  static const String baseUrl = 'http://10.0.2.2:5000/api/v1';

  late Dio _dio;

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
