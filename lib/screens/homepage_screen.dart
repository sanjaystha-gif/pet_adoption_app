import 'package:flutter/material.dart';
import 'package:pet_adoption_app/bottom_navigation/bottomnavigation_screen.dart';

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  static const Color _accent = Color(0xFFF67D2C);
  //
  final List<Map<String, String>> _pets = const [
    {"name": "Shephard", "meta": "Adult | Playfull", "image": "shephard.jpg"},
    {"name": "Kaali", "meta": "Young | Loyal", "image": "kaali.jpg"},
    {"name": "Khaire", "meta": "Young | Active", "image": "khaire.jpg"},
    {"name": "Gori", "meta": "Puppy | Protective", "image": "gori.jpg"},
  ];

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
                  Container(
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
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Grid of cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 80, top: 6),
                  itemCount: _pets.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, idx) {
                    final pet = _pets[idx];
                    final imageName = pet['image'] ?? 'main_logo.png';
                    return _PetCard(
                      name: pet['name']!,
                      meta: pet['meta']!,
                      imageName: imageName,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBarWidget(accent: _accent),
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
  final String name;
  final String meta;
  final String
  imageName; // filename only, e.g. 'Shephard.jpeg' or 'shephard.jpg'

  const _PetCard({
    required this.name,
    required this.meta,
    required this.imageName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
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
                        name,
                        style: TextStyle(
                          fontFamily: 'Aclonica',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Icon(Icons.male, size: 16, color: Colors.orange[700]),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    meta,
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
