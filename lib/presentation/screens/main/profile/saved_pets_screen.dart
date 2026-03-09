import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/presentation/providers/favorites_provider.dart';
import 'package:pet_adoption_app/presentation/screens/main/pet_details/pet_details_screen.dart';
import 'package:pet_adoption_app/presentation/widgets/smart_pet_image.dart';

class SavedPetsScreen extends ConsumerWidget {
  const SavedPetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedPetsAsync = ref.watch(favoritePetsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saved Pets',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Afacad',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF7F7F8),
      body: savedPetsAsync.when(
        data: (savedPets) {
          if (savedPets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Saved Pets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Afacad',
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start saving your favorite pets',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Afacad',
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: savedPets.length,
            itemBuilder: (context, index) {
              final pet = savedPets[index];
              return _SavedPetCard(
                pet: pet,
                onRemove: () async {
                  await ref
                      .read(favoritePetIdsProvider.notifier)
                      .removeFavorite(pet.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pet removed from saved'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            'Could not load saved pets',
            style: TextStyle(color: Colors.grey[600], fontFamily: 'Afacad'),
          ),
        ),
      ),
    );
  }
}

class _SavedPetCard extends StatelessWidget {
  final dynamic pet;
  final VoidCallback onRemove;

  const _SavedPetCard({required this.pet, required this.onRemove});

  String _resolveImageSource() {
    final candidates = <dynamic>[];

    if (pet is Map<String, dynamic>) {
      final map = pet as Map<String, dynamic>;
      candidates.addAll([
        map['imageUrl'],
        map['mediaUrl'],
        map['image'],
        map['photos'] is List && (map['photos'] as List).isNotEmpty
            ? (map['photos'] as List).first
            : null,
        map['media'] is List && (map['media'] as List).isNotEmpty
            ? (map['media'] as List).first
            : null,
      ]);
    } else {
      candidates.addAll([pet.imageUrl, pet.mediaUrl]);
    }

    candidates.add('main_logo.png');

    for (final candidate in candidates) {
      final value = (candidate ?? '').toString().trim();
      if (value.isNotEmpty) return value;
    }

    return 'main_logo.png';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => PetDetailsScreen(pet: pet)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pet Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SmartPetImage(
                imageSource: _resolveImageSource(),
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // Pet Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Afacad',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.age} years | ${pet.gender}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Afacad',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pet.breed,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontFamily: 'Afacad',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Remove Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.favorite,
                  color: Color(0xFFF67D2C),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
