import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/presentation/providers/pet_provider.dart';
import 'package:pet_adoption_app/presentation/screens/admin/pets/admin_add_pet_screen.dart';
import 'package:pet_adoption_app/presentation/screens/admin/pets/admin_edit_pet_screen.dart';

class AdminPetsListScreen extends ConsumerStatefulWidget {
  const AdminPetsListScreen({super.key});

  @override
  ConsumerState<AdminPetsListScreen> createState() =>
      _AdminPetsListScreenState();
}

class _AdminPetsListScreenState extends ConsumerState<AdminPetsListScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch the admin updated pets provider to get real-time updates
    final petsAsyncValue = ref.watch(adminUpdatedPetsProvider);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminAddPetScreen(),
                    ),
                  );
                  if (result != null && mounted) {
                    // If successful add to backend
                    if (result['success'] == true) {
                      // Invalidate providers to refresh from backend
                      ref.invalidate(allPetsProvider);
                      ref.invalidate(adminUpdatedPetsProvider);
                      ref.invalidate(userPetsProvider);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pet added and saved to database!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Pet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF67D2C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: petsAsyncValue.when(
              data: (pets) => pets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pets, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No pets added yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontFamily: 'Afacad',
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final petModel = pets[index];
                        // Convert PetModel to Map for compatibility
                        final pet = {
                          '_id': petModel.id,
                          'id': petModel.id,
                          'name': petModel.name,
                          'breed': petModel.breed,
                          'age': petModel.age,
                          'gender': petModel.gender,
                          'image': petModel.mediaUrl ?? 'pet_placeholder.png',
                          'description': petModel.description,
                          'type': petModel.type,
                          'category': petModel.category,
                          'location': petModel.location,
                          'mediaUrl': petModel.mediaUrl,
                          'mediaType': petModel.mediaType,
                          'size': petModel.size,
                          'healthStatus': petModel.healthStatus,
                        };
                        return _PetListCard(
                          pet: pet,
                          onEdit: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AdminEditPetScreen(pet: pet),
                              ),
                            );
                            if (result != null && mounted) {
                              // If edit was successful, refresh providers
                              if (result['success'] == true) {
                                ref.invalidate(allPetsProvider);
                                ref.invalidate(adminUpdatedPetsProvider);
                                ref.invalidate(userPetsProvider);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pet updated successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading pets: $error',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[600],
                        fontFamily: 'Afacad',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.invalidate(adminUpdatedPetsProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PetListCard extends StatelessWidget {
  final Map<String, dynamic> pet;
  final VoidCallback onEdit;

  const _PetListCard({required this.pet, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/${pet['image']}',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.pets),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Afacad',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pet['breed']} • ${pet['age']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'Afacad',
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(onTap: onEdit, child: const Text('Edit')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
