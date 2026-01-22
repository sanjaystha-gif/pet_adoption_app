import 'package:flutter/material.dart';
import 'package:pet_adoption_app/presentation/screens/admin/pets/admin_pets_list_screen.dart';
import 'package:pet_adoption_app/presentation/screens/admin/bookings/admin_booking_requests_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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
            onPressed: () {},
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
