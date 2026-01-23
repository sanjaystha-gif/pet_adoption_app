import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? icon;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
  });

  @override
  List<Object?> get props => [id, name, description, icon];
}
