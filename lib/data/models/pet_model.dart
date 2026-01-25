import 'package:pet_adoption_app/domain/entities/pet_entity.dart';

class PetModel {
  final String id;
  final String name;
  final String description;
  final String type;
  final String category;
  final String location;
  final String mediaUrl;
  final String mediaType;
  final String breed;
  final int age;
  final String gender;
  final String size;
  final String healthStatus;
  final bool isAdopted;
  final String? adoptedBy;
  final String? adoptedByName;
  final String postedBy;
  final String postedByName;
  final DateTime createdAt;
  final DateTime? adoptedAt;

  PetModel({
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

  /// Convert from JSON response from API
  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['itemName'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'available',
      category: json['category'] is Map
          ? json['category']['_id'] ?? json['category']['id'] ?? ''
          : json['category'] ?? '',
      location: json['location'] ?? '',
      mediaUrl: json['media'] ?? json['mediaUrl'] ?? '',
      mediaType: json['mediaType'] ?? 'photo',
      breed: json['breed'] ?? '',
      age: json['age'] is int
          ? json['age']
          : int.tryParse(json['age'].toString()) ?? 0,
      gender: json['gender'] ?? '',
      size: json['size'] ?? '',
      healthStatus: json['healthStatus'] ?? 'healthy',
      isAdopted: json['isClaimed'] ?? json['isAdopted'] ?? false,
      adoptedBy: json['claimedBy'] is Map
          ? json['claimedBy']['_id'] ?? json['claimedBy']['id']
          : json['claimedBy'] ?? json['adoptedBy'],
      adoptedByName: json['claimedBy'] is Map
          ? json['claimedBy']['name']
          : json['adoptedByName'],
      postedBy: json['reportedBy'] is Map
          ? json['reportedBy']['_id'] ?? json['reportedBy']['id'] ?? ''
          : json['reportedBy'] ?? json['postedBy'] ?? '',
      postedByName: json['reportedBy'] is Map
          ? json['reportedBy']['name'] ?? ''
          : json['postedByName'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      adoptedAt: json['adoptedAt'] != null
          ? DateTime.parse(json['adoptedAt'])
          : null,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'itemName': name,
      'name': name,
      'description': description,
      'type': type,
      'category': category,
      'location': location,
      'media': mediaUrl,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'breed': breed,
      'age': age,
      'gender': gender,
      'size': size,
      'healthStatus': healthStatus,
      'isClaimed': isAdopted,
      'isAdopted': isAdopted,
      'reportedBy': postedBy,
      'postedBy': postedBy,
    };
  }

  /// Get image URL with default profile icon
  String get imageUrl => mediaUrl.isNotEmpty ? mediaUrl : 'profile.jpg';

  /// Convert to Entity
  PetEntity toEntity() {
    return PetEntity(
      id: id,
      name: name,
      description: description,
      type: type,
      category: category,
      location: location,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      breed: breed,
      age: age,
      gender: gender,
      size: size,
      healthStatus: healthStatus,
      isAdopted: isAdopted,
      adoptedBy: adoptedBy,
      adoptedByName: adoptedByName,
      postedBy: postedBy,
      postedByName: postedByName,
      createdAt: createdAt,
      adoptedAt: adoptedAt,
    );
  }
}
