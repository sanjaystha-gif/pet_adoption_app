import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/core/services/hive/hive_service.dart';
import 'package:pet_adoption_app/presentation/providers/favorites_provider.dart';
import 'package:pet_adoption_app/presentation/providers/pet_provider.dart';
import 'package:pet_adoption_app/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/presentation/screens/main/pet_details/pet_details_screen.dart';
import 'filter_screen.dart';

class HomePageScreen extends ConsumerStatefulWidget {
  final UserProvider? userProvider;

  const HomePageScreen({super.key, this.userProvider});

  @override
  ConsumerState<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends ConsumerState<HomePageScreen> {
  static const Color _accent = Color(0xFFF67D2C);

  Future<String?> _getHomeProfileImagePath() async {
    final hive = ref.read(hiveServiceProvider);
    final hiveUser = await hive.getAuthData();

    // Load profile picture for the specific user only
    final userId = hiveUser?.authId;
    String? pic;
    if (userId != null && userId.isNotEmpty && userId != 'unknown') {
      pic = await hive.getProfilePicture(userId);
    }

    return pic;
  }

  /// Current filter values
  Map<String, dynamic> _currentFilters = {
    'category': 'All',
    'breed': 'All',
    'age': 'All',
    'gender': 'All',
    'priceRange': const RangeValues(0, 50000),
  };

  /// Get filtered pets based on current filter values
  List<dynamic> _applyFilters(List<dynamic> pets) {
    return pets.where((pet) {
      // Category filter
      if (_currentFilters['category'] != 'All') {
        if (!_matchesCategoryFilter(
          pet,
          _currentFilters['category'].toString(),
        )) {
          return false;
        }
      }

      // Breed filter
      if (_currentFilters['breed'] != 'All') {
        final petBreed = (pet.breed ?? '').toString().toLowerCase().trim();
        final selectedBreed = _currentFilters['breed']
            .toString()
            .toLowerCase()
            .trim();
        final breedMatched =
            petBreed == selectedBreed ||
            petBreed.contains(selectedBreed) ||
            selectedBreed.contains(petBreed);
        if (!breedMatched) {
          return false;
        }
      }

      // Age filter
      if (_currentFilters['age'] != 'All') {
        final petAgeCategory = _ageCategoryFromValue(pet.age);
        if (petAgeCategory != _currentFilters['age']) {
          return false;
        }
      }

      // Gender filter
      if (_currentFilters['gender'] != 'All') {
        final petGender = (pet.gender ?? '').toString().toLowerCase().trim();
        final selectedGender = _currentFilters['gender']
            .toString()
            .toLowerCase()
            .trim();
        if (petGender != selectedGender) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  bool _matchesCategoryFilter(dynamic pet, String selectedCategory) {
    final selected = selectedCategory.toLowerCase().trim();
    final categoryRaw = (pet.category ?? '').toString().toLowerCase().trim();

    if (selected == 'dogs') {
      return categoryRaw == 'dogs' ||
          categoryRaw == 'dog' ||
          categoryRaw.contains('dog');
    }

    if (selected == 'cats') {
      return categoryRaw == 'cats' ||
          categoryRaw == 'cat' ||
          categoryRaw.contains('cat');
    }

    return categoryRaw == selected;
  }

  String _ageCategoryFromValue(dynamic ageValue) {
    final intAge = int.tryParse(ageValue.toString()) ?? 0;
    if (intAge <= 1) return 'Puppy';
    if (intAge <= 3) return 'Young';
    if (intAge <= 8) return 'Adult';
    return 'Senior';
  }

  void _setQuickCategory(String category) {
    setState(() {
      _currentFilters = {..._currentFilters, 'category': category};
    });
  }

  String _normalizeCategoryLabel(String rawValue) {
    final value = rawValue.toLowerCase().trim();
    if (value.isEmpty) return '';

    if (value == 'dog' || value == 'dogs' || value.contains('dog')) {
      return 'Dogs';
    }
    if (value == 'cat' || value == 'cats' || value.contains('cat')) {
      return 'Cats';
    }

    final cleaned = value.replaceAll('_', ' ');
    return cleaned
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  List<String> _availableCategories(List<dynamic> pets) {
    final categories = <String>{'All'};

    for (final pet in pets) {
      final rawCategory = (pet.category ?? '').toString();
      final normalized = _normalizeCategoryLabel(rawCategory);
      if (normalized.isNotEmpty) {
        categories.add(normalized);
      }
    }

    final sorted = categories.where((value) => value != 'All').toList()..sort();
    return ['All', ...sorted];
  }

  List<String> _availableBreeds(List<dynamic> pets) {
    final breeds = <String>{'All'};

    for (final pet in pets) {
      final breed = (pet.breed ?? '').toString().trim();
      if (breed.isNotEmpty) {
        breeds.add(breed);
      }
    }

    final sorted = breeds.where((value) => value != 'All').toList()..sort();
    return ['All', ...sorted];
  }

  void _openFilterScreen() async {
    List<dynamic> pets = <dynamic>[];
    try {
      pets = await ref.read(userPetsProvider.future);
    } catch (_) {
      // If fetching fails, filter screen still opens with default options.
    }

    final categories = _availableCategories(pets);
    final breeds = _availableBreeds(pets);

    if (!mounted) return;

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => FilterScreen(
          currentFilters: _currentFilters,
          availableCategories: categories,
          availableBreeds: breeds,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _currentFilters = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(userPetsProvider);

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
                  FutureBuilder<String?>(
                    future: _getHomeProfileImagePath(),
                    builder: (context, snapshot) {
                      final imagePath = snapshot.data;

                      if (imagePath != null && imagePath.isNotEmpty) {
                        if (imagePath.startsWith('http://') ||
                            imagePath.startsWith('https://')) {
                          return CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: NetworkImage(imagePath),
                          );
                        }

                        final file = File(imagePath);
                        if (file.existsSync()) {
                          return CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: FileImage(file),
                          );
                        }
                      }

                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 24,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi ${widget.userProvider?.user.firstName ?? 'Sanjaya'},',
                          style: TextStyle(
                            fontFamily: 'Aclonica',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.userProvider?.user.address ??
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
                  IconButton(
                    onPressed: () async {
                      // ignore: unused_result
                      await ref.refresh(userPetsProvider.future);
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    onPressed: () async {
                      final pets = await ref.read(userPetsProvider.future);
                      // ignore: avoid_print
                      print(
                        '[AdopterPets] Temporary debug action - parsed pets length: ${pets.length}',
                      );
                    },
                    icon: const Icon(Icons.bug_report_outlined),
                  ),
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
                              active: _currentFilters['category'] == 'Dogs',
                              onTap: () => _setQuickCategory('Dogs'),
                            ),
                            const SizedBox(width: 8),
                            _CategoryChip(
                              label: 'Cats',
                              icon: Icons.pets,
                              active: _currentFilters['category'] == 'Cats',
                              onTap: () => _setQuickCategory('Cats'),
                            ),
                            const SizedBox(width: 8),
                            _CategoryChip(
                              label: 'All',
                              icon: Icons.grid_view_rounded,
                              active: _currentFilters['category'] == 'All',
                              onTap: () => _setQuickCategory('All'),
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

            // Grid of cards with loading/error handling
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // ignore: unused_result
                  await ref.refresh(userPetsProvider.future);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: petsAsync.when(
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(_accent),
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading pets',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Afacad',
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Afacad',
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              // ignore: unused_result
                              await ref.refresh(userPetsProvider.future);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    data: (pets) {
                      final filteredPets = _applyFilters(pets);
                      return filteredPets.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pets,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
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
                              padding: const EdgeInsets.only(
                                bottom: 80,
                                top: 6,
                              ),
                              itemCount: filteredPets.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 0.78,
                                  ),
                              itemBuilder: (context, idx) {
                                final pet = filteredPets[idx];
                                return _PetCard(
                                  key: ValueKey(
                                    '${(pet.id ?? '').toString()}_${(pet.imageUrl ?? '').toString()}',
                                  ),
                                  pet: pet,
                                  imageName: pet.imageUrl ?? 'main_logo.png',
                                );
                              },
                            );
                    },
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
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
        ),
      ),
    );
  }
}

class _PetCard extends ConsumerWidget {
  final dynamic pet; // PetModel
  final String imageName;

  const _PetCard({super.key, required this.pet, required this.imageName});

  String _petId() {
    return (pet.id ?? '').toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petId = _petId();
    final isFavorite = petId.isNotEmpty
        ? ref.watch(isPetFavoriteProvider(petId))
        : false;

    final petName = (pet.name ?? 'Unknown').toString();
    final petBreed = (pet.breed ?? 'Unknown Breed').toString();
    final petAge = (pet.age ?? 'Unknown').toString();
    final petLocation = (pet.location ?? 'Unknown').toString();
    final isMale = (pet.gender ?? '').toString().toLowerCase() == 'male';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PetDetailsScreen(pet: pet)),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _ResolvedAssetImage(
                      key: ValueKey('${_petId()}_$imageName'),
                      imageName: imageName,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.06),
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.25),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Available',
                          style: TextStyle(
                            fontFamily: 'Afacad',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF67D2C),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: petId.isEmpty
                            ? null
                            : () async {
                                await ref
                                    .read(favoritePetIdsProvider.notifier)
                                    .toggleFavorite(petId);
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: isFavorite
                                ? const Color(0xFFF67D2C)
                                : Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 17,
                            color: isFavorite
                                ? Colors.white
                                : const Color(0xFFF67D2C),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            petName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Afacad',
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              height: 1.0,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1EA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isMale ? Icons.male : Icons.female,
                            size: 16,
                            color: const Color(0xFFF67D2C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      petBreed,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Afacad',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _CardMetaChip(icon: Icons.cake_outlined, text: petAge),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _CardMetaChip(
                            icon: Icons.place_outlined,
                            text: petLocation,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardMetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CardMetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Afacad',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget that attempts to resolve an asset image file by testing several
/// candidate filenames in `assets/images/` and shows the first that exists.
class _ResolvedAssetImage extends StatefulWidget {
  final String? imageName; // may be null

  const _ResolvedAssetImage({super.key, this.imageName});

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

  @override
  void didUpdateWidget(covariant _ResolvedAssetImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.imageName ?? '').trim() != (widget.imageName ?? '').trim()) {
      setState(() => _resolvedPath = null);
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final candidates = <String>[];
    if (widget.imageName == null || widget.imageName!.trim().isEmpty) {
      candidates.add('assets/images/main_logo.png');
    } else {
      final raw = widget.imageName!;

      // If imageName is a URL, use it directly (network image)
      if (raw.trim().toLowerCase().startsWith('http://') ||
          raw.trim().toLowerCase().startsWith('https://')) {
        if (mounted) setState(() => _resolvedPath = raw.trim());
        return;
      }

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
        // debug: log attempt
        // ignore: avoid_print
        print('Resolving asset: $path');
        // try to load asset; if it exists, set as resolved and break
        await DefaultAssetBundle.of(context).load(path);
        // ignore: avoid_print
        print('Asset resolved: $path');
        if (mounted) {
          setState(() => _resolvedPath = path);
        }
        return;
      } catch (e) {
        // debug: log failure
        // ignore: avoid_print
        print('Asset not found: $path -> $e');
        // continue to next candidate
      }
    }
    // If none found, ensure fallback
    // ignore: avoid_print
    print('No asset candidates found; falling back to main_logo.png');
    if (mounted) setState(() => _resolvedPath = 'assets/images/main_logo.png');
  }

  @override
  Widget build(BuildContext context) {
    final path = _resolvedPath;
    if (path == null) {
      return Container(color: Colors.grey.shade200);
    }

    // If the resolved path looks like a URL, use network image
    final pathLower = path.toLowerCase();
    if (pathLower.startsWith('http://') || pathLower.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset('assets/images/main_logo.png', fit: BoxFit.cover),
      );
    }

    return Image.asset(path, fit: BoxFit.cover);
  }
}
