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
  static const String _uploadPhotoEndpoint = '/items/upload-photo';
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
    required String userId, // postedBy/reportedBy
  }) async {
    try {
      final response = await _apiService.postAuth(
        _itemsEndpoint,
        data: {
          'itemName': name,
          'name': name,
          'description': description,
          'type': type,
          'species': 'dog',
          'category': categoryId,
          'location': location,
          'media': mediaUrl,
          'mediaUrl': mediaUrl,
          'mediaType': mediaType,
          'breed': breed ?? '',
          'age': age ?? 0,
          'gender': (gender ?? '').toLowerCase(),
          'size': size ?? '',
          'healthStatus': healthStatus ?? 'healthy',
          'postedBy': userId,
        },
      );

      if (response.statusCode == 201) {
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
    bool? isAdopted,
    String? adoptedBy,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) {
        data['itemName'] = name;
        data['name'] = name;
      }
      if (description != null) data['description'] = description;
      if (type != null) data['type'] = type;
      if (categoryId != null) data['category'] = categoryId;
      if (location != null) data['location'] = location;
      if (mediaUrl != null) {
        data['media'] = mediaUrl;
        data['mediaUrl'] = mediaUrl;
      }
      if (mediaType != null) data['mediaType'] = mediaType;
      if (breed != null) data['breed'] = breed;
      if (age != null) data['age'] = age;
      if (gender != null) data['gender'] = gender.toLowerCase();
      if (size != null) data['size'] = size;
      if (healthStatus != null) data['healthStatus'] = healthStatus;
      if (isAdopted != null) {
        data['isClaimed'] = isAdopted;
        data['isAdopted'] = isAdopted;
      }
      if (adoptedBy != null) {
        data['claimedBy'] = adoptedBy;
        data['adoptedBy'] = adoptedBy;
      }
      if (status != null) data['status'] = status;

      // ignore: avoid_print
      print('🔍 Updating pet $petId with data: $data');

      final response = await _apiService.putAuth(
        '$_itemsEndpoint/$petId',
        data: data,
      );

      // ignore: avoid_print
      print('✅ Pet update response: ${response.statusCode}');
      // ignore: avoid_print
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = response.data['data'] ?? response.data;
          // ignore: avoid_print
          print('🔄 Parsing response: $responseData');

          final petModel = PetModel.fromJson(responseData);
          // ignore: avoid_print
          print('✅ Successfully parsed pet model: ${petModel.name}');
          return petModel.toEntity();
        } catch (parseError) {
          // ignore: avoid_print
          print('❌ Parse error: $parseError');
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
      // ignore: avoid_print
      print('❌ Pet update error: $e');
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
      final response = await _apiService.deleteAuth('$_itemsEndpoint/$petId');

      if (response.statusCode != 200) {
        throw ApiFailure(
          message: response.data['message'] ?? 'Pet deletion failed',
          statusCode: response.statusCode,
        );
      }
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
      final response = await _apiService.uploadFile(
        _uploadPhotoEndpoint,
        filePath: filePath,
        fieldName: 'media',
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data['message'];
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Photo upload failed',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Upload photo error: ${e.toString()}');
    }
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
