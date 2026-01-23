import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pet_adoption_app/data/models/pet_model.dart';
import 'package:pet_adoption_app/features/auth/presentation/notifiers/auth_notifier.dart';

class PetApiClient {
  final Dio dio;

  PetApiClient(this.dio);

  Future<List<PetModel>> getAllPets() async {
    try {
      final response = await dio.get('/items');
      if (response.statusCode == 200) {
        final List<dynamic> petsList =
            response.data['data'] ?? response.data ?? [];
        return petsList.map((pet) => PetModel.fromJson(pet)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<PetModel> getPetById(String petId) async {
    try {
      final response = await dio.get('/items/$petId');
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
      final response = await dio.get('/items', queryParameters: params);
      if (response.statusCode == 200) {
        final List<dynamic> petsList =
            response.data['data'] ?? response.data ?? [];
        return petsList.map((pet) => PetModel.fromJson(pet)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

final petApiClientProvider = Provider<PetApiClient>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PetApiClient(apiClient.dio);
});

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
    final pets = await petApiClient.getAllPets();
    return pets
        .where((pet) => pet.postedBy == 'admin' || pet.postedByName == 'admin')
        .toList();
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
