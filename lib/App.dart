import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/screens/getstarted_screen.dart'; // Import the GetStartedScreen
import 'package:pet_adoption_app/screens/splash_screen.dart';

const String _appTitle = 'PawBuddy';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: _appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF67D2C)),
        useMaterial3: true,
        fontFamily: 'Aclonica',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/getstarted': (context) => const GetstartedScreen(),
      },
    );
  }
}
