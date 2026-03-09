import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_adoption_app/core/services/permission/permission_service.dart';
import 'package:pet_adoption_app/core/services/camera_service.dart';
import 'package:pet_adoption_app/presentation/providers/api_providers.dart';
import 'dart:io';
import 'package:pet_adoption_app/presentation/providers/pet_provider.dart';

class AdminEditPetScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> pet;

  const AdminEditPetScreen({super.key, required this.pet});

  @override
  ConsumerState<AdminEditPetScreen> createState() => _AdminEditPetScreenState();
}

class _AdminEditPetScreenState extends ConsumerState<AdminEditPetScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String _selectedCategory = 'Dog'; // Default value
  String _selectedBreed = 'Golden Retriever'; // Default value
  String _selectedAge = 'Puppy'; // Default value
  String _selectedGender = 'Male'; // Default value
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _categories = ['Dog', 'Cat'];
  final List<String> _ages = ['Puppy', 'Young', 'Adult', 'Senior'];
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _dogBreeds = [
    'Golden Retriever',
    'Labrador Retriever',
    'German Shepherd',
    'Bulldog',
    'Beagle',
    'Poodle',
    'Rottweiler',
    'Yorkshire Terrier',
    'Boxer',
    'Dachshund',
    'Siberian Husky',
    'Shih Tzu',
    'Doberman',
    'Chihuahua',
    'Pomeranian',
    'Corgi',
    'Pug',
    'Mixed Breed',
    'Other',
  ];

  final List<String> _catBreeds = [
    'Persian',
    'Siamese',
    'Maine Coon',
    'Ragdoll',
    'British Shorthair',
    'Bengal',
    'Sphynx',
    'Abyssinian',
    'Scottish Fold',
    'Domestic Shorthair',
    'Mixed Breed',
    'Other',
  ];

  List<String> get _breedsForCategory =>
      _selectedCategory == 'Cat' ? _catBreeds : _dogBreeds;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet['name']);
    _descriptionController = TextEditingController(
      text: widget.pet['description'] ?? '',
    );

    final speciesFromBackend = (widget.pet['species'] ?? '')
        .toString()
        .toLowerCase()
        .trim();
    _selectedCategory = speciesFromBackend == 'cat' ? 'Cat' : 'Dog';

    // Set breed from pet data
    final breedFromBackend =
        widget.pet['breed']?.toString() ?? 'Golden Retriever';
    _selectedBreed = _breedsForCategory.contains(breedFromBackend)
        ? breedFromBackend
        : _breedsForCategory.first;

    // Convert numeric age to category string
    final petAge = widget.pet['age'];

    final convertedAge = _getCategoryFromAge(
      petAge is int ? petAge : int.tryParse(petAge.toString()) ?? 0,
    );

    // Ensure the converted age is in the dropdown list
    _selectedAge = _ages.contains(convertedAge) ? convertedAge : 'Puppy';

    // Ensure gender is capitalized
    final genderFromBackend = (widget.pet['gender'] ?? 'Male').toString();
    _selectedGender =
        genderFromBackend[0].toUpperCase() +
        genderFromBackend.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFF67D2C);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Edit Pet',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Afacad',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Name
            Text(
              'Pet Name',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Afacad',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter pet name',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Afacad',
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category
            Text(
              'Category',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Afacad',
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(fontFamily: 'Afacad'),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                    final newBreeds = _breedsForCategory;
                    if (!newBreeds.contains(_selectedBreed)) {
                      _selectedBreed = newBreeds.first;
                    }
                  });
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Breed
            Text(
              'Breed',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Afacad',
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedBreed,
              items: _breedsForCategory
                  .map(
                    (breed) => DropdownMenuItem(
                      value: breed,
                      child: Text(
                        breed,
                        style: const TextStyle(fontFamily: 'Afacad'),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedBreed = value);
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Age and Gender Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Age',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Afacad',
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue:
                            (_selectedAge.isEmpty ||
                                !_ages.contains(_selectedAge))
                            ? 'Puppy'
                            : _selectedAge,
                        items: _ages
                            .map(
                              (age) => DropdownMenuItem(
                                value: age,
                                child: Text(age),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedAge = value);
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gender',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Afacad',
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        items: _genders
                            .map(
                              (gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedGender = value);
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'Description',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Afacad',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter pet description',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Afacad',
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Pet Image
            Text(
              'Pet Image',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Afacad',
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to upload pet image',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontFamily: 'Afacad',
                            ),
                          ),
                          Text(
                            'Or keep the current image',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontFamily: 'Afacad',
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Afacad',
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _resolveCategoryId() async {
    final normalizedSelected = _selectedCategory.toLowerCase().trim();

    final categoryService = ref.read(categoryServiceProvider);
    final categories = await categoryService.getAllCategories();

    bool nameMatches(String name) {
      final normalizedName = name.toLowerCase().trim();
      if (normalizedSelected == 'dog') {
        return normalizedName == 'dog' ||
            normalizedName == 'dogs' ||
            normalizedName.contains('dog') ||
            normalizedName.contains('canine');
      }
      if (normalizedSelected == 'cat') {
        return normalizedName == 'cat' ||
            normalizedName == 'cats' ||
            normalizedName.contains('cat') ||
            normalizedName.contains('feline');
      }
      return normalizedName == normalizedSelected;
    }

    for (final category in categories) {
      if (nameMatches(category.name) && category.id.isNotEmpty) {
        return category.id;
      }
    }

    if (normalizedSelected == 'dog') {
      return '6973651cd96b87a44687ca13';
    }

    throw Exception(
      'Category "${_selectedCategory}" not found in backend. Please create it in backend categories first.',
    );
  }

  Future<void> _pickImage() async {
    const orange = Color(0xFFF67D2C);

    // Show dialog to choose between camera and gallery
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Update Pet Photo',
            style: TextStyle(fontFamily: 'Afacad', fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Choose how you want to update the pet photo',
            style: TextStyle(fontFamily: 'Afacad'),
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Afacad', color: Colors.grey),
              ),
            ),
            // Gallery button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
              icon: const Icon(Icons.photo_library),
              label: const Text(
                'Gallery',
                style: TextStyle(fontFamily: 'Afacad'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            // Camera button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                'Camera',
                style: TextStyle(fontFamily: 'Afacad'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Pick image from device camera
  Future<void> _pickFromCamera() async {
    try {
      final cameraService = CameraService();

      debugPrint('[Camera] AdminEditPet: Requesting camera...');
      final pickedFile = await cameraService.takePicture();

      if (pickedFile != null) {
        if (!mounted) return;
        setState(() {
          _selectedImage = pickedFile;
        });
        debugPrint(
          '[Success] AdminEditPet: Camera photo selected: ${pickedFile.path}',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo captured! Ready to update.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        debugPrint('[Error] AdminEditPet: Camera error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Pick image from device gallery
  Future<void> _pickFromGallery() async {
    try {
      final status = await PermissionService.requestPhotos();
      if (!mounted) return;

      if (!PermissionService.isGranted(status)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo permission required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      debugPrint('📷 AdminEditPet: Picking from gallery...');
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        if (!mounted) return;
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        debugPrint(
          '[Success] AdminEditPet: Gallery photo selected: ${pickedFile.path}',
        );
      }
    } catch (e) {
      if (mounted) {
        debugPrint('[Error] AdminEditPet: Gallery error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      final petService = ref.read(petServiceProvider);
      final petId = widget.pet['id'] ?? widget.pet['_id'];

      if (petId == null) {
        throw Exception('Pet ID not found');
      }

      // If image changed, upload it first
      String mediaUrlToSend = widget.pet['mediaUrl'] ?? 'main_logo.png';
      if (_selectedImage != null) {
        debugPrint(
          '📷 AdminEditPet: Uploading new image: ${_selectedImage!.path}',
        );
        mediaUrlToSend = await petService.uploadPhoto(
          filePath: _selectedImage!.path,
        );
        debugPrint(
          '📷 AdminEditPet: Image uploaded successfully: $mediaUrlToSend',
        );
      } else {
        debugPrint(
          '[Upload] AdminEditPet: No new image, keeping existing: $mediaUrlToSend',
        );
      }

      debugPrint(
        '[Pet] AdminEditPet: Updating pet $petId with mediaUrl: $mediaUrlToSend',
      );

      final categoryId = await _resolveCategoryId();
      final species = _selectedCategory.toLowerCase();

      // Call backend to update pet
      await petService.updatePet(
        petId: petId.toString(),
        name: _nameController.text,
        breed: _selectedBreed,
        description: _descriptionController.text,
        age: _getAgeFromCategory(_selectedAge), // Convert category to age
        gender: _selectedGender,
        species: species,
        type: widget.pet['type'] ?? 'available',
        categoryId: categoryId,
        location: widget.pet['location'] ?? 'Kathmandu',
        mediaUrl: mediaUrlToSend,
        mediaType: widget.pet['mediaType'] ?? 'photo',
      );

      debugPrint('[Success] AdminEditPet: Pet updated successfully!');

      // Refresh the admin pets list by invalidating the provider
      ref.invalidate(adminPetsNotifierProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Return success to previous screen
      Navigator.pop(context, {'success': true});
    } catch (e) {
      debugPrint('[Error] AdminEditPet: Error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Convert numeric age to age category
  String _getCategoryFromAge(int age) {
    // Match the exact ages returned by backend
    switch (age) {
      case 1:
        return 'Puppy';
      case 3:
        return 'Young';
      case 5:
        return 'Adult';
      case 10:
        return 'Senior';
      default:
        // If age doesn't match exactly, find closest match
        if (age <= 1) return 'Puppy';
        if (age <= 3) return 'Young';
        if (age <= 5) return 'Adult';
        return 'Senior';
    }
  }

  /// Convert age category to numeric age
  int _getAgeFromCategory(String category) {
    switch (category) {
      case 'Puppy':
        return 1;
      case 'Young':
        return 3;
      case 'Adult':
        return 5;
      case 'Senior':
        return 10;
      default:
        return 0;
    }
  }
}
