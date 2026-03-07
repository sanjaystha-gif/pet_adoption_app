import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_adoption_app/core/services/permission/permission_service.dart';
import 'package:pet_adoption_app/presentation/providers/api_providers.dart';
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
  String _selectedBreed = 'Golden Retriever';
  String _selectedAge = 'Puppy';
  String _selectedGender = 'Male';
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _ages = ['Puppy', 'Young', 'Adult', 'Senior'];
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _breeds = [
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
                            color: orange.withOpacity(0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: orange.withOpacity(0.05),
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

                    // Breed Dropdown
                    _buildLabel('Breed', Icons.category),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedBreed,
                      items: _breeds
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
                                value: _selectedAge,
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
                                value: _selectedGender,
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
                  shadowColor: orange.withOpacity(0.4),
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
    try {
      final status = await PermissionService.requestPhotos();
      if (!PermissionService.isGranted(status)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo permission required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
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

      // If there's a selected image, upload it first
      String mediaUrlToSend = 'main_logo.png';
      if (_selectedImage != null) {
        mediaUrlToSend = await ref.read(
          uploadPhotoProvider(_selectedImage!.path).future,
        );
      }

      // Create pet with backend API
      await petService.createPet(
        name: _nameController.text,
        description: _descriptionController.text,
        type: 'available',
        categoryId: '6973651cd96b87a44687ca13', // Dogs category ID
        location: 'Kathmandu',
        mediaUrl: mediaUrlToSend,
        mediaType: 'photo',
        breed: _selectedBreed,
        age: _getAgeFromCategory(_selectedAge), // Convert category to age
        gender: _selectedGender,
        size: 'medium',
        healthStatus: 'healthy',
        userId: 'admin', // Will be replaced by actual admin ID from auth
      );

      // Refresh ALL pet providers so both admin and user views update
      ref.invalidate(adminPetsNotifierProvider);
      ref.invalidate(userPetsProvider);
      ref.invalidate(petApiClientProvider);

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
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding pet: $e'),
          backgroundColor: Colors.red,
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
