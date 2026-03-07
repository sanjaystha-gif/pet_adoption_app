import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:pet_adoption_app/core/services/hive/hive_service.dart';
import 'package:pet_adoption_app/data/models/pet_model.dart';
import 'package:pet_adoption_app/presentation/providers/pet_provider.dart';

const String _favoritesBoxName = 'favorites_box';

class FavoritePetIdsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    return _load();
  }

  Future<void> toggleFavorite(String petId) async {
    if (petId.trim().isEmpty) {
      return;
    }

    final current = state.asData?.value ?? <String>{};
    final updated = Set<String>.from(current);

    if (updated.contains(petId)) {
      updated.remove(petId);
    } else {
      updated.add(petId);
    }

    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> removeFavorite(String petId) async {
    final current = state.asData?.value ?? <String>{};
    if (!current.contains(petId)) {
      return;
    }

    final updated = Set<String>.from(current)..remove(petId);
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<Set<String>> _load() async {
    final box = await Hive.openBox(_favoritesBoxName);
    final key = await _keyForCurrentUser();
    final raw = box.get(key, defaultValue: <dynamic>[]);

    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toSet();
    }

    return <String>{};
  }

  Future<void> _save(Set<String> favoriteIds) async {
    final box = await Hive.openBox(_favoritesBoxName);
    final key = await _keyForCurrentUser();
    await box.put(key, favoriteIds.toList(growable: false));
  }

  Future<String> _keyForCurrentUser() async {
    final hiveService = ref.read(hiveServiceProvider);
    final auth = await hiveService.getAuthData();
    final authId = (auth?.authId ?? '').trim();

    if (authId.isEmpty) {
      return 'favorite_pet_ids_guest';
    }

    return 'favorite_pet_ids_$authId';
  }
}

final favoritePetIdsProvider =
    AsyncNotifierProvider<FavoritePetIdsNotifier, Set<String>>(
      FavoritePetIdsNotifier.new,
    );

final isPetFavoriteProvider = Provider.family<bool, String>((ref, petId) {
  final favorites = ref.watch(favoritePetIdsProvider);
  return favorites.maybeWhen(
    data: (ids) => ids.contains(petId),
    orElse: () => false,
  );
});

final favoritePetsProvider = FutureProvider<List<PetModel>>((ref) async {
  final favoriteIds = await ref.watch(favoritePetIdsProvider.future);
  if (favoriteIds.isEmpty) {
    return [];
  }

  final pets = await ref.watch(allPetsProvider.future);
  return pets.where((pet) => favoriteIds.contains(pet.id)).toList();
});
