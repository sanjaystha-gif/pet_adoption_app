import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pet_adoption_app/core/services/hive/hive_service.dart';
import 'package:pet_adoption_app/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:pet_adoption_app/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/presentation/screens/admin/dashboard/admin_dashboard_screen.dart';
import 'package:pet_adoption_app/presentation/screens/auth/login_screen.dart';
import '../onboarding/getstarted_screen.dart';
import '../main/main_navigation_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<bool> _isBiometricEnabledForCurrentUser() async {
    final hive = ref.read(hiveServiceProvider);
    final hiveUser = await hive.getAuthData();
    final userId = hiveUser?.authId;

    if (userId == null || userId.isEmpty || userId == 'unknown') {
      return false;
    }

    return hive.isBiometricLoginEnabled(userId);
  }

  /// Try biometric login with 3 attempts. Returns true if successful.
  Future<bool> _tryBiometricLogin(String userId) async {
    try {
      final deviceSupported = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;

      if (!deviceSupported || !canCheckBiometrics) {
        return false;
      }

      final available = await _localAuth.getAvailableBiometrics();
      if (available.isEmpty) {
        return false;
      }

      // User gets 3 attempts. If all fail, return false.
      for (var attempt = 1; attempt <= 3; attempt++) {
        try {
          final authenticated = await _localAuth.authenticate(
            localizedReason: 'Verify your fingerprint to login ($attempt/3)',
            options: const AuthenticationOptions(
              biometricOnly: true,
              stickyAuth: true,
              useErrorDialogs: true,
            ),
          );

          if (authenticated) {
            return true;
          }
        } catch (e) {
          debugPrint('Biometric attempt $attempt failed: $e');
          // Continue to next attempt
        }
      }

      return false;
    } catch (e) {
      debugPrint('Biometric login failed due to error: $e');
      return false;
    }
  }

  Future<bool> _authenticateIfBiometricAvailable() async {
    try {
      final enabled = await _isBiometricEnabledForCurrentUser();
      if (!enabled) {
        return true;
      }

      final deviceSupported = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;

      if (!deviceSupported || !canCheckBiometrics) {
        return false;
      }

      final available = await _localAuth.getAvailableBiometrics();
      if (available.isEmpty) {
        return false;
      }

      // User gets only 3 attempts. If all fail, fallback to email/password login.
      for (var attempt = 1; attempt <= 3; attempt++) {
        final authenticated = await _localAuth.authenticate(
          localizedReason:
              'Verify your fingerprint to open PawBuddy ($attempt/3)',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
            useErrorDialogs: true,
          ),
        );

        if (authenticated) {
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Biometric auth failed due to error: $e');
      return false;
    }
  }

  void _checkAuthStatus() {
    // Wait 2 seconds then check auth status
    Timer(const Duration(milliseconds: 2000), () async {
      final hiveService = ref.read(hiveServiceProvider);

      // FIRST: Check if there's a biometric login available from previous session
      final lastUserId = await hiveService.getLastBiometricUser();
      if (lastUserId != null && lastUserId.isNotEmpty) {
        final biometricEnabled = await hiveService.isBiometricLoginEnabled(
          lastUserId,
        );

        if (biometricEnabled) {
          // Try biometric authentication (3 attempts)
          final biometricSuccess = await _tryBiometricLogin(lastUserId);

          if (!mounted) return;

          if (biometricSuccess) {
            // Biometric auth succeeded, restore token and navigate
            final savedAuth = await hiveService.getBiometricToken(lastUserId);
            if (savedAuth != null) {
              await hiveService.saveToken(savedAuth['token']!);
              await hiveService.saveUserRole(savedAuth['role']!);

              if (!mounted) return;

              // Navigate based on role
              if (savedAuth['role'] == 'admin') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const AdminDashboardScreen(),
                  ),
                );
              } else {
                // Load user data and navigate to main screen
                final authNotifier = ref.read(authNotifierProvider);
                final authState = await authNotifier.checkAuthStatus();

                if (!mounted) return;

                if (authState.isAuthenticated && authState.user != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => MainNavigationScreen(
                        userProvider: UserProvider.fromAuthEntity(
                          authState.user!,
                        ),
                      ),
                    ),
                  );
                } else {
                  // If auth check fails, go to login
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              }
              return;
            }
          } else {
            // Biometric failed after 3 attempts, clear biometric token and go to login
            await hiveService.deleteBiometricToken(lastUserId);

            if (!mounted) return;

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
            return;
          }
        }
      }

      // SECOND: Normal authentication check (no biometric or biometric not setup)
      final token = await hiveService.getToken();
      final userRole = await hiveService.getUserRole();
      debugPrint(
        'Splash routing: tokenExists=${token != null && token.isNotEmpty}, role=$userRole',
      );

      if (!mounted) return;

      if (token != null && token.isNotEmpty && userRole == 'admin') {
        final authenticated = await _authenticateIfBiometricAvailable();
        if (!mounted) return;
        if (!authenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          return;
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
        return;
      }

      // Check adopter authentication status for regular users
      final authNotifier = ref.read(authNotifierProvider);
      final authState = await authNotifier.checkAuthStatus();

      if (authState.isAuthenticated && authState.user != null) {
        final authenticated = await _authenticateIfBiometricAvailable();
        if (!mounted) return;
        if (!authenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          return;
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MainNavigationScreen(
              userProvider: UserProvider.fromAuthEntity(authState.user!),
            ),
          ),
        );
      } else {
        if (!mounted) return;
        // User is not logged in, go to onboarding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GetstartedScreen()),
        );
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
