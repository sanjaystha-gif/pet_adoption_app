import 'package:equatable/equatable.dart';

class PetEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String type; // 'available', 'adopted', 'pending'
  final String category; // dog, cat, rabbit, etc.
  final String location;
  final String mediaUrl; // image or video URL
  final String mediaType; // 'photo' or 'video'
  final String breed;
  final int age; // in months or years
  final String gender;
  final String size; // small, medium, large
  final String healthStatus;
  final bool isAdopted;
  final String? adoptedBy;
  final String? adoptedByName;
  final String postedBy;
  final String postedByName;
  final DateTime createdAt;
  final DateTime? adoptedAt;

  const PetEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.category,
    required this.location,
    required this.mediaUrl,
    required this.mediaType,
    required this.breed,
    required this.age,
    required this.gender,
    required this.size,
    required this.healthStatus,
    required this.isAdopted,
    this.adoptedBy,
    this.adoptedByName,
    required this.postedBy,
    required this.postedByName,
    required this.createdAt,
    this.adoptedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    type,
    category,
    location,
    mediaUrl,
    mediaType,
    breed,
    age,
    gender,
    size,
    healthStatus,
    isAdopted,
    adoptedBy,
    adoptedByName,
    postedBy,
    postedByName,
    createdAt,
    adoptedAt,
  ];
}
