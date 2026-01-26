import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pet_adoption_app/presentation/providers/pet_provider.dart';
import 'package:pet_adoption_app/presentation/providers/api_providers.dart';

class AdminEditPetScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> pet;

  const AdminEditPetScreen({super.key, required this.pet});

  @override
  ConsumerState<AdminEditPetScreen> createState() => _AdminEditPetScreenState();
}

class _AdminEditPetScreenState extends ConsumerState<AdminEditPetScreen> {
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _descriptionController;
  late String _selectedAge;
  late String _selectedGender;
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _ages = ['Puppy', 'Young', 'Adult', 'Senior'];
  final List<String> _genders = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet['name']);
    _breedController = TextEditingController(text: widget.pet['breed']);
    _descriptionController = TextEditingController(
      text: widget.pet['description'] ?? '',
    );
    _selectedAge = widget.pet['age'] ?? 'Puppy';
    _selectedGender = widget.pet['gender'] ?? 'Male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
            TextField(
              controller: _breedController,
              decoration: InputDecoration(
                hintText: 'Enter breed',
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
                        initialValue: _selectedAge,
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

  Future<void> _pickImage() async {
    try {
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

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      final petService = ref.read(petServiceProvider);
      final petId = widget.pet['id'] ?? widget.pet['_id'];

      // ignore: avoid_print
      print('🔍 Editing pet - ID: $petId');
      // ignore: avoid_print
      print('📝 Pet data: ${widget.pet}');

      if (petId == null) {
        throw Exception('Pet ID not found');
      }

      // Call backend to update pet
      await petService.updatePet(
        petId: petId.toString(),
        name: _nameController.text,
        breed: _breedController.text,
        description: _descriptionController.text,
        age: _getAgeFromCategory(_selectedAge), // Convert category to age
        gender: _selectedGender,
        type: widget.pet['type'] ?? 'available',
        categoryId: '6973651cd96b87a44687ca13', // Dogs category ID
        location: widget.pet['location'] ?? 'Kathmandu',
        mediaUrl:
            _selectedImage?.path ??
            widget.pet['mediaUrl'] ??
            'main_logo.png', // Use selected image or keep existing or default app logo
        mediaType: widget.pet['mediaType'] ?? 'photo',
      );

      // Invalidate the pet cache to force refresh
      ref.invalidate(allPetsProvider);
      ref.invalidate(adminUpdatedPetsProvider);
      ref.invalidate(userPetsProvider);

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
      if (!mounted) return;

      // ignore: avoid_print
      print('❌ Error in _saveChanges: $e');
      // ignore: avoid_print
      print('📋 Stack trace: ${StackTrace.current}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating pet: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
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
