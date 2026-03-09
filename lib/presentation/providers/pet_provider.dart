import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/data/models/pet_model.dart';
import 'package:pet_adoption_app/core/services/api/api_service.dart';
import 'package:pet_adoption_app/presentation/providers/api_providers.dart';

class PetApiClient {
  final ApiService apiService;

  PetApiClient(this.apiService);

  Future<List<PetModel>> getAllPets() async {
    try {
      const endpoint = '/items';
      final queryParameters = {'feed': 'adoption'};
      final requestedUrl =
          '${ApiService.baseUrl}$endpoint?feed=${queryParameters['feed']}';

      // ignore: avoid_print
      print('[AdopterPets] URL requested: $requestedUrl');

      dynamic response;
      try {
        response = await apiService.dio.get(
          endpoint,
          queryParameters: queryParameters,
        );
      } catch (e) {
        // Fallback to public client in case auth token is missing/expired.
        // ignore: avoid_print
        print('[AdopterPets] Auth GET failed, retrying public GET: $e');
        response = await apiService.get(
          endpoint,
          queryParameters: queryParameters,
        );
      }

      // ignore: avoid_print
      print('[AdopterPets] Status code: ${response.statusCode}');

      final rawBody = response.data.toString();
      final preview = rawBody.length > 500
          ? '${rawBody.substring(0, 500)}...'
          : rawBody;
      // ignore: avoid_print
      print('[AdopterPets] Raw response (first 500 chars): $preview');

      if (response.statusCode == 200) {
        final dynamic body = response.data;
        dynamic dataNode;
        if (body is Map) {
          dataNode = body['data'];
          if (dataNode is Map) {
            dataNode =
                dataNode['items'] ??
                dataNode['docs'] ??
                dataNode['results'] ??
                dataNode['pets'];
          }
        } else {
          dataNode = body;
        }

        final List<dynamic> petsList = dataNode is List
            ? dataNode
            : <dynamic>[];

        // ignore: avoid_print
        print('[AdopterPets] Parsed list length: ${petsList.length}');

        final parsedPets = petsList.map((pet) {
          try {
            return PetModel.fromJson(Map<String, dynamic>.from(pet as Map));
          } catch (e) {
            rethrow;
          }
        }).toList();

        return parsedPets;
      }

      return [];
    } catch (e) {
      // ignore: avoid_print
      print('[AdopterPets] getAllPets error: $e');
      return [];
    }
  }

  Future<PetModel> getPetById(String petId) async {
    try {
      final response = await apiService.dio.get('/items/$petId');
      if (response.statusCode == 200) {
        return PetModel.fromJson(response.data['data'] ?? response.data);
      }
      throw Exception('Failed to fetch pet');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PetModel>> getPetsByFilter({
    String? type,
    String? category,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final params = {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
        if (category != null) 'category': category,
      };
      final response = await apiService.dio.get(
        '/items',
        queryParameters: params,
      );
      if (response.statusCode == 200) {
        final List<dynamic> petsList =
            response.data['data'] ?? response.data ?? [];
        return petsList
            .map((pet) => PetModel.fromJson(pet as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

final petApiClientProvider = Provider<PetApiClient>((ref) {
  // Use the shared ApiService instance from api_providers
  final apiService = ref.watch(apiServiceProvider);
  return PetApiClient(apiService);
});

// Use adminUpdatedPetsProvider as the main provider for admin pets
// This will be used in the admin pets list screen
final adminPetsNotifierProvider = adminUpdatedPetsProvider;

final allPetsProvider = FutureProvider<List<PetModel>>((ref) async {
  final petApiClient = ref.watch(petApiClientProvider);
  try {
    return await petApiClient.getAllPets();
  } catch (e) {
    return [];
  }
});

final adminUpdatedPetsProvider = FutureProvider<List<PetModel>>((ref) async {
  final petApiClient = ref.watch(petApiClientProvider);
  try {
    // Get pets - will use cache if available
    final pets = await petApiClient.getAllPets();

    // For admin: Show ALL pets (they manage all pets)
    return pets;
  } catch (e) {
    // Return empty list instead of rethrowing to prevent infinite loading
    return [];
  }
});

final userPetsProvider = FutureProvider<List<PetModel>>((ref) async {
  final petApiClient = ref.watch(petApiClientProvider);
  try {
    return await petApiClient.getAllPets();
  } catch (e) {
    return [];
  }
});

final petDetailsProvider = FutureProvider.family<PetModel, String>((
  ref,
  petId,
) async {
  final petApiClient = ref.watch(petApiClientProvider);
  try {
    return await petApiClient.getPetById(petId);
  } catch (e) {
    rethrow;
  }
});

final refreshAllPetsProvider = FutureProvider<List<PetModel>>((ref) async {
  ref.invalidate(allPetsProvider);
  return ref
      .watch(allPetsProvider)
      .when(
        data: (pets) => pets,
        loading: () => [],
        error: (error, stack) => [],
      );
});

final refreshAdminPetsProvider = FutureProvider<List<PetModel>>((ref) async {
  ref.invalidate(adminUpdatedPetsProvider);
  return ref
      .watch(adminUpdatedPetsProvider)
      .when(
        data: (pets) => pets,
        loading: () => [],
        error: (error, stack) => [],
      );
});
