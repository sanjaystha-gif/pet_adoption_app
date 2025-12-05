import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'getstarted_screen.dart'; // Import the GetStartedScreen
import 'splash_screen.dart';

const String _appTitle = 'PawBuddy';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF67D2C)),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/getstarted': (context) => const GetstartedScreen(),
      },
    );
  }
}