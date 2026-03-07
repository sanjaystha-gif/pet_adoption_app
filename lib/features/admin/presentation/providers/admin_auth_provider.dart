import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/core/services/api/api_client.dart';
import 'package:pet_adoption_app/core/services/hive/hive_service.dart';
import 'package:pet_adoption_app/features/admin/presentation/notifiers/admin_auth_notifier.dart';
import 'package:pet_adoption_app/presentation/providers/api_providers.dart';

// Use shared instances from `api_providers.dart` to ensure tokens and auth state
// are consistent app-wide. Previously this file created its own ApiService/Hive
// providers which caused token persistence and navigation issues.
final apiClientProvider = Provider((ref) => ApiClient());

// Admin auth notifier provider uses the shared ApiService and HiveService
final adminAuthNotifierProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  return AdminAuthNotifier(
    apiClient: apiClient,
    hiveService: hiveService,
    apiService: apiService,
  );
});
