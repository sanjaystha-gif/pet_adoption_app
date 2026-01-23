import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Debug widget to test API connectivity
/// Run this to verify backend is accessible
class ApiDebugTest extends StatefulWidget {
  const ApiDebugTest({super.key});

  @override
  State<ApiDebugTest> createState() => _ApiDebugTestState();
}

class _ApiDebugTestState extends State<ApiDebugTest> {
  String testResult = 'Not tested yet';
  bool isLoading = false;

  Future<void> testApiConnectivity() async {
    setState(() {
      isLoading = true;
      testResult = 'Testing...';
    });

    try {
      // Test 1: Basic connectivity to base URL
      final dio = Dio();
      try {
        await dio.get(
          'http://localhost:5000',
          options: Options(
            validateStatus: (status) => status != null && status < 500,
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
      } catch (e) {
        throw Exception(
          'Cannot reach http://localhost:5000 - Backend server not running?',
        );
      }

      // Test 2: API endpoint connectivity
      try {
        final response = await dio.post(
          'http://localhost:5000/api/v1/auth/login',
          data: {'email': 'test@test.com', 'password': 'test'},
          options: Options(
            validateStatus: (status) => true,
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        setState(() {
          testResult =
              '''
API Connection Status: ✅ SUCCESS
- Base URL: http://localhost:5000 ✓
- /api/v1 path: Accessible
- /auth/login endpoint: Status ${response.statusCode}
- Response Type: ${response.data.runtimeType}
- Response: ${response.data}
          ''';
        });
      } catch (e) {
        setState(() {
          testResult = 'API endpoint error: $e';
        });
      }
    } catch (e) {
      setState(() {
        testResult =
            'Connection Error:\n$e\n\nMake sure your backend is running on http://localhost:5000';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Debug Test')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: isLoading ? null : testApiConnectivity,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Test API Connectivity'),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    testResult,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
