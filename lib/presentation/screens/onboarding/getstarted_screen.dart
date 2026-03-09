import 'package:flutter/material.dart';
import 'package:pet_adoption_app/presentation/screens/auth/login_screen.dart';

class GetstartedScreen extends StatefulWidget {
  const GetstartedScreen({super.key});

  @override
  State<GetstartedScreen> createState() => _GetstartedScreenState();
}

class _GetstartedScreenState extends State<GetstartedScreen> {
  int _currentStep = 0;

  static const Color _accent = Color(0xFFF67D2C);

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'icon': Icons.pets,
      'gradient': [Color(0xFFFF6B6B), Color(0xFFFFB84D)],
      'title': 'Find Your Perfect Companion',
      'description':
          'Discover loving pets ready for adoption and bring home a friend for life.',
    },
    {
      'icon': Icons.search_rounded,
      'gradient': [Color(0xFF4ECDC4), Color(0xFF44A08D)],
      'title': 'Smart Search, Faster Match',
      'description':
          'Filter by breed, age, and personality to quickly find the pet that fits your lifestyle.',
    },
    {
      'icon': Icons.verified_user_rounded,
      'gradient': [Color(0xFF667EEA), Color(0xFF764BA2)],
      'title': 'Adopt With Confidence',
      'description':
          'Connect securely with shelters and start your adoption journey today.',
    },
  ];

  void _goToLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _goToStep(int step) {
    if (step < 0 || step >= _onboardingData.length) return;
    setState(() {
      _currentStep = step;
    });
  }

  void _nextStep() {
    if (_currentStep >= _onboardingData.length - 1) {
      _goToLogin();
      return;
    }
    _goToStep(_currentStep + 1);
  }

  void _previousStep() {
    if (_currentStep <= 0) return;
    _goToStep(_currentStep - 1);
  }

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) {
    final data = _onboardingData[_currentStep];
    final isLastPage = _currentStep == _onboardingData.length - 1;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: data['gradient'] as List<Color>,
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  children: [
                    // Top bar with logo and skip
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.pets, color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'PawBuddy',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Aclonica',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _goToLogin,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Afacad',
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Icon illustration
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Container(
                        key: ValueKey('icon_$_currentStep'),
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          data['icon'] as IconData,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Content card
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.3),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        key: ValueKey('content_$_currentStep'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              data['title'] as String,
                              style: const TextStyle(
                                fontFamily: 'Aclonica',
                                fontSize: 30,
                                color: Colors.white,
                                height: 1.3,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              data['description'] as String,
                              style: TextStyle(
                                fontFamily: 'Afacad',
                                fontSize: 18,
                                color: Colors.white.withValues(alpha: 0.95),
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 26),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Dot indicators
                                Row(
                                  children: List.generate(
                                    _onboardingData.length,
                                    (dotIndex) => GestureDetector(
                                      onTap: () => _goToStep(dotIndex),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        margin: const EdgeInsets.only(right: 8),
                                        width: _currentStep == dotIndex
                                            ? 32
                                            : 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          color: _currentStep == dotIndex
                                              ? _accent
                                              : Colors.white.withValues(
                                                  alpha: 0.4,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Continue/Get Started button
                                ElevatedButton(
                                  onPressed: _nextStep,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _accent,
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shadowColor: _accent.withValues(alpha: 0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28,
                                      vertical: 16,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isLastPage ? 'Get Started' : 'Continue',
                                        style: const TextStyle(
                                          fontFamily: 'Afacad',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
