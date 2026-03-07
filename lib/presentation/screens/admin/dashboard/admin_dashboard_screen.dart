import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Close the dialog using its context
                        Navigator.pop(dialogContext);

                        // Capture navigator using outer context before awaiting
                        final navigator = Navigator.of(context);

                        // Logout
                        final adminAuthNotifier = ref.read(
                          adminAuthNotifierProvider,
                        );
                        await adminAuthNotifier.adminLogout();

                        if (!mounted) return;

                        // Navigate back to login using the captured navigator
                        navigator.pushReplacement(
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
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onTabChange,
            height: 70,
            elevation: 0,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFF67D2C).withValues(alpha: 0.2),
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.pets_outlined),
                selectedIcon: Icon(Icons.pets),
                label: 'Pets',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Bookings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
