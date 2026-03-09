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
    // Safe helper functions
    String getString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is List) {
        if (value.isEmpty) return '';
        // API can return media as an array; use the first valid entry.
        return getString(value.first);
      }
      if (value is Map) {
        final mediaCandidate =
            value['url'] ??
            value['secure_url'] ??
            value['mediaUrl'] ??
            value['media'] ??
            value['path'] ??
            value['location'];
        if (mediaCandidate != null) {
          final parsedMedia = getString(mediaCandidate);
          if (parsedMedia.isNotEmpty) return parsedMedia;
        }
        return value['_id'] ?? value['id'] ?? value['name'] ?? '';
      }
      return value.toString();
    }

    int getInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    bool getBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }

    String firstNonEmpty(List<dynamic> values) {
      for (final value in values) {
        final parsed = getString(value).trim();
        if (parsed.isNotEmpty) {
          return parsed;
        }
      }
      return '';
    }

    String getCategoryValue(Map<String, dynamic> source) {
      final raw = source['category'];

      if (raw is Map) {
        final name = getString(raw['name']).trim();
        if (name.isNotEmpty) return name;
      }

      final categoryFromRaw = getString(raw).trim();
      if (categoryFromRaw.isNotEmpty) return categoryFromRaw;

      // Fallback to species so category-based filters still work.
      return getString(source['species']).trim();
    }

    try {
      return PetModel(
        id: getString(json['_id'] ?? json['id']),
        name: firstNonEmpty([json['itemName'], json['name'], 'Unnamed Pet']),
        description: getString(json['description']),
        type:
            getString(
                  json['type'] ?? json['status'] ?? json['adoptionStatus'],
                ).trim() ==
                ''
            ? 'available'
            : getString(
                json['type'] ?? json['status'] ?? json['adoptionStatus'],
              ),
        category: getCategoryValue(json),
        location: getString(json['location']),
        mediaUrl: firstNonEmpty([
          json['mediaUrl'],
          json['media'],
          json['photos'],
        ]),
        mediaType: getString(json['mediaType']) == ''
            ? 'photo'
            : getString(json['mediaType']),
        breed: getString(json['breed']),
        age: getInt(json['age']),
        gender: getString(json['gender']),
        size: getString(json['size']),
        healthStatus: getString(json['healthStatus']) == ''
            ? 'healthy'
            : getString(json['healthStatus']),
        isAdopted:
            getBool(json['isClaimed'] ?? json['isAdopted']) ||
            getString(json['adoptionStatus']).toLowerCase() == 'adopted',
        adoptedBy: getString(json['claimedBy'] ?? json['adoptedBy']),
        adoptedByName: json['claimedBy'] is Map
            ? getString(json['claimedBy']['name'])
            : getString(json['adoptedByName']),
        postedBy: getString(json['reportedBy'] ?? json['postedBy']),
        postedByName: json['reportedBy'] is Map
            ? getString(json['reportedBy']['name'])
            : getString(json['postedByName']),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        adoptedAt: json['adoptedAt'] != null
            ? DateTime.parse(json['adoptedAt'].toString())
            : null,
      );
    } catch (e) {
      // Error parsing pet; rethrow for upstream handling
      rethrow;
    }
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
  String get imageUrl => mediaUrl.isNotEmpty ? mediaUrl : 'main_logo.png';

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
