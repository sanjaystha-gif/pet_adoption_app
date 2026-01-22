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
    const orange = Color(0xFFF67D2C);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Logo/App Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: orange,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: orange.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(Icons.pets, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                'Create Account',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Afacad',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a profile and find your perfect companion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Afacad',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Email field label
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email Address',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Afacad',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildRoundedField(
                controller: _emailController,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                prefix: const Icon(Icons.email_outlined, color: orange),
              ),
              if (_emailError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                  child: Text(
                    _emailError,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontFamily: 'Afacad',
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Password field label
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Afacad',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildRoundedField(
                controller: _passwordController,
                hintText: 'At least 8 characters',
                obscureText: _obscure,
                prefix: const Icon(Icons.lock_outlined, color: orange),
                suffix: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: orange,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              if (_passwordError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                  child: Text(
                    _passwordError,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontFamily: 'Afacad',
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Confirm Password field label
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Confirm Password',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Afacad',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildRoundedField(
                controller: _confirmPasswordController,
                hintText: 'Re-enter your password',
                obscureText: _obscureConfirm,
                prefix: const Icon(Icons.lock_outlined, color: orange),
                suffix: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: orange,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              if (_confirmPasswordError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                  child: Text(
                    _confirmPasswordError,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontFamily: 'Afacad',
                    ),
                  ),
                ),

              const SizedBox(height: 28),

              // CTA Button
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
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Afacad',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Bottom login text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontFamily: 'Afacad',
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      'Log In',
                      style: const TextStyle(
                        color: Color(0xFFF67D2C),
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Afacad',
                        fontSize: 14,
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
      style: const TextStyle(fontFamily: 'Afacad', fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontFamily: 'Afacad',
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        prefixIcon: prefix,
        suffixIcon: suffix,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF67D2C), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }
}
