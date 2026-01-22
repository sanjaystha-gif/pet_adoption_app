import 'package:flutter/material.dart';
import 'package:pet_adoption_app/presentation/screens/main/bookings/my_bookings_screen.dart';
import 'package:pet_adoption_app/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/presentation/screens/auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'saved_pets_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserProvider userProvider;

  const ProfileScreen({super.key, required this.userProvider});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            // Profile Header
            Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/profile.jpg',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/main_logo.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.userProvider.user.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Afacad',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.userProvider.user.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'Afacad',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Profile Options
            _ProfileOptionTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        EditProfileScreen(userProvider: widget.userProvider),
                  ),
                );
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

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Afacad', color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Reset user data
                widget.userProvider.reset();

                // Pop the dialog
                Navigator.pop(context);

                // Navigate to login screen and remove all previous routes
                Navigator.of(context).pushAndRemoveUntil(
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
