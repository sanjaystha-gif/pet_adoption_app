import 'package:flutter/material.dart';

class BookingFormScreen extends StatefulWidget {
  final Map<String, dynamic> pet;

  const BookingFormScreen({super.key, required this.pet});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFF67D2C);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Adoption Request',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Afacad',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.pets, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adopting: ${widget.pet['name']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Afacad',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.pet['breed']} • ${widget.pet['age']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Afacad',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Your Information
            Text(
              'Your Information',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Afacad',
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel('Full Name'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hintText: 'Enter your full name',
            ),
            const SizedBox(height: 16),

            _buildLabel('Email Address'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            _buildLabel('Phone Number'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _phoneController,
              hintText: 'Enter your phone number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            _buildLabel('Address'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _addressController,
              hintText: 'Enter your residential address',
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Adoption Questions
            Text(
              'Adoption Questions',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Afacad',
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel('Why do you want to adopt ${widget.pet['name']}?'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _reasonController,
              hintText: 'Tell us about your reasons...',
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Agreements
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agreements & Acknowledgments',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Afacad',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAgreementItem(
                    'I confirm that all information provided is true and accurate',
                  ),
                  _buildAgreementItem(
                    'I understand the pet\'s needs and am prepared to provide proper care',
                  ),
                  _buildAgreementItem(
                    'I agree to veterinary check-ups and proper pet care',
                  ),
                  _buildAgreementItem(
                    'I accept that the adoption can be revoked if conditions are not met',
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() => _agreeToTerms = value ?? false);
                    },
                    title: const Text(
                      'I agree to all terms and conditions',
                      style: TextStyle(fontSize: 13, fontFamily: 'Afacad'),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFFF67D2C),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _agreeToTerms ? () => _submitRequest(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text(
                  'Submit Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Afacad',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'Afacad',
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Afacad'),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontFamily: 'Afacad'),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFF67D2C), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildAgreementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(Icons.check_circle, color: Color(0xFFF67D2C), size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontFamily: 'Afacad',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitRequest(BuildContext context) {
    if (_validateForm()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success!'),
          content: Text(
            'Your adoption request for ${widget.pet['name']} has been submitted successfully.\n\nThe admin will review your request and get back to you soon.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close booking form
                Navigator.pop(context); // Close pet details
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  bool _validateForm() {
    if (_nameController.text.isEmpty) {
      _showError('Please enter your name');
      return false;
    }
    if (_emailController.text.isEmpty ||
        !RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        ).hasMatch(_emailController.text)) {
      _showError('Please enter a valid email');
      return false;
    }
    if (_phoneController.text.isEmpty) {
      _showError('Please enter your phone number');
      return false;
    }
    if (_addressController.text.isEmpty) {
      _showError('Please enter your address');
      return false;
    }
    if (_reasonController.text.isEmpty) {
      _showError('Please tell us why you want to adopt');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
