import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart'; // Import the App file

void main() {
  runApp(
    ProviderScope(child: MyApp()),
  ); // Run the MyApp widget defined in App.dart
}
