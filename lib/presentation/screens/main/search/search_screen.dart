import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/data/models/pet_model.dart';
import 'package:pet_adoption_app/presentation/providers/pet_provider.dart';
import 'package:pet_adoption_app/presentation/screens/main/pet_details/pet_details_screen.dart';
import 'package:pet_adoption_app/presentation/widgets/smart_pet_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final value = _searchController.text.trim();
      if (value == _query) return;
      setState(() => _query = value);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PetModel> _filterPets(List<PetModel> pets) {
    if (_query.isEmpty) {
      return pets;
    }

    final q = _query.toLowerCase();
    return pets.where((pet) {
      final name = pet.name.toLowerCase();
      final breed = pet.breed.toLowerCase();
      final location = pet.location.toLowerCase();
      final gender = pet.gender.toLowerCase();
      return name.contains(q) ||
          breed.contains(q) ||
          location.contains(q) ||
          gender.contains(q);
    }).toList();
  }

  List<String> _topSuggestions(List<PetModel> pets) {
    final map = <String, int>{};
    for (final pet in pets) {
      final breed = pet.breed.trim();
      if (breed.isEmpty) continue;
      map[breed] = (map[breed] ?? 0) + 1;
    }

    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) => e.key).toList();
  }

  void _applySuggestion(String value) {
    _searchController.text = value;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );
    setState(() => _query = value);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final petsAsync = ref.watch(userPetsProvider);

        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Pets',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Afacad',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search for pets...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontFamily: 'Afacad',
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                },
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    petsAsync.when(
                      data: (pets) {
                        final suggestions = _topSuggestions(pets);
                        if (suggestions.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: suggestions
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ActionChip(
                                      label: Text(item),
                                      onPressed: () => _applySuggestion(item),
                                      backgroundColor: const Color(0xFFFFF1EA),
                                      labelStyle: const TextStyle(
                                        fontFamily: 'Afacad',
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFF67D2C),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: petsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text(
                      'Could not load pets\n$error',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'Afacad',
                      ),
                    ),
                  ),
                  data: (pets) {
                    final filtered = _filterPets(pets);

                    if (pets.isEmpty) {
                      return Center(
                        child: Text(
                          'No pets available right now',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontFamily: 'Afacad',
                          ),
                        ),
                      );
                    }

                    if (filtered.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 56,
                            color: Colors.grey[350],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No results for "$_query"',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontFamily: 'Afacad',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try searching by breed, location or gender',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontFamily: 'Afacad',
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final pet = filtered[index];
                        return _SearchPetTile(pet: pet);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchPetTile extends StatelessWidget {
  final PetModel pet;

  const _SearchPetTile({required this.pet});

  @override
  Widget build(BuildContext context) {
    final gender = pet.gender.trim().isEmpty ? 'Unknown' : pet.gender;
    final ageText = pet.age > 0 ? '${pet.age} yrs' : 'Age N/A';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => PetDetailsScreen(pet: pet)));
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SmartPetImage(
                  imageSource: pet.imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Afacad',
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${pet.breed} | $gender | $ageText',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontFamily: 'Afacad',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pet.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontFamily: 'Afacad',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            ],
          ),
        ),
      ),
    );
  }
}
