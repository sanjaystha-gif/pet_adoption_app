import 'package:flutter/material.dart';
import 'getstarted_screen.dart'; // Import the GetStartedScreen

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawBuddyy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GetstartedScreen(), // Set GetStartedScreen as the home
    );
  }
}