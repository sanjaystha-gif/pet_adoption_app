import 'package:pet_adoption_app/domain/entities/category_entity.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String? icon;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
  });

  /// Convert from JSON response from API
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'],
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description, 'icon': icon};
  }

  /// Convert to Entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      description: description,
      icon: icon,
    );
  }
}
