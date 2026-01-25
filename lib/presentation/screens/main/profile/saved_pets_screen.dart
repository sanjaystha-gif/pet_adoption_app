import 'package:flutter/material.dart';
import 'package:pet_adoption_app/presentation/screens/main/pet_details/pet_details_screen.dart';

class SavedPetsScreen extends StatefulWidget {
  const SavedPetsScreen({super.key});

  @override
  State<SavedPetsScreen> createState() => _SavedPetsScreenState();
}

class _SavedPetsScreenState extends State<SavedPetsScreen> {
  final List<Map<String, dynamic>> _savedPets = [
    {
      "name": "Shephard",
      "meta": "Adult | Playful",
      "image": "shephard.jpg",
      "breed": "German Shepherd",
      "age": "Adult",
      "gender": "Male",
      "description":
          "Shephard is a friendly and loyal German Shepherd who loves playing fetch and going on adventures. He is great with kids and other pets.",
    },
    {
      "name": "Kaali",
      "meta": "Young | Loyal",
      "image": "kaali.jpg",
      "breed": "Labrador",
      "age": "Young",
      "gender": "Female",
      "description":
          "Kaali is a young and energetic Labrador with a golden heart. She loves swimming and is very affectionate with her family.",
    },
    {
      "name": "Gori",
      "meta": "Puppy | Protective",
      "image": "gori.jpg",
      "breed": "Poodle",
      "age": "Puppy",
      "gender": "Female",
      "description":
          "Gori is an adorable and intelligent Poodle puppy. She is already learning commands and loves cuddles.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saved Pets',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Afacad',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF7F7F8),
      body: _savedPets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Saved Pets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Afacad',
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start saving your favorite pets',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Afacad',
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _savedPets.length,
              itemBuilder: (context, index) {
                final pet = _savedPets[index];
                final imageName = pet['image'] ?? 'main_logo.png';
                return _SavedPetCard(
                  pet: pet,
                  imageName: imageName,
                  onRemove: () {
                    setState(() {
                      _savedPets.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pet removed from saved'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _SavedPetCard extends StatelessWidget {
  final Map<String, dynamic> pet;
  final String imageName;
  final VoidCallback onRemove;

  const _SavedPetCard({
    required this.pet,
    required this.imageName,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => PetDetailsScreen(pet: pet)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pet Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.asset(
                'assets/images/$imageName',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/main_logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Pet Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Afacad',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pet['meta'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Afacad',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pet['breed'] ?? 'Unknown Breed',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontFamily: 'Afacad',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Remove Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.favorite,
                  color: Color(0xFFF67D2C),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
