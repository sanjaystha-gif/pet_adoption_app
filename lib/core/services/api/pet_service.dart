import 'package:pet_adoption_app/core/error/failure.dart';
import 'package:pet_adoption_app/core/services/api/api_service.dart';
import 'package:pet_adoption_app/data/models/pet_model.dart';
import 'package:pet_adoption_app/domain/entities/pet_entity.dart';

/// Pet Service
///
/// Handles all pet-related operations including:
/// - Creating pet listings
/// - Retrieving pets with filtering and pagination
/// - Updating pet information
/// - Deleting pets
/// - Managing adoption status
class PetService {
  final ApiService _apiService;

  // API endpoints matching Node.js backend routes
  // The backend uses "items" terminology, we map it to "pets"
  static const String _itemsEndpoint = '/items';
  static const String _uploadPhotoEndpoint = '/pets/items/upload-photo';
  static const String _uploadVideoEndpoint = '/items/upload-video';

  PetService({required ApiService apiService}) : _apiService = apiService;

  /// Create a new pet listing
  ///
  /// Creates a new pet listing with provided information.
  /// Requires authentication.
  Future<PetEntity> createPet({
    required String name,
    required String description,
    required String type, // 'available', 'adopted', etc.
    required String categoryId,
    required String location,
    required String mediaUrl,
    required String mediaType, // 'photo' or 'video'
    String? breed,
    int? age,
    String? gender,
    String? size,
    String? healthStatus,
    String? species,
    required String userId, // postedBy/reportedBy
  }) async {
    try {
      final normalizedMedia = _normalizeMediaForApi(mediaUrl);
      final payload = {
        'itemName': name,
        'description': description,
        'type': type,
        'species': species ?? 'dog',
        'category': categoryId,
        'location': location,
        'mediaUrl': normalizedMedia,
        'mediaType': mediaType,
        'breed': breed ?? '',
        'age': age ?? 0,
        'gender': (gender ?? '').toLowerCase(),
        'postedBy': userId,
      };

      // ignore: avoid_print
      print('[Pet] PetService: Creating pet with payload: $payload');

      final response = await _apiService
          .postAuth(_itemsEndpoint, data: payload)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw ApiFailure(
                message:
                    'Request timed out after 15 seconds. Please check your connection and try again.',
                statusCode: 408,
              );
            },
          );

