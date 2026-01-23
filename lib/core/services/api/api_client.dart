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
          // Debug logging
          print(
            '🔵 REQUEST: ${options.method} ${options.baseUrl}${options.path}',
          );
          print('   Headers: ${options.headers}');
          print('   Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Debug logging
          print(
            '🟢 RESPONSE: ${response.statusCode} from ${response.requestOptions.path}',
          );
          print('   Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          // Debug logging
          print('   ERROR: ${error.message}');
          print('   Type: ${error.type}');
          print('   Status Code: ${error.response?.statusCode}');
          print('   Response Data: ${error.response?.data}');
          print(
            '   Request URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}',
          );
          return handler.next(error);
        },
      ),
    );
  }

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
      print('🔴 DioException caught in POST $endpoint');
      print('   Message: ${e.message}');
      print('   Type: ${e.type}');
      print('   Status: ${e.response?.statusCode}');
      print('   Response Data: ${e.response?.data}');

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
      print('❌ Unexpected error in POST $endpoint: $e');
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
      print('🔴 DioException caught in GET $endpoint');
      print('   Message: ${e.message}');
      print('   Type: ${e.type}');
      print('   Status: ${e.response?.statusCode}');
      print('   Response Data: ${e.response?.data}');

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
      print('❌ Unexpected error in GET $endpoint: $e');
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
      print('🔴 DioException caught in PUT $endpoint');
      print('   Message: ${e.message}');
      print('   Type: ${e.type}');
      print('   Status: ${e.response?.statusCode}');
      print('   Response Data: ${e.response?.data}');

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
      print('❌ Unexpected error in PUT $endpoint: $e');
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
      print('🔴 DioException caught in DELETE $endpoint');
      print('   Message: ${e.message}');
      print('   Type: ${e.type}');
      print('   Status: ${e.response?.statusCode}');
      print('   Response Data: ${e.response?.data}');

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
      print('❌ Unexpected error in DELETE $endpoint: $e');
      rethrow;
    }
  }
}
