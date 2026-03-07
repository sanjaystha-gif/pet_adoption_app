import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pet_adoption_app/core/constants/hive_table_constant.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pet_adoption_app/core/services/permission/permission_service.dart';
import 'package:pet_adoption_app/presentation/providers/api_providers.dart';
import 'package:pet_adoption_app/core/services/hive/hive_service.dart';
import 'package:pet_adoption_app/presentation/screens/main/bookings/my_bookings_screen.dart';
import 'package:pet_adoption_app/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/presentation/screens/auth/login_screen.dart';
import 'package:pet_adoption_app/features/auth/presentation/notifiers/auth_notifier.dart';
import 'edit_profile_screen.dart';
import 'saved_pets_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final UserProvider userProvider;

  const ProfileScreen({super.key, required this.userProvider});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _selectedImage;
  String? _profileImagePath; // can be network URL or local file path

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final hive = ref.read(hiveServiceProvider);
      final hiveUser = await hive.getAuthData();
      debugPrint('ProfileScreen: Loading image, hiveUser exists: ${hiveUser != null}');
      debugPrint('ProfileScreen: authId = ${hiveUser?.authId}');
      
      // Try active user's profile picture first (fallback key)
      var pic = await hive.getProfilePicture(HiveTableConstant.userTable);
      
      // If not found and we have a specific authId, try that
      if (pic == null) {
        final userId = hiveUser?.authId;
        if (userId != null && userId.isNotEmpty && userId != 'unknown') {
          pic = await hive.getProfilePicture(userId);
        }
      }
      
      if (mounted && pic != null) {
        debugPrint('ProfileScreen: Setting profile image: $pic');
        setState(() => _profileImagePath = pic);
      } else {
        debugPrint('ProfileScreen: No profile image found');
      }
    } catch (e) {
      debugPrint('ProfileScreen: Error loading profile image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = widget.userProvider;
    debugPrint('ProfileScreen: Building with user - name: ${userProvider.user.fullName}, email: ${userProvider.user.email}, phone: ${userProvider.user.phone}, address: ${userProvider.user.address}');

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            // Profile Header
            Column(
              children: [
                GestureDetector(
                  onTap: _uploadProfilePicture,
                  child: Stack(
                    children: [
                      ClipOval(
                        child: Builder(
                          builder: (_) {
                            // Priority: local preview file -> network/url -> default avatar
                            if (_selectedImage != null) {
                              return Image.file(
                                _selectedImage!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              );
                            }

                            if (_profileImagePath != null &&
                                _profileImagePath!.isNotEmpty) {
                              // Network URL
                              if (_profileImagePath!.startsWith('http')) {
                                return Image.network(
                                  _profileImagePath!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _defaultAvatar(),
                                );
                              }

                              // Local file path
                              try {
                                final f = File(_profileImagePath!);
                                if (f.existsSync()) {
                                  return Image.file(
                                    f,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  );
                                }
                              } catch (_) {}
                            }

                            return _defaultAvatar();
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
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userProvider.user.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Afacad',
                  ),
                ),
                const SizedBox(height: 16),
                // Profile Information Details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email
                      _buildProfileDetailRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: userProvider.user.email,
                      ),
                      const SizedBox(height: 12),
                      // Phone
                      _buildProfileDetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: userProvider.user.phone,
                      ),
                      const SizedBox(height: 12),
                      // Address
                      _buildProfileDetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: userProvider.user.address,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Profile Options
            _ProfileOptionTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () async {
                final updated = await Navigator.of(context).push<bool?>(
                  MaterialPageRoute(
                    builder: (_) =>
                        EditProfileScreen(userProvider: widget.userProvider),
                  ),
                );
                // If edit screen reported an update, reload persisted image
                if (updated == true) {
                  await _loadProfileImage();
                }
              },
            ),
            _ProfileOptionTile(
              icon: Icons.receipt_long,
              title: 'My Bookings',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                );
              },
            ),
            _ProfileOptionTile(
              icon: Icons.favorite_outline,
              title: 'Saved Pets',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SavedPetsScreen()),
                );
              },
            ),
            _ProfileOptionTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutConfirmation(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Log Out',
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

  Widget _buildProfileDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final displayValue = value.isEmpty ? 'Not provided' : value;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFFF67D2C)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'Afacad',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayValue,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Afacad',
                  color: value.isEmpty ? Colors.grey[400] : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: 40, color: Colors.grey[600]),
    );
  }

  Future<void> _uploadProfilePicture() async {
    Future<void> showPermissionDeniedDialog(
      PermissionStatus status,
      String message,
    ) async {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      if (status.isPermanentlyDenied) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('$message. Please enable in Settings.'),
            backgroundColor: Colors.red,
          ),
        );
        final open = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'Permission is permanently denied. Open settings to enable?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        if (open == true) await PermissionService.openSettings();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final status = await PermissionService.requestCamera();
                  if (!PermissionService.isGranted(status)) {
                    if (!mounted) return;
                    await showPermissionDeniedDialog(
                      status,
                      'Camera permission is required',
                    );
                    return;
                  }

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening camera...')),
                  );

                  try {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      if (!mounted) return;
                      await _handlePickedFile(File(image.path));
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error opening camera: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final status = await PermissionService.requestPhotos();
                  if (!PermissionService.isGranted(status)) {
                    if (!mounted) return;
                    await showPermissionDeniedDialog(
                      status,
                      'Photo permission is required',
                    );
                    return;
                  }

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening gallery...')),
                  );

                  try {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      if (!mounted) return;
                      await _handlePickedFile(File(image.path));
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error picking image: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handlePickedFile(File file) async {
    // Show local preview immediately
    setState(() => _selectedImage = file);

    // Upload to backend and update profile
    try {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(const SnackBar(content: Text('Uploading...')));

      // Upload using provider
      final uploadedUrl = await ref.read(
        uploadProfilePictureProvider(file.path).future,
      );

      // Update profile on backend using AuthNotifier and persist image locally
      final hive = ref.read(hiveServiceProvider);
      final hiveUser = await hive.getAuthData();
      final authNotifier = ref.read(authNotifierProvider);
      final userId = hiveUser?.authId;
      
      debugPrint('ProfileScreen: Saving picture, userId: $userId');

      // Always save under the active user key for immediate access
      await hive.saveProfilePicture(HiveTableConstant.userTable, uploadedUrl);
      
      // Also save under specific userId if it's valid
      if (userId != null && userId.isNotEmpty && userId != 'unknown') {
        await hive.saveProfilePicture(userId, uploadedUrl);
        await authNotifier.updateUserProfile(
          userId: userId,
          profilePicture: uploadedUrl,
        );
        debugPrint('ProfileScreen: Updated backend profile with userId: $userId');
      }
      if (mounted) {
        setState(() {
          _profileImagePath = uploadedUrl;
          _selectedImage = null;
        });
      }

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
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

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Log Out',
            style: TextStyle(fontFamily: 'Afacad', fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(fontFamily: 'Afacad'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Afacad', color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Call logout through the auth notifier
                final authNotifier = ref.read(authNotifierProvider);

                // Capture navigator from outer context and a dialog pop closure before awaiting
                final navigator = Navigator.of(context);
                void popDialog() => Navigator.pop(dialogContext);

                await authNotifier.logout();

                if (!mounted) return;

                // Pop the dialog using captured closure
                popDialog();

                // Navigate to login screen and remove all previous routes
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(fontFamily: 'Afacad'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFF67D2C)),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Afacad',
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
