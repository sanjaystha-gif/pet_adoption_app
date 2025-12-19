import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavigationBarWidget extends ConsumerWidget {
  final Color accent;

  const BottomNavigationBarWidget({super.key, required this.accent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            _NavIcon(icon: Icons.home, active: true, accent: accent),
            _NavIcon(icon: Icons.search, active: false, accent: accent),
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
              child: const Icon(Icons.home_outlined, color: Colors.white),
            ),
            _NavIcon(
              icon: Icons.favorite_border,
              active: false,
              accent: accent,
            ),
            _NavIcon(icon: Icons.person_outline, active: false, accent: accent),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends ConsumerWidget {
  final IconData icon;
  final bool active;
  final Color accent;

  const _NavIcon({
    required this.icon,
    required this.active,
    required this.accent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon, color: active ? accent : Colors.grey[600]),
    );
  }
}
