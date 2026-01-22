import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  final Map<String, dynamic> currentFilters;

  const FilterScreen({super.key, required this.currentFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late String _selectedCategory;
  late String _selectedBreed;
  late String _selectedAge;
  late String _selectedGender;
  late RangeValues _priceRange;

  final List<String> _categories = ['All', 'Dogs', 'Cats', 'Rabbits', 'Birds'];
  final List<String> _breeds = [
    'All',
    'German Shepherd',
    'Labrador',
    'Beagle',
    'Poodle',
    'Golden Retriever',
    'Bulldog',
  ];
  final List<String> _ages = ['All', 'Puppy', 'Young', 'Adult', 'Senior'];
  final List<String> _genders = ['All', 'Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentFilters['category'] ?? 'All';
    _selectedBreed = widget.currentFilters['breed'] ?? 'All';
    _selectedAge = widget.currentFilters['age'] ?? 'All';
    _selectedGender = widget.currentFilters['gender'] ?? 'All';
    _priceRange =
        widget.currentFilters['priceRange'] ?? const RangeValues(0, 10000);
  }

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
          'Filters',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filter
            _buildFilterSection(
              title: 'Category',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        fontFamily: 'Afacad',
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFFF67D2C),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Breed Filter
            _buildFilterSection(
              title: 'Breed',
              child: DropdownButton<String>(
                value: _selectedBreed,
                isExpanded: true,
                items: _breeds.map((breed) {
                  return DropdownMenuItem(
                    value: breed,
                    child: Text(
                      breed,
                      style: const TextStyle(fontFamily: 'Afacad'),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedBreed = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // Age Filter
            _buildFilterSection(
              title: 'Age',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _ages.map((age) {
                  final isSelected = _selectedAge == age;
                  return FilterChip(
                    label: Text(
                      age,
                      style: TextStyle(
                        fontFamily: 'Afacad',
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedAge = age);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFFF67D2C),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Gender Filter
            _buildFilterSection(
              title: 'Gender',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _genders.map((gender) {
                  final isSelected = _selectedGender == gender;
                  return FilterChip(
                    label: Text(
                      gender,
                      style: TextStyle(
                        fontFamily: 'Afacad',
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedGender = gender);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFFF67D2C),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Price Range Filter
            _buildFilterSection(
              title: 'Price Range',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rs. ${_priceRange.start.toStringAsFixed(0)} - Rs. ${_priceRange.end.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Afacad',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFFF67D2C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 50000,
                    divisions: 100,
                    labels: RangeLabels(
                      _priceRange.start.toStringAsFixed(0),
                      _priceRange.end.toStringAsFixed(0),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() => _priceRange = values);
                    },
                    activeColor: const Color(0xFFF67D2C),
                    inactiveColor: Colors.grey[300],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'All';
                        _selectedBreed = 'All';
                        _selectedAge = 'All';
                        _selectedGender = 'All';
                        _priceRange = const RangeValues(0, 50000);
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(
                        color: Color(0xFFF67D2C),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Clear Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Afacad',
                        color: Color(0xFFF67D2C),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final filters = {
                        'category': _selectedCategory,
                        'breed': _selectedBreed,
                        'age': _selectedAge,
                        'gender': _selectedGender,
                        'priceRange': _priceRange,
                      };
                      Navigator.pop(context, filters);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF67D2C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
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
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Afacad',
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