      // ignore: avoid_print
      print('[Pet] PetService: Create response status: ${response.statusCode}');
      // ignore: avoid_print
      print('[Pet] PetService: Create response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final petModel = PetModel.fromJson(
          response.data['data'] ?? response.data,
        );
        return petModel.toEntity();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Pet creation failed',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      // ignore: avoid_print
      print('[Pet] PetService: Create pet error: $e');
      throw ApiFailure(message: 'Create pet error: ${e.toString()}');
    }
  }

  /// Get all pets with optional filtering and pagination
  ///
  /// Retrieves paginated list of pets with optional filtering by:
  /// - type (available, adopted, pending)
  /// - status
  /// - category
  /// - page and limit for pagination
  Future<Map<String, dynamic>> getAllPets({
    int page = 1,
    int limit = 10,
    String? type,
    String? status,
    String? categoryId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'page': page, 'limit': limit};

      if (type != null) queryParameters['type'] = type;
      if (status != null) queryParameters['status'] = status;
      if (categoryId != null) queryParameters['category'] = categoryId;

      final response = await _apiService.get(
        _itemsEndpoint,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> pets = data['data'] ?? [];

        return {
          'pets': pets.map((pet) => PetModel.fromJson(pet).toEntity()).toList(),
          'total': data['total'] ?? pets.length,
          'page': data['page'] ?? page,
          'pages': data['pages'] ?? 1,
          'count': data['count'] ?? pets.length,
        };
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Failed to fetch pets',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Get all pets error: ${e.toString()}');
    }
  }

  /// Get pet by ID
  ///
  /// Retrieves detailed information about a specific pet.
  Future<PetEntity> getPetById({required String petId}) async {
    try {
      final response = await _apiService.get('$_itemsEndpoint/$petId');

      if (response.statusCode == 200) {
        final petModel = PetModel.fromJson(
          response.data['data'] ?? response.data,
        );
        return petModel.toEntity();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Pet not found',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Get pet by ID error: ${e.toString()}');
    }
  }

  /// Update pet information
  ///
  /// Updates an existing pet listing.
  /// Only the user who created the listing can update it.
  /// Requires authentication.
  Future<PetEntity> updatePet({
    required String petId,
    String? name,
    String? description,
    String? type,
    String? categoryId,
    String? location,
    String? mediaUrl,
    String? mediaType,
    String? breed,
    int? age,
    String? gender,
    String? size,
    String? healthStatus,
    String? species,
    bool? isAdopted,
    String? adoptedBy,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['itemName'] = name;
      if (description != null) data['description'] = description;
      if (type != null) data['type'] = type;
      if (species != null) data['species'] = species;
      if (categoryId != null) data['category'] = categoryId;
      if (location != null) data['location'] = location;
      if (mediaUrl != null) {
        final normalizedMedia = _normalizeMediaForApi(mediaUrl);
        data['mediaUrl'] = normalizedMedia;
      }
      if (mediaType != null) data['mediaType'] = mediaType;
      if (breed != null) data['breed'] = breed;
      if (age != null) data['age'] = age;
      if (gender != null) data['gender'] = gender.toLowerCase();
      if (size != null) data['size'] = size;
      if (healthStatus != null) data['healthStatus'] = healthStatus;
      if (isAdopted != null) data['isAdopted'] = isAdopted;
      if (adoptedBy != null) data['adoptedBy'] = adoptedBy;
      if (status != null) data['status'] = status;

      // ignore: avoid_print
      print('[Pet] PetService: Updating pet $petId with data: $data');

      final response = await _apiService
          .putAuth('$_itemsEndpoint/$petId', data: data)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw ApiFailure(
                message:
                    'Request timed out after 15 seconds. Please check your connection and try again.',
                statusCode: 408,
              );
            },
          );

      // ignore: avoid_print
      print('[Pet] PetService: Update response status: ${response.statusCode}');
      // ignore: avoid_print
      print('[Pet] PetService: Update response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = response.data['data'] ?? response.data;
          final petModel = PetModel.fromJson(responseData);
          return petModel.toEntity();
        } catch (parseError) {
          rethrow;
        }
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Pet update failed',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Update pet error: ${e.toString()}');
    }
  }

  /// Mark pet as adopted
  ///
  /// Updates pet status to adopted and assigns it to a user.
  /// Requires authentication.
  Future<PetEntity> adoptPet({
    required String petId,
    required String adoptedBy,
  }) async {
    return updatePet(
      petId: petId,
      isAdopted: true,
      adoptedBy: adoptedBy,
      status: 'adopted',
    );
  }

  /// Mark pet as available again
  ///
  /// Resets pet adoption status back to available.
  /// Requires authentication.
  Future<PetEntity> markAvailable({required String petId}) async {
    return updatePet(
      petId: petId,
      isAdopted: false,
      adoptedBy: null,
      status: 'available',
    );
  }

  /// Delete pet listing
  ///
  /// Permanently deletes a pet listing.
  /// Only the user who created the listing can delete it.
  /// Requires authentication.
  Future<void> deletePet({required String petId}) async {
    try {
      final normalizedId = petId.trim();
      if (normalizedId.isEmpty || normalizedId.toLowerCase() == 'null') {
        throw const ApiFailure(message: 'Invalid pet ID for deletion');
      }

      final response = await _apiService.deleteAuth(
        '$_itemsEndpoint/$normalizedId',
      );

      // Accept 200, 201, or 204 as successful deletion
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return;
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Pet deletion failed',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Delete pet error: ${e.toString()}');
    }
  }

  /// Upload pet photo
  ///
  /// Uploads a photo for a pet listing.
  /// Returns the filename of the uploaded image.
  Future<String> uploadPhoto({required String filePath}) async {
    try {
      // ignore: avoid_print
      print('📤 PetService: Starting upload for: $filePath');

      // Try authenticated upload first (admin flow), then public upload fallback.
      late final dynamic response;
      try {
        // ignore: avoid_print
        print('📤 PetService: Attempting authenticated upload...');
        response = await _apiService
            .uploadFileAuth(
              _uploadPhotoEndpoint,
              filePath: filePath,
              fieldName: 'media',
              timeout: const Duration(seconds: 20),
            )
            .timeout(
              const Duration(seconds: 20),
              onTimeout: () {
                throw ApiFailure(
                  message:
                      'Upload timed out after 20 seconds. Backend may not be responding.',
                  statusCode: 408,
                );
              },
            );
        // ignore: avoid_print
        print('[Success] PetService: Authenticated upload succeeded');
      } catch (authError) {
        // ignore: avoid_print
        print('[Warning] PetService: Auth upload failed: $authError');
        // ignore: avoid_print
        print('[Upload] PetService: Attempting public upload fallback...');
        response = await _apiService
            .uploadFile(
              _uploadPhotoEndpoint,
              filePath: filePath,
              fieldName: 'media',
              timeout: const Duration(seconds: 20),
            )
            .timeout(
              const Duration(seconds: 20),
              onTimeout: () {
                throw ApiFailure(
                  message:
                      'Upload timed out after 20 seconds. Backend may not be responding.',
                  statusCode: 408,
                );
              },
            );
        // ignore: avoid_print
        print('[Success] PetService: Public upload succeeded');
      }

      // ignore: avoid_print
      print(
        '[Upload] PetService: Upload response status: ${response.statusCode}',
      );
      // ignore: avoid_print
      print('[Upload] PetService: Upload response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final extracted = _extractMediaUrl(response.data);
        // ignore: avoid_print
        print('[Upload] PetService: Extracted URL: $extracted');

        if (extracted != null && extracted.isNotEmpty) {
          return _normalizeMediaForApi(extracted);
        }

        throw ApiFailure(message: 'No URL returned from upload');
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Photo upload failed',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      // ignore: avoid_print
      print('[Error] PetService: Upload error: $e');
      throw ApiFailure(message: 'Upload photo error: ${e.toString()}');
    }
  }

  String? _extractMediaUrl(dynamic data) {
    if (data == null) return null;

    if (data is String) {
      final value = data.trim();
      if (value.isEmpty) return null;
      // Guard against generic success messages being stored as media path.
      final lower = value.toLowerCase();
      if (lower.contains('success') && !value.contains('http')) {
        return null;
      }

      // Normalize stringified list values like: [https://...]
      if (value.startsWith('[') && value.endsWith(']')) {
        final inner = value.substring(1, value.length - 1).trim();
        if (inner.isNotEmpty) {
          return inner.replaceAll('"', '').replaceAll("'", '');
        }
      }
      return value;
    }

    if (data is List) {
      for (final item in data) {
        final candidate = _extractMediaUrl(item);
        if (candidate != null && candidate.isNotEmpty) return candidate;
      }
      return null;
    }

    if (data is Map) {
      final candidates = [
        data['data'],
        data['url'],
        data['media'],
        data['mediaUrl'],
        data['secure_url'],
        data['image'],
        data['file'],
      ];

      for (final candidate in candidates) {
        final extracted = _extractMediaUrl(candidate);
        if (extracted != null && extracted.isNotEmpty) return extracted;
      }

      return null;
    }

    return data.toString();
  }

  String _normalizeMediaForApi(String value) {
    var normalized = value.trim();
    if (normalized.startsWith('[') && normalized.endsWith(']')) {
      normalized = normalized.substring(1, normalized.length - 1).trim();
    }
    normalized = normalized.replaceAll('"', '').replaceAll("'", '').trim();
    return normalized;
  }

  /// Upload pet video
  ///
  /// Uploads a video for a pet listing.
  /// Returns the filename of the uploaded video.
  Future<String> uploadVideo({required String filePath}) async {
    try {
      final response = await _apiService.uploadFile(
        _uploadVideoEndpoint,
        filePath: filePath,
        fieldName: 'media',
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data['message'];
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Video upload failed',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Upload video error: ${e.toString()}');
    }
  }

  /// Search pets
  ///
  /// Searches for pets using filters (simplified wrapper for getAllPets).
  Future<List<PetEntity>> searchPets({
    String? type,
    String? categoryId,
    String? location,
  }) async {
    try {
      final result = await getAllPets(type: type, categoryId: categoryId);
      return result['pets'] ?? [];
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Search pets error: ${e.toString()}');
    }
  }
}
