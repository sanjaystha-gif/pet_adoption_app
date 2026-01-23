import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:pet_adoption_app/presentation/providers/user_provider.dart';
import '../onboarding/getstarted_screen.dart';
import '../main/main_navigation_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    // Wait 2 seconds then check auth status
    Timer(const Duration(milliseconds: 2000), () async {
      // Check authentication status
      final authNotifier = ref.read(authNotifierProvider);
      final authState = await authNotifier.checkAuthStatus();

      if (mounted) {
        if (authState.isAuthenticated && authState.user != null) {
          // User is logged in, go to main navigation
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MainNavigationScreen(
                userProvider: UserProvider.fromAuthEntity(authState.user!),
              ),
            ),
          );
        } else {
          // User is not logged in, go to onboarding
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const GetstartedScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Image.asset(
                'assets/images/main_logo.png',
                height: 220,
                width: 220,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                'PawBuddy',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
