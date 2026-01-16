import 'package:flutter/material.dart';


class AppThemeWidget extends StatefulWidget {
  const AppThemeWidget({super.key});

  @override
  State<AppThemeWidget> createState() => _AppThemeWidgetState();
}

class _AppThemeWidgetState extends State<AppThemeWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

MaterialApp getApplicationTheme() {
  return MaterialApp(
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Montserrat-Regular',
      colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0B7C7C)),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF0B7C7C),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Montserrat-Bold',
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Montserrat-Regular',
      ),
    ),


    // inputDecorationTheme: InputDecorationTheme(
    //   filled: true,
    //   fillColor: Colors.white,
    //   contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),

    //   enabledBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(6),
    //     borderSide: const BorderSide(color: Colors.grey),
    //   ),

    //   focusedBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(6),
    //     borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
    //   ),

    //   errorBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(6),
    //     borderSide: const BorderSide(color: Colors.red),
    //   ),

    //   focusedErrorBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(6),
    //     borderSide: const BorderSide(color: Colors.red, width: 2),
    //   ),

    //   labelStyle: const TextStyle(
    //     fontFamily: 'OpenSans-Regular',
    //     fontSize: 14,
    //     color: Colors.black87,
    //   ),

    //   hintStyle: const TextStyle(
    //     fontFamily: 'OpenSans-Regular',
    //     fontSize: 14,
    //     color: Colors.grey,
    //   ),
    // ),
    ),
  );
}