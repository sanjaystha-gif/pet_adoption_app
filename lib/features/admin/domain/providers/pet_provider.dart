import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a pet model
class Pet {
  final String id;
  final String name;
  final String breed;
  final String age;
  final String? image;
  final String? description;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    this.image,
    this.description,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'breed': breed,
    'age': age,
    'image': image,
    'description': description,
  };

  factory Pet.fromMap(Map<String, dynamic> map) => Pet(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    breed: map['breed'] ?? '',
    age: map['age'] ?? '',
    image: map['image'],
    description: map['description'],
  );
}

/// Pet list notifier - manages pets list with real-time updates
class PetListNotifier extends StateNotifier<List<Pet>> {
  PetListNotifier() : super([]);

  /// Add a new pet
  void addPet(Pet pet) {
    state = [...state, pet];
  }

  /// Update an existing pet
  void updatePet(String petId, Pet updatedPet) {
    state = [
      for (final pet in state)
        if (pet.id == petId) updatedPet else pet,
    ];
  }

  /// Delete a pet
  void deletePet(String petId) {
    state = state.where((pet) => pet.id != petId).toList();
  }

  /// Set all pets (for fetching from backend)
  void setPets(List<Pet> pets) {
    state = pets;
  }

  /// Clear all pets
  void clearPets() {
    state = [];
  }
}

/// Provider for pet list
final petListProvider = StateNotifierProvider<PetListNotifier, List<Pet>>((
  ref,
) {
  return PetListNotifier();
});
