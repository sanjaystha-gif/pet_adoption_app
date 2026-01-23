import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/core/services/api/api_client.dart';
import 'package:pet_adoption_app/core/services/hive/hive_service.dart';
import '../notifiers/admin_auth_notifier.dart';

// Create singleton instances
final apiClientProvider = Provider((ref) => ApiClient());
final hiveServiceProvider = Provider((ref) => HiveService());

// Admin auth notifier provider
final adminAuthNotifierProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  return AdminAuthNotifier(apiClient: apiClient, hiveService: hiveService);
});
