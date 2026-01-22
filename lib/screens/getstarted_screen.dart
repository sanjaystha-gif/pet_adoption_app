import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'admin_login_screen.dart';

class GetstartedScreen extends StatefulWidget {
  const GetstartedScreen({super.key});

  @override
  GetStartedScreenState createState() => GetStartedScreenState();
}

class GetStartedScreenState extends State<GetstartedScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  // Onboarding data
  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/main_logo.png',
      'title': 'Welcome To PawBuddy',
      'description':
          'Let\'s find your dream pet and be a home for homeless pets.',
    },
    {
      'image': 'assets/images/main_logo.png',
      'title': 'Adopt Easily',
      'description': 'Browse and adopt pets with ease from our platform.',
    },
    {
      'image': 'assets/images/main_logo.png',
      'title': 'Get Started Now',
      'description': 'Join us and find your perfect companion today.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                final data = _onboardingData[index];
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Pet illustration from assets
                        Image.asset(data['image']!, height: 320, width: 320),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: 250,
                          child: Text(
                            data['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Aclonica',
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: 280,
                          child: Text(
                            data['description']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'Afacad',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingData.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? const Color(0xFFF67D2C)
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Get Started button only on last page
          if (_currentPage == _onboardingData.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to LoginScreen when pressed
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF67D2C),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Afacad',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      // Navigate to AdminLoginScreen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AdminLoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Admin Login',
                      style: TextStyle(
                        color: const Color(0xFFF67D2C),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Afacad',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
