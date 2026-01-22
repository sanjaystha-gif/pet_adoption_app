import 'package:dio/dio.dart';
import 'package:pet_adoption_app/core/error/failure.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:5000/api';
  // Change above to your actual backend URL
  // Example: 'https://your-api.com/api'

  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add interceptor for requests/responses
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('📤 REQUEST: ${options.method} ${options.path}');
          print('Headers: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '📥 RESPONSE: ${response.statusCode} from ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ ERROR: ${error.message}');
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
      throw ApiFailure(
        message: e.response?.data['message'] ?? e.message ?? 'API Error',
        statusCode: e.response?.statusCode,
      );
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
      throw ApiFailure(
        message: e.response?.data['message'] ?? e.message ?? 'API Error',
        statusCode: e.response?.statusCode,
      );
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
      throw ApiFailure(
        message: e.response?.data['message'] ?? e.message ?? 'API Error',
        statusCode: e.response?.statusCode,
      );
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
      throw ApiFailure(
        message: e.response?.data['message'] ?? e.message ?? 'API Error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
