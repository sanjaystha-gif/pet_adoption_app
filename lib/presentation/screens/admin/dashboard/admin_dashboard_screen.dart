import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/features/admin/domain/providers/pet_provider.dart';
import 'package:pet_adoption_app/features/admin/presentation/providers/admin_auth_provider.dart';
import 'package:pet_adoption_app/presentation/screens/admin/pets/admin_pets_list_screen.dart';
import 'package:pet_adoption_app/presentation/screens/admin/bookings/admin_booking_requests_screen.dart';
import 'package:pet_adoption_app/presentation/screens/onboarding/getstarted_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const AdminPetsListScreen(),
      const AdminBookingRequestsScreen(),
    ];
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _selectedIndex == 0 ? 'Pet Management' : 'Booking Requests',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Afacad',
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // Show logout confirmation
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        // Logout
                        final adminAuthNotifier = ref.read(
                          adminAuthNotifierProvider,
                        );
                        await adminAuthNotifier.adminLogout();

                        if (!mounted) return;

                        // Clear pets when logging out
                        ref.read(petListProvider.notifier).clearPets();

                        // Navigate back to login
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const GetstartedScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.black),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabChange,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Pets'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Bookings',
          ),
        ],
        selectedItemColor: const Color(0xFFF67D2C),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
