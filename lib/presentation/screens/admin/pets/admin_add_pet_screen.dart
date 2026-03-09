import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_adoption_app/core/services/permission/permission_service.dart';
import 'package:pet_adoption_app/core/services/camera_service.dart';
import 'package:pet_adoption_app/presentation/providers/api_providers.dart';
import 'package:pet_adoption_app/core/services/hive/hive_service.dart';
import 'dart:io';
import 'package:pet_adoption_app/presentation/providers/pet_provider.dart';

class AdminAddPetScreen extends ConsumerStatefulWidget {
  const AdminAddPetScreen({super.key});

  @override
  ConsumerState<AdminAddPetScreen> createState() => _AdminAddPetScreenState();
}

class _AdminAddPetScreenState extends ConsumerState<AdminAddPetScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Dog';
  String _selectedBreed = 'Golden Retriever';
  String _selectedAge = 'Puppy';
  String _selectedGender = 'Male';
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
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFF67D2C);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Add New Pet',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Afacad',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Upload Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.photo_camera, color: orange, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Pet Photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Afacad',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: orange.withValues(alpha: 0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: orange.withValues(alpha: 0.05),
                        ),
                        child: _selectedImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed: _pickImage,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 64,
                                    color: orange,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tap to upload pet photo',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Afacad',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Recommended: Square image, min 500x500px',
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pet Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.pets, color: orange, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Pet Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Afacad',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Pet Name
                    _buildLabel('Pet Name', Icons.badge),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: _buildInputDecoration(
                        'e.g., Max, Bella, Charlie',
                      ),
                      style: const TextStyle(fontFamily: 'Afacad'),
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    _buildLabel('Category', Icons.pets),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
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
                      decoration: _buildInputDecoration('Select category'),
                      icon: Icon(Icons.arrow_drop_down, color: orange),
                    ),
                    const SizedBox(height: 16),

                    // Breed Dropdown
                    _buildLabel('Breed', Icons.category),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBreed,
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
                      decoration: _buildInputDecoration('Select breed'),
                      icon: Icon(Icons.arrow_drop_down, color: orange),
                    ),
                    const SizedBox(height: 16),

                    // Age and Gender Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Age', Icons.cake),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedAge,
                                items: _ages
                                    .map(
                                      (age) => DropdownMenuItem(
                                        value: age,
                                        child: Text(
                                          age,
                                          style: const TextStyle(
                                            fontFamily: 'Afacad',
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedAge = value);
                                  }
                                },
                                decoration: _buildInputDecoration('Select'),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: orange,
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
                              _buildLabel('Gender', Icons.male),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedGender,
                                items: _genders
                                    .map(
                                      (gender) => DropdownMenuItem(
                                        value: gender,
                                        child: Text(
                                          gender,
                                          style: const TextStyle(
                                            fontFamily: 'Afacad',
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedGender = value);
                                  }
                                },
                                decoration: _buildInputDecoration('Select'),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildLabel('Description', Icons.description),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: _buildInputDecoration(
                        'Tell us about this pet\'s personality, habits, or special needs...',
                      ),
                      style: const TextStyle(fontFamily: 'Afacad'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addPetToBackend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: orange.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle_outline, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Add Pet to Database',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Afacad',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<String> _resolveCategoryId() async {
    final normalizedSelected = _selectedCategory.toLowerCase().trim();

    final categoryService = ref.read(categoryServiceProvider);
    final categories = await categoryService.getAllCategories();

    bool _nameMatches(String name) {
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
      if (_nameMatches(category.name) && category.id.isNotEmpty) {
        return category.id;
      }
    }

    // Keep previous dog fallback to avoid blocking when backend categories drift.
    if (normalizedSelected == 'dog') {
      return '6973651cd96b87a44687ca13';
    }

    throw Exception(
      'Category "${_selectedCategory}" not found in backend. Please create it in backend categories first.',
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
            fontFamily: 'Afacad',
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontFamily: 'Afacad',
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF67D2C), width: 2),
      ),
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
            'Select Image Source',
            style: TextStyle(fontFamily: 'Afacad', fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Choose how you want to add a pet photo',
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

      debugPrint('📷 AdminAddPet: Requesting camera...');
      final pickedFile = await cameraService.takePicture();

      if (pickedFile != null) {
        if (!mounted) return;
        setState(() {
          _selectedImage = pickedFile;
        });
        debugPrint(
          '[Success] AdminAddPet: Camera photo selected: ${pickedFile.path}',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo captured! Ready to upload.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        debugPrint('[Error] AdminAddPet: Camera error: $e');
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

      debugPrint('📷 AdminAddPet: Picking from gallery...');
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
          '[Success] AdminAddPet: Gallery photo selected: ${pickedFile.path}',
        );
      }
    } catch (e) {
      if (mounted) {
        debugPrint('[Error] AdminAddPet: Gallery error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addPetToBackend() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter pet name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final petService = ref.read(petServiceProvider);
      final hiveService = ref.read(hiveServiceProvider);
      final currentUser = await hiveService.getAuthData();
      final adminId = (currentUser?.authId ?? '').trim();

      if (adminId.isEmpty || adminId.toLowerCase() == 'unknown') {
        throw Exception('Admin session not found. Please login again.');
      }

      // If there's a selected image, upload it first
      String mediaUrlToSend = 'main_logo.png';
      if (_selectedImage != null) {
        debugPrint('📷 AdminAddPet: Uploading image: ${_selectedImage!.path}');
        mediaUrlToSend = await petService.uploadPhoto(
          filePath: _selectedImage!.path,
        );
        debugPrint(
          '[Upload] AdminAddPet: Image uploaded successfully: $mediaUrlToSend',
        );
      } else {
        debugPrint('[Warning] AdminAddPet: No image selected, using default');
      }

      debugPrint(
        '[Pet] AdminAddPet: Creating pet with mediaUrl: $mediaUrlToSend',
      );

      final categoryId = await _resolveCategoryId();
      final species = _selectedCategory.toLowerCase();

      // Create pet with backend API
      await petService.createPet(
        name: _nameController.text,
        description: _descriptionController.text,
        type: 'available',
        species: species,
        categoryId: categoryId,
        location: 'Kathmandu',
        mediaUrl: mediaUrlToSend,
        mediaType: 'photo',
        breed: _selectedBreed,
        age: _getAgeFromCategory(_selectedAge), // Convert category to age
        gender: _selectedGender,
        size: 'medium',
        healthStatus: 'healthy',
        userId: adminId,
      );

      debugPrint('[Success] AdminAddPet: Pet created successfully!');

      // Refresh ALL pet providers so both admin and user views update
      ref.invalidate(adminPetsNotifierProvider);
      ref.invalidate(userPetsProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Return success
      Navigator.pop(context, {'success': true});
    } catch (e) {
      debugPrint('[Error] AdminAddPet: Error: $e');

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
