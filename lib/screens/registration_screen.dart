import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Controllers for input fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';

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
      _confirmPasswordError = '';

      if (_emailController.text.isEmpty) {
        _emailError = 'Email is required';
      } else if (!_isValidEmail(_emailController.text)) {
        _emailError = 'Please enter a valid email (e.g., example@gmail.com)';
      }

      if (_passwordController.text.isEmpty) {
        _passwordError = 'Password is required';
      } else if (!_isValidPassword(_passwordController.text)) {
        _passwordError = 'Password must be at least 8 characters';
      }

      if (_confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = 'Please confirm your password';
      } else if (_passwordController.text != _confirmPasswordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFF67D2C);

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
                'Sign Up',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Afacad',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'create a profile and find your friend.',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontFamily: 'Afacad',
                ),
              ),

              const SizedBox(height: 28),

              // Email field
              _buildRoundedField(
                controller: _emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
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

              // Password field
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildRoundedField(
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
                  ),
                ],
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

              const SizedBox(height: 12),

              // Confirm Password field
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildRoundedField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: _obscureConfirm,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[600],
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),
                ],
              ),
              if (_confirmPasswordError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 18.0),
                  child: Text(
                    _confirmPasswordError,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontFamily: 'Afacad',
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _validateInputs();
                    if (_emailError.isEmpty &&
                        _passwordError.isEmpty &&
                        _confirmPasswordError.isEmpty) {
                      // Proceed with account creation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account created successfully!'),
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
                    'Create An Account',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Afacad',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Bottom login text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.grey, fontFamily: 'Afacad'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      'Log in',
                      style: const TextStyle(
                        color: Color(0xFFD86C2B),
                        fontWeight: FontWeight.w600,
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
        suffixIcon: suffix,
      ),
    );
  }
}
