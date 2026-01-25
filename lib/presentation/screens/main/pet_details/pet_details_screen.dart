import 'package:flutter/material.dart';
import 'package:pet_adoption_app/presentation/screens/main/bookings/booking_form_screen.dart';

class PetDetailsScreen extends StatefulWidget {
  final dynamic pet; // PetModel or PetEntity

  const PetDetailsScreen({super.key, required this.pet});

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  bool _isFavorite = false;

  /// Get pet value - handle both Map and Object types
  dynamic _getPetValue(String key) {
    if (widget.pet is Map) {
      return widget.pet[key];
    }
    switch (key) {
      case 'image':
      case 'imageUrl':
        return widget.pet.imageUrl ?? 'main_logo.png';
      case 'name':
        return widget.pet.name ?? 'Unknown';
      case 'breed':
        return widget.pet.breed ?? 'Breed';
      case 'age':
        return widget.pet.age ?? 0;
      case 'gender':
        return widget.pet.gender ?? 'Unknown';
      case 'description':
        return widget.pet.description ?? '';
      case 'type':
        return widget.pet.type ?? 'available';
      case 'category':
        return widget.pet.category ?? 'Unknown';
      case 'location':
        return widget.pet.location ?? 'Unknown';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_outline,
              color: _isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFavorite
                        ? '${_getPetValue('name')} added to favorites!'
                        : '${_getPetValue('name')} removed from favorites!',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Image
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey[200],
              child: Image.asset(
                'assets/images/${_getPetValue('image')}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.pets, size: 80, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pet Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPetValue('name'),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Afacad',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getPetValue('breed'),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontFamily: 'Afacad',
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        _getPetValue('gender') == 'Male'
                            ? Icons.male
                            : Icons.female,
                        color: const Color(0xFFF67D2C),
                        size: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Info Pills
                  Row(
                    children: [
                      _buildInfoPill(
                        icon: Icons.cake_outlined,
                        label: '${_getPetValue('age')} years',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoPill(
                        icon: Icons.location_on_outlined,
                        label: _getPetValue('location') ?? 'Location',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoPill(
                        icon: Icons.pets,
                        label: _getPetValue('gender') ?? 'Gender',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description Section
                  Text(
                    'About ${_getPetValue('name')}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Afacad',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getPetValue('description') ??
                        'This is a wonderful pet looking for a loving home. ${_getPetValue('name')} is friendly, playful, and ready to be part of your family.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.6,
                      fontFamily: 'Afacad',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Details Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF67D2C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pet Information',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Afacad',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('Type', 'Dog'),
                        _buildDetailRow('Breed', _getPetValue('breed')),
                        _buildDetailRow('Age', '${_getPetValue('age')} years'),
                        _buildDetailRow('Gender', _getPetValue('gender')),
                        _buildDetailRow('Health Status', 'Healthy'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Requirements Section
                  Text(
                    'Adoption Requirements',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Afacad',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRequirementItem('Minimum 18 years old'),
                  _buildRequirementItem('Stable housing'),
                  _buildRequirementItem('Proof of residence'),
                  _buildRequirementItem('Personal interview'),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookingFormScreen(pet: widget.pet),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF67D2C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Adopt Now',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Afacad',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPill({required IconData icon, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF67D2C).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFF67D2C), size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF67D2C),
                fontFamily: 'Afacad',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontFamily: 'Afacad',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Afacad',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String requirement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: const Color(0xFFF67D2C), size: 18),
          const SizedBox(width: 8),
          Text(
            requirement,
            style: const TextStyle(fontSize: 13, fontFamily: 'Afacad'),
          ),
        ],
      ),
    );
  }
}
