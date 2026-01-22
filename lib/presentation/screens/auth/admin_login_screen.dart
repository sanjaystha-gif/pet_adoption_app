import 'package:flutter/material.dart';
import 'package:pet_adoption_app/presentation/screens/admin/dashboard/admin_dashboard_screen.dart';
import 'package:pet_adoption_app/presentation/screens/onboarding/getstarted_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  String _emailError = '';
  String _passwordError = '';

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8;
  }

  void _validateInputs() {
    setState(() {
      _emailError = '';
      _passwordError = '';

      if (_emailController.text.isEmpty) {
        _emailError = 'Email is required';
      } else if (!_isValidEmail(_emailController.text)) {
        _emailError = 'Please enter a valid email (e.g., admin@example.com)';
      }

      if (_passwordController.text.isEmpty) {
        _passwordError = 'Password is required';
      } else if (!_isValidPassword(_passwordController.text)) {
        _passwordError = 'Password must be at least 8 characters';
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFF67D2C);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Admin Login',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Afacad',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage pets and bookings',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontFamily: 'Afacad',
                ),
              ),
              const SizedBox(height: 32),

              _buildRoundedField(
                controller: _emailController,
                hintText: 'Admin Email',
                keyboardType: TextInputType.emailAddress,
                prefix: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Colors.grey,
                ),
              ),
              if (_emailError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 18.0),
                  child: Text(
                    _emailError,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontFamily: 'Afacad',
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              _buildRoundedField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: _obscure,
                suffix: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              if (_passwordError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 18.0),
                  child: Text(
                    _passwordError,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontFamily: 'Afacad',
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _validateInputs();
                    if (_emailError.isEmpty && _passwordError.isEmpty) {
                      // Navigate to AdminDashboardScreen after successful login
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const AdminDashboardScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Login as Admin',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Afacad',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not an admin? ',
                    style: TextStyle(color: Colors.grey, fontFamily: 'Afacad'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GetstartedScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Go back',
                      style: const TextStyle(
                        color: Color(0xFFD86C2B),
                        fontFamily: 'Afacad',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? prefix,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontFamily: 'Afacad'),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontFamily: 'Afacad'),
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
      ),
    );
  }
}
