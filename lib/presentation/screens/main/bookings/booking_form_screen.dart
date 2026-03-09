import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/core/services/hive/hive_service.dart';
import 'package:pet_adoption_app/presentation/providers/api_providers.dart';
import 'package:pet_adoption_app/presentation/providers/booking_provider.dart';
import 'package:pet_adoption_app/presentation/widgets/smart_pet_image.dart';

class BookingFormScreen extends ConsumerStatefulWidget {
  final dynamic pet;

  const BookingFormScreen({super.key, required this.pet});

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  static const Color _accent = Color(0xFFF67D2C);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _reasonController = TextEditingController();

  bool _agreeToTerms = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  Future<void> _prefillUserData() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      if (_nameController.text.isEmpty) _nameController.text = currentUser.name;
      if (_emailController.text.isEmpty) {
        _emailController.text = currentUser.email;
      }
      if (_phoneController.text.isEmpty) {
        _phoneController.text = currentUser.phoneNumber;
      }
      return;
    }

    final hiveUser = await ref.read(hiveServiceProvider).getAuthData();
    if (!mounted || hiveUser == null) return;

    if (_nameController.text.isEmpty) {
      _nameController.text = '${hiveUser.firstName} ${hiveUser.lastName}'
          .trim();
    }
    if (_emailController.text.isEmpty) _emailController.text = hiveUser.email;
    if (_phoneController.text.isEmpty) {
      _phoneController.text = hiveUser.phoneNumber ?? '';
    }
    if (_addressController.text.isEmpty) {
      _addressController.text = hiveUser.address;
    }
  }

  String _petName() {
    if (widget.pet is Map) {
      final map = widget.pet as Map;
      return (map['name'] ?? map['itemName'] ?? 'Unknown Pet').toString();
    }
    try {
      final dynamic pet = widget.pet;
      return (pet.name ?? pet.itemName ?? 'Unknown Pet').toString();
    } catch (_) {
      return 'Unknown Pet';
    }
  }

  String _petId() {
    if (widget.pet is Map) {
      final map = widget.pet as Map;
      return (map['_id'] ?? map['id'] ?? '').toString();
    }
    try {
      final dynamic pet = widget.pet;
      return (pet.id ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  String _petImage() {
    if (widget.pet is Map) {
      final map = widget.pet as Map;
      final photos = map['photos'];
      final media = map['media'];
      return (map['mediaUrl'] ??
              map['imageUrl'] ??
              ((photos is List && photos.isNotEmpty) ? photos.first : null) ??
              ((media is List && media.isNotEmpty) ? media.first : null) ??
              'main_logo.png')
          .toString();
    }
    try {
      final dynamic pet = widget.pet;
      final dynamic photos = pet.photos;
      final dynamic media = pet.media;
      return (pet.mediaUrl ??
              pet.imageUrl ??
              ((photos is List && photos.isNotEmpty) ? photos.first : null) ??
              ((media is List && media.isNotEmpty) ? media.first : null) ??
              'main_logo.png')
          .toString();
    } catch (_) {
      return 'main_logo.png';
    }
  }

  String _petBreed() {
    if (widget.pet is Map) {
      final map = widget.pet as Map;
      return (map['breed'] ?? 'Unknown Breed').toString();
    }
    try {
      return (widget.pet.breed ?? 'Unknown Breed').toString();
    } catch (_) {
      return 'Unknown Breed';
    }
  }

  Future<String?> _currentUserId() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null && currentUser.id.isNotEmpty) return currentUser.id;
    final hiveUser = await ref.read(hiveServiceProvider).getAuthData();
    return hiveUser?.authId;
  }

  Future<void> _submit() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final petId = _petId();
    if (petId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to identify pet for booking.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userId = await _currentUserId();
    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login again before creating a booking.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final booking = await ref
          .read(createBookingProvider.notifier)
          .createBooking(
            userId: userId,
            userName: _nameController.text.trim(),
            userEmail: _emailController.text.trim(),
            userPhone: _phoneController.text.trim(),
            petId: petId,
            petName: _petName(),
            petImageUrl: _petImage(),
            address: _addressController.text.trim(),
            reason: _reasonController.text.trim(),
          );

      if (!mounted) return;

      if (booking == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking could not be submitted. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ref.invalidate(userBookingsProvider);
      ref.invalidate(adminBookingsProvider);
      ref.invalidate(pendingBookingsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adoption request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, {'success': true});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      hintStyle: TextStyle(color: Colors.grey.shade500, fontFamily: 'Afacad'),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _accent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
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

  @override
  Widget build(BuildContext context) {
    final petName = _petName();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Adoption Booking',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Afacad',
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SmartPetImage(
                        imageSource: _petImage(),
                        width: 74,
                        height: 74,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            petName,
                            style: const TextStyle(
                              fontFamily: 'Afacad',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _petBreed(),
                            style: TextStyle(
                              fontFamily: 'Afacad',
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Fill the form below to submit your request.',
                            style: TextStyle(
                              fontFamily: 'Afacad',
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _FieldLabel(text: 'Full Name'),
              TextFormField(
                controller: _nameController,
                decoration: _fieldDecoration('Enter your full name'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Full name is required'
                    : null,
              ),
              const SizedBox(height: 14),
              _FieldLabel(text: 'Email Address'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _fieldDecoration('Enter your email'),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return 'Email is required';
                  final valid = RegExp(
                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                  ).hasMatch(text);
                  if (!valid) return 'Enter a valid email address';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _FieldLabel(text: 'Phone Number'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _fieldDecoration('Enter your phone number'),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return 'Phone number is required';
                  if (text.length < 7) return 'Phone number looks too short';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _FieldLabel(text: 'Address'),
              TextFormField(
                controller: _addressController,
                decoration: _fieldDecoration('Enter your current address'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Address is required'
                    : null,
              ),
              const SizedBox(height: 14),
              _FieldLabel(text: 'Why do you want to adopt $petName?'),
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                decoration: _fieldDecoration(
                  'Describe why you are a good match',
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return 'Please provide your reason';
                  if (text.length < 10) {
                    return 'Please provide a bit more detail';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                value: _agreeToTerms,
                contentPadding: EdgeInsets.zero,
                activeColor: _accent,
                onChanged: _isSubmitting
                    ? null
                    : (value) => setState(() => _agreeToTerms = value ?? false),
                title: const Text(
                  'I confirm this information is correct and agree to the booking terms.',
                  style: TextStyle(fontFamily: 'Afacad', fontSize: 12.5),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Submit Adoption Request',
                          style: TextStyle(
                            fontFamily: 'Afacad',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Afacad',
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
