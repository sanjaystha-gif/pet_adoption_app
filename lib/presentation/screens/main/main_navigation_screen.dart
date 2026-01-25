import 'package:flutter/material.dart';
import 'package:pet_adoption_app/presentation/screens/main/home/homepage_screen.dart';
import 'package:pet_adoption_app/presentation/screens/main/search/search_screen.dart';
import 'package:pet_adoption_app/presentation/screens/main/favorites/favorites_screen.dart';
import 'package:pet_adoption_app/presentation/screens/main/profile/profile_screen.dart';
import 'package:pet_adoption_app/presentation/providers/user_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  final UserProvider userProvider;

  const MainNavigationScreen({super.key, required this.userProvider});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomePageScreen(),
      const SearchScreen(),
      const FavoritesScreen(),
      ProfileScreen(userProvider: widget.userProvider),
    ];
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBarWidget(
        accent: const Color(0xFFF67D2C),
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final Color accent;
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationBarWidget({
    super.key,
    required this.accent,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(
              icon: Icons.home,
              active: currentIndex == 0,
              accent: accent,
              onPressed: () => onTap(0),
            ),
            _NavIcon(
              icon: Icons.search,
              active: currentIndex == 1,
              accent: accent,
              onPressed: () => onTap(1),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => onTap(2),
                icon: Icon(
                  currentIndex == 2 ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
              ),
            ),
            _NavIcon(
              icon: Icons.person_outline,
              active: currentIndex == 3,
              accent: accent,
              onPressed: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color accent;
  final VoidCallback onPressed;

  const _NavIcon({
    required this.icon,
    required this.active,
    required this.accent,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: active ? accent : Colors.grey[600]),
    );
  }
}
