import 'package:flutter/material.dart';
import 'package:pet_adoption_app/presentation/screens/main/pet_details/pet_details_screen.dart';
import 'filter_screen.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  static const Color _accent = Color(0xFFF67D2C);

  /// Current filter values
  Map<String, dynamic> _currentFilters = {
    'category': 'All',
    'breed': 'All',
    'age': 'All',
    'gender': 'All',
    'priceRange': const RangeValues(0, 50000),
  };

  /// Sample pet data
  final List<Map<String, dynamic>> _allPets = const [
    {
      "name": "Shephard",
      "meta": "Adult | Playfull",
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
      "name": "Khaire",
      "meta": "Young | Active",
      "image": "khaire.jpg",
      "breed": "Beagle",
      "age": "Young",
      "gender": "Male",
      "description":
          "Khaire is an active and curious Beagle who loves exploring. He is playful and enjoys socializing with other dogs.",
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

  /// Get filtered pets based on current filter values
  List<Map<String, dynamic>> get _filteredPets {
    return _allPets.where((pet) {
      // Category filter (we'll use breed as category proxy for now)
      if (_currentFilters['category'] != 'All') {
        // This would need actual category field in pets
        // For now, we'll skip category filtering
      }

      // Breed filter
      if (_currentFilters['breed'] != 'All') {
        if (pet['breed'] != _currentFilters['breed']) {
          return false;
        }
      }

      // Age filter
      if (_currentFilters['age'] != 'All') {
        if (pet['age'] != _currentFilters['age']) {
          return false;
        }
      }

      // Gender filter
      if (_currentFilters['gender'] != 'All') {
        if (pet['gender'] != _currentFilters['gender']) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _openFilterScreen() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => FilterScreen(currentFilters: _currentFilters),
      ),
    );

    if (result != null) {
      setState(() {
        _currentFilters = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const SizedBox(width: 8),
                  // Profile avatar (uses profile.jpg if present, falls back to main_logo.png)
                  ClipOval(
                    child: Image.asset(
                      'assets/images/profile.jpg',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/main_logo.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi Sanjaya,',
                          style: TextStyle(
                            fontFamily: 'Aclonica',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Kathmandu, Nepal',
                          style: TextStyle(
                            fontFamily: 'Aclonica',
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                ],
              ),
            ),

            // Title and category chips
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Have you found your pet?',
                          style: TextStyle(
                            fontFamily: 'Aclonica',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _CategoryChip(
                              label: 'Dogs',
                              icon: Icons.pets,
                              active: true,
                            ),
                            const SizedBox(width: 8),
                            _CategoryChip(
                              label: 'Cats',
                              icon: Icons.pets,
                              active: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _openFilterScreen,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.tune, color: _accent),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Grid of cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: _filteredPets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pets, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No Pets Found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Afacad',
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Afacad',
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 80, top: 6),
                        itemCount: _filteredPets.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.78,
                            ),
                        itemBuilder: (context, idx) {
                          final pet = _filteredPets[idx];
                          final imageName = pet['image'] ?? 'main_logo.png';
                          return _PetCard(pet: pet, imageName: imageName);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;

  const _CategoryChip({
    required this.label,
    required this.icon,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFFF1EA) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: active
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: active ? const Color(0xFFF67D2C) : Colors.grey[700],
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Aclonica',
              fontSize: 13,
              color: active ? const Color(0xFFF67D2C) : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final Map<String, dynamic> pet;
  final String imageName;

  const _PetCard({required this.pet, required this.imageName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => PetDetailsScreen(pet: pet)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // image area
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Try to resolve the correct asset filename (different cases/extensions)
                    _ResolvedAssetImage(imageName: imageName),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          size: 18,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // info area
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pet['name'],
                        style: TextStyle(
                          fontFamily: 'Aclonica',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        pet['gender'] == 'Male' ? Icons.male : Icons.female,
                        size: 16,
                        color: Colors.orange[700],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pet['meta'],
                    style: TextStyle(
                      fontFamily: 'Aclonica',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that attempts to resolve an asset image file by testing several
/// candidate filenames in `assets/images/` and shows the first that exists.
class _ResolvedAssetImage extends StatefulWidget {
  final String? imageName; // may be null

  const _ResolvedAssetImage({this.imageName});

  @override
  State<_ResolvedAssetImage> createState() => _ResolvedAssetImageState();
}

class _ResolvedAssetImageState extends State<_ResolvedAssetImage> {
  String? _resolvedPath;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final candidates = <String>[];
    if (widget.imageName == null || widget.imageName!.trim().isEmpty) {
      candidates.add('assets/images/main_logo.png');
    } else {
      final raw = widget.imageName!;
      // If imageName already includes a path, try it first
      if (raw.startsWith('assets/')) {
        candidates.add(raw);
      } else {
        // Try the provided filename as-is under assets/images
        candidates.add('assets/images/$raw');
        // try common variations: lowercase, .jpg, .jpeg, .png
        final nameLower = raw.toLowerCase();
        if (!nameLower.startsWith('assets/images/')) {
          candidates.add('assets/images/$nameLower');
        }

        // if has no extension, add common extensions
        if (!raw.contains('.')) {
          candidates.add('assets/images/$raw.jpg');
          candidates.add('assets/images/$raw.jpeg');
          candidates.add('assets/images/$raw.png');
          candidates.add('assets/images/${raw.toLowerCase()}.jpg');
          candidates.add('assets/images/${raw.toLowerCase()}.jpeg');
          candidates.add('assets/images/${raw.toLowerCase()}.png');
        } else {
          // if has extension but possibly typo (jpep), try correcting common typos
          final correctedJpeg = raw.replaceAll(
            RegExp(r'jpep', caseSensitive: false),
            'jpeg',
          );
          if (correctedJpeg != raw) {
            candidates.add('assets/images/$correctedJpeg');
          }
        }
      }
      // always fallback to main_logo
      candidates.add('assets/images/main_logo.png');
    }

    for (final path in candidates) {
      try {
        // try to load asset; if it exists, set as resolved and break
        await DefaultAssetBundle.of(context).load(path);
        if (mounted) {
          setState(() => _resolvedPath = path);
        }
        return;
      } catch (_) {
        // continue to next candidate
      }
    }
    // If none found, ensure fallback
    if (mounted) setState(() => _resolvedPath = 'assets/images/main_logo.png');
  }

  @override
  Widget build(BuildContext context) {
    final path = _resolvedPath;
    if (path == null) {
      return Container(color: Colors.grey.shade200);
    }
    return Image.asset(path, fit: BoxFit.cover);
  }
}
