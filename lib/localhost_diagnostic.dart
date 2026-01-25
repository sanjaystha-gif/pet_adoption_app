// Quick diagnostic utility to test different localhost variants
// Use this to find which localhost format works for your setup

import 'package:dio/dio.dart';

void testLocalhost() async {
  final variants = [
    'http://localhost:5000/api/v1/auth/login',
    'http://127.0.0.1:5000/api/v1/auth/login',
    'http://10.0.2.2:5000/api/v1/auth/login', // Android emulator
  ];

  final dio = Dio();
  final testData = {'email': 'test@test.com', 'password': 'test'};

  for (final url in variants) {
    try {
      await dio.post(
        url,
        data: testData,
        options: Options(
          validateStatus: (status) => true,
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      // Handle error silently
    }
  }
}

// Add this call to main() temporarily for testing
// Then remove it
