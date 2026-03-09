import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/presentation/providers/pet_provider.dart';
import 'package:pet_adoption_app/presentation/providers/api_providers.dart';
import 'package:pet_adoption_app/presentation/screens/admin/pets/admin_add_pet_screen.dart';
import 'package:pet_adoption_app/presentation/screens/admin/pets/admin_edit_pet_screen.dart';
import 'package:pet_adoption_app/presentation/widgets/smart_pet_image.dart';

class AdminPetsListScreen extends ConsumerStatefulWidget {
  const AdminPetsListScreen({super.key});

  @override
  ConsumerState<AdminPetsListScreen> createState() =>
      _AdminPetsListScreenState();
}

class _AdminPetsListScreenState extends ConsumerState<AdminPetsListScreen> {
  Future<void> _deleteAllDeletablePets() async {
    final pets = await ref.read(adminPetsNotifierProvider.future);

    if (!mounted) return;

    if (pets.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No pets found to delete')));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete All Pets'),
        content: Text(
          'This will try to delete ${pets.length} pets from backend. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final petService = ref.read(petServiceProvider);
    int deleted = 0;
    int denied = 0;
    int failed = 0;

    for (final pet in pets) {
      final petId = pet.id.trim();
      if (petId.isEmpty || petId.toLowerCase() == 'null') {
        failed++;
        continue;
      }

      try {
        await petService.deletePet(petId: petId);
        deleted++;
      } catch (e) {
        final message = e.toString();
        if (message.contains('403')) {
          denied++;
        } else {
          failed++;
        }
      }
    }

    ref.invalidate(adminPetsNotifierProvider);
    final _ = await ref.refresh(adminPetsNotifierProvider.future);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Deleted: $deleted, Permission denied: $denied, Failed: $failed',
        ),
        backgroundColor: failed == 0 ? Colors.green : Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the admin pets notifier provider for real-time updates
    final petsAsyncValue = ref.watch(adminPetsNotifierProvider);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      final result = await navigator.push(
                        MaterialPageRoute(
                          builder: (_) => const AdminAddPetScreen(),
                        ),
                      );
                      if (!mounted) return;
                      if (result != null && result['success'] == true) {
                        ref.invalidate(adminPetsNotifierProvider);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Pet added and saved to database!'),
                            backgroundColor: Colors.green,
                          ),
                        );
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
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _deleteAllDeletablePets,
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Delete All'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
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
                          'image': petModel.mediaUrl.isNotEmpty
                              ? petModel.mediaUrl
                              : 'pet_placeholder.png',
                          'description': petModel.description,
                          'type': petModel.type,
                          'isAdopted': petModel.isAdopted,
                          'category': petModel.category,
                          'location': petModel.location,
                          'mediaUrl': petModel.mediaUrl,
                          'mediaType': petModel.mediaType,
                          'size': petModel.size,
                          'healthStatus': petModel.healthStatus,
                        };
                        return _PetListCard(
                          pet: pet,
                          ref: ref,
                          onEdit: () async {
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            final result = await navigator.push(
                              MaterialPageRoute(
                                builder: (_) => AdminEditPetScreen(pet: pet),
                              ),
                            );
                            if (!mounted) return;
                            // If edit was successful, refresh providers
                            if (result != null && result['success'] == true) {
                              ref.invalidate(adminPetsNotifierProvider);

                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Pet updated successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
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
                        ref.invalidate(adminPetsNotifierProvider);
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

class _PetListCard extends ConsumerWidget {
  final Map<String, dynamic> pet;
  final VoidCallback onEdit;
  final WidgetRef ref;

  const _PetListCard({
    required this.pet,
    required this.onEdit,
    required this.ref,
  });

  Future<void> _deletePet(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Pet',
            style: TextStyle(fontFamily: 'Afacad', fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete ${pet['name']}? This action cannot be undone.',
            style: const TextStyle(fontFamily: 'Afacad'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Afacad'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Afacad',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final petService = ref.read(petServiceProvider);
      final petId = (pet['id'] ?? pet['_id'] ?? '').toString().trim();

      if (petId.isEmpty || petId.toLowerCase() == 'null') {
        throw Exception('Invalid pet ID for deletion');
      }

      // Delete from API first
      await petService.deletePet(petId: petId);

      // Ensure backend has fully processed the deletion
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!context.mounted) return;

      // IMPORTANT: Only invalidate the admin provider, NOT the API client provider
      // The API client is a singleton and shouldn't be invalidated

      // Invalidate the admin pets provider to force a new fetch
      ref.invalidate(adminPetsNotifierProvider);

      // Now refresh to get fresh data (value intentionally captured)
      final _ = await ref.refresh(adminPetsNotifierProvider.future);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      // Show detailed error message based on error type
      String errorMsg = e.toString();
      String errorTitle = 'Deletion Failed';

      if (errorMsg.contains('401')) {
        errorMsg =
            'Your session has expired. Please log in again to delete this pet.';
        errorTitle = 'Not Authenticated';
      } else if (errorMsg.contains('403')) {
        errorMsg =
            'This pet was created by another user. Only the original creator or a super admin can delete it.';
        errorTitle = 'Permission Denied';
      } else if (errorMsg.contains('404')) {
        errorMsg = 'This pet no longer exists.';
        errorTitle = 'Pet Not Found';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                errorTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(errorMsg),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  String _resolveStatus() {
    final rawType = (pet['type'] ?? '').toString().trim().toLowerCase();
    final isAdopted =
        (pet['isAdopted'] == true) ||
        (pet['isClaimed'] == true) ||
        (pet['claimedBy'] != null && pet['claimedBy'].toString().isNotEmpty);

    if (isAdopted || rawType == 'booked' || rawType == 'adopted') {
      return 'Booked';
    }

    if (rawType == 'pending' || rawType == 'reserved') {
      return 'Pending';
    }

    return 'Available';
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'Booked':
        return const Color(0xFFFDEDEC);
      case 'Pending':
        return const Color(0xFFFFF6E8);
      default:
        return const Color(0xFFEAF7EE);
    }
  }

  Color _statusFg(String status) {
    switch (status) {
      case 'Booked':
        return const Color(0xFFC0392B);
      case 'Pending':
        return const Color(0xFFD68910);
      default:
        return const Color(0xFF1E8449);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = _resolveStatus();

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SmartPetImage(
                imageSource: pet['image'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
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
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBg(status),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _statusFg(status),
                        fontFamily: 'Afacad',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(onTap: onEdit, child: const Text('Edit')),
                PopupMenuItem(
                  onTap: () => _deletePet(context),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
