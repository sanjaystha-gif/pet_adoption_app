import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/presentation/providers/booking_provider.dart';

class BookingFormScreen extends ConsumerStatefulWidget {
  final dynamic pet; // Can be Map or PetModel/PetEntity

  const BookingFormScreen({super.key, required this.pet});

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  static const Color orange = Color(0xFFF67D2C);

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _agreeToTerms = false;

  /// Get pet value - handle both Map and Object types
  dynamic _getPetValue(String key) {
    if (widget.pet is Map) {
      return widget.pet[key];
    }
    switch (key) {
      case 'name':
        return widget.pet.name ?? 'Unknown';
      case 'breed':
        return widget.pet.breed ?? 'Breed';
      case 'age':
        return widget.pet.age ?? 0;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  bool _validate() {
    return _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _reasonController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
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
            Text(
              'Please fill in the details below to request the adoption of ${_getPetValue('name')}.',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Afacad',
              ),
            ),
            const SizedBox(height: 24),

            // Full Name
            Text(
              'Full Name',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Afacad',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Afacad',
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Email
            Text(
              'Email Address',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Afacad',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Afacad',
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Phone
            Text(
              'Phone Number',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Afacad',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter your phone number',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Afacad',
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Address
            Text(
              'Address',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Afacad',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter your address',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Afacad',
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reason for Adoption
            Text(
              'Why do you want to adopt ${_getPetValue('name')}?',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Afacad',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us why you would be a great match...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Afacad',
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Terms and Conditions
            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() => _agreeToTerms = value ?? false);
                  },
                  activeColor: orange,
                ),
                const Expanded(
                  child: Text(
                    'I agree to the terms and conditions',
                    style: TextStyle(fontSize: 12, fontFamily: 'Afacad'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _agreeToTerms
                    ? () async {
                        final isSubmitting = _validate();
                        if (!isSubmitting) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        // Show loading indicator
                        if (mounted) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(orange),
                              ),
                            ),
                          );
                        }

                        try {
                          // Get pet details - handle both Map and Object types
                          String petId = '';
                          String petName = '';
                          String petImageUrl = '';

                          if (widget.pet is Map) {
                            petId = widget.pet['_id'] ?? widget.pet['id'] ?? '';
                            petName = widget.pet['name'] ?? '';
                            petImageUrl =
                                widget.pet['imageUrl'] ??
                                widget.pet['photos']?[0] ??
                                'main_logo.png';
                          } else {
                            petId = widget.pet.id ?? '';
                            petName = widget.pet.name ?? '';
                            petImageUrl =
                                widget.pet.imageUrl ?? 'main_logo.png';
                          }

                          final bookingService = ref.read(
                            bookingServiceProvider,
                          );

                          // Submit booking - using dummy userId, should come from auth in real app
                          await bookingService.createBooking(
                            userId: 'user123',
                            petId: petId,
                            petName: petName,
                            petImageUrl: petImageUrl,
                            userName: _nameController.text.trim(),
                            userEmail: _emailController.text.trim(),
                            userPhone: _phoneController.text.trim(),
                            address: _addressController.text.trim(),
                            reason: _reasonController.text.trim(),
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Adoption request submitted successfully!',
                                ),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    : null,
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
          ],
        ),
      ),
    );
  }
}
