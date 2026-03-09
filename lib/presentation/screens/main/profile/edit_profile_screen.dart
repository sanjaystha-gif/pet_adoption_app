import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/presentation/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pet_adoption_app/core/services/permission/permission_service.dart';
import 'package:pet_adoption_app/presentation/providers/api_providers.dart';
import 'package:pet_adoption_app/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:pet_adoption_app/core/services/hive/hive_service.dart';
import 'package:pet_adoption_app/core/constants/hive_table_constant.dart';
import 'package:pet_adoption_app/features/auth/data/models/auth_hive_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserProvider userProvider;

  const EditProfileScreen({super.key, required this.userProvider});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;
  File? _selectedImage;
  String? _profileImagePath;
  bool _imageUpdated = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.userProvider.user.firstName,
    );
    _lastNameController = TextEditingController(
      text: widget.userProvider.user.lastName,
    );
    _emailController = TextEditingController(
      text: widget.userProvider.user.email,
    );
    _phoneController = TextEditingController(
      text: widget.userProvider.user.phone,
    );
    _addressController = TextEditingController(
      text: widget.userProvider.user.address,
    );
    _bioController = TextEditingController(text: widget.userProvider.user.bio);
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final hive = HiveService();
      final hiveUser = await hive.getAuthData();
      debugPrint(
        'EditProfile: Loading image, hiveUser exists: ${hiveUser != null}',
      );
      debugPrint('EditProfile: authId = ${hiveUser?.authId}');

      // Load profile picture for the specific user only
      final userId = hiveUser?.authId;
      String? pic;
      if (userId != null && userId.isNotEmpty && userId != 'unknown') {
        pic = await hive.getProfilePicture(userId);
      }

      if (mounted && pic != null) {
        debugPrint('EditProfile: Setting profile image: $pic');
        setState(() => _profileImagePath = pic);
      } else {
        debugPrint('EditProfile: No profile image found');
      }
    } catch (e) {
      debugPrint('EditProfile: Error loading profile image: $e');
    }
  }

  Future<void> _handlePickedFile(File file) async {
    setState(() => _selectedImage = file);

    try {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(const SnackBar(content: Text('Uploading...')));

      debugPrint('EditProfile: Starting upload for file: ${file.path}');
      final uploadedUrl = await ref.read(
        uploadProfilePictureProvider(file.path).future,
      );
      debugPrint('EditProfile: Upload successful, URL: $uploadedUrl');

      final hive = HiveService();
      final hiveUser = await hive.getAuthData();
      final authNotifier = ref.read(authNotifierProvider);
      final userId = hiveUser?.authId;

      debugPrint('EditProfile: Saving picture, userId: $userId');

      // Always save under the active user key for immediate access
      await hive.saveProfilePicture(HiveTableConstant.userTable, uploadedUrl);
      debugPrint('EditProfile: Saved to Hive under active user key');

      // Also save under specific userId if it's valid
      if (userId != null && userId.isNotEmpty && userId != 'unknown') {
        await hive.saveProfilePicture(userId, uploadedUrl);
        debugPrint('EditProfile: Saved to Hive under userId: $userId');

        await authNotifier.updateUserProfile(
          userId: userId,
          profilePicture: uploadedUrl,
        );
        debugPrint('EditProfile: Updated backend profile with userId: $userId');
      } else {
        debugPrint(
          'EditProfile: Skipping backend update - invalid userId: $userId',
        );
      }

      if (mounted) {
        setState(() {
          _profileImagePath = uploadedUrl;
          _selectedImage = null;
          _imageUpdated = true;
        });
        debugPrint('EditProfile: UI updated with new image');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('EditProfile: Error uploading profile picture: $e');
      debugPrint('EditProfile: Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await PermissionService.requestCamera();
      if (!PermissionService.isGranted(status)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      final status = await PermissionService.requestPhotos();
      if (!PermissionService.isGranted(status)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo permission is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        await _handlePickedFile(File(image.path));
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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context, _imageUpdated),
        ),
        title: const Text(
          'Edit Profile',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture Section
            Center(
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (sheetCtx) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Take Photo'),
                              onTap: () async {
                                Navigator.pop(sheetCtx);
                                await _pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Choose from Gallery'),
                              onTap: () async {
                                Navigator.pop(sheetCtx);
                                await _pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Stack(
                  children: [
                    ClipOval(
                      child: Builder(
                        builder: (_) {
                          if (_selectedImage != null) {
                            return Image.file(
                              _selectedImage!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            );
                          }

                          if (_profileImagePath != null &&
                              _profileImagePath!.isNotEmpty) {
                            if (_profileImagePath!.startsWith('http')) {
                              return Image.network(
                                _profileImagePath!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/main_logo.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }

                            try {
                              final f = File(_profileImagePath!);
                              if (f.existsSync()) {
                                return Image.file(
                                  f,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                );
                              }
                            } catch (_) {}
                          }

                          return Image.asset(
                            'assets/images/profile.jpg',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                                  'assets/images/main_logo.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF67D2C),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Form Fields
            _buildTextFormField(
              controller: _firstNameController,
              label: 'First Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _lastNameController,
              label: 'Last Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _bioController,
              label: 'Bio',
              icon: Icons.info,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF67D2C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Afacad',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    try {
      // Get HiveService to update local storage
      final hiveService = HiveService();

      // Get current user from Hive to get the authId
      final currentHiveUser = await hiveService.getAuthData();
      if (currentHiveUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: User data not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saving profile...'),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Make API call to update profile
      final authNotifier = ref.read(authNotifierProvider);
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final email = _emailController.text.trim();
      final phoneNumber = _phoneController.text.trim();
      final address = _addressController.text.trim();

      // Call backend API to update user profile
      await authNotifier.updateUserProfile(
        userId: currentHiveUser.authId ?? 'unknown',
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
      );

      // Update Hive storage with new data
      final updatedHiveModel = AuthHiveModel(
        authId: currentHiveUser.authId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
      );
      await hiveService.saveAuthData(updatedHiveModel);

      // Update UserProvider with new data
      widget.userProvider.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phoneNumber,
        address: address,
        bio: _bioController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFF67D2C)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF67D2C), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
