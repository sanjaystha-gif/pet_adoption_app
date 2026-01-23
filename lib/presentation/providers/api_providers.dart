import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/core/services/api/api_service.dart';
import 'package:pet_adoption_app/core/services/api/auth_service.dart';
import 'package:pet_adoption_app/core/services/api/category_service.dart';
import 'package:pet_adoption_app/core/services/api/comment_service.dart';
import 'package:pet_adoption_app/core/services/api/pet_service.dart';
import 'package:pet_adoption_app/domain/entities/user_entity.dart';

// ==================== API SERVICE PROVIDERS ====================

/// Provides the main ApiService instance (singleton)
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Provides the AuthService with injected ApiService
final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthService(apiService: apiService);
});

/// Provides the PetService with injected ApiService
final petServiceProvider = Provider<PetService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PetService(apiService: apiService);
});

/// Provides the CategoryService with injected ApiService
final categoryServiceProvider = Provider<CategoryService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CategoryService(apiService: apiService);
});

/// Provides the CommentService with injected ApiService
final commentServiceProvider = Provider<CommentService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CommentService(apiService: apiService);
});

// ==================== AUTHENTICATION STATE PROVIDERS ====================

/// Tracks the current authenticated user (null if not authenticated)
/// Use this to manage user state after login/signup
class CurrentUserNotifier extends Notifier<UserEntity?> {
  @override
  UserEntity? build() {
    return null;
  }

  void setUser(UserEntity? user) {
    state = user;
  }
}

final currentUserProvider = NotifierProvider<CurrentUserNotifier, UserEntity?>(
  () {
    return CurrentUserNotifier();
  },
);

/// Login operation provider
final loginProvider =
    FutureProvider.family<UserEntity, ({String email, String password})>((
      ref,
      params,
    ) async {
      final authService = ref.watch(authServiceProvider);
      return await authService.login(
        email: params.email,
        password: params.password,
      );
    });

/// Signup operation provider
final signupProvider =
    FutureProvider.family<
      UserEntity,
      ({
        String name,
        String email,
        String username,
        String password,
        String phoneNumber,
        String batchId,
      })
    >((ref, params) async {
      final authService = ref.watch(authServiceProvider);
      return await authService.signup(
        name: params.name,
        email: params.email,
        username: params.username,
        password: params.password,
        phoneNumber: params.phoneNumber,
        batchId: params.batchId,
      );
    });

/// Logout operation provider
final logoutProvider = FutureProvider((ref) async {
  final authService = ref.watch(authServiceProvider);
  await authService.logout();
});

/// Update user profile provider
final updateProfileProvider =
    FutureProvider.family<
      UserEntity,
      ({
        String userId,
        String? name,
        String? email,
        String? phoneNumber,
        String? profilePicture,
      })
    >((ref, params) async {
      final authService = ref.watch(authServiceProvider);
      return await authService.updateProfile(
        userId: params.userId,
        name: params.name,
        email: params.email,
        phoneNumber: params.phoneNumber,
        profilePicture: params.profilePicture,
      );
    });

/// Get user by ID provider
final getUserProvider = FutureProvider.family<UserEntity, String>((
  ref,
  userId,
) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getUserById(userId: userId);
});

/// Check if user is authenticated
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.isAuthenticated();
});

// ==================== PET/ITEM STATE PROVIDERS ====================

/// Provides all pets with pagination
final petsProvider =
    FutureProvider.family<
      Map<String, dynamic>,
      ({int page, int limit, String? type, String? categoryId})
    >((ref, params) async {
      final petService = ref.watch(petServiceProvider);
      return await petService.getAllPets(
        page: params.page,
        limit: params.limit,
        type: params.type,
        categoryId: params.categoryId,
      );
    });

/// Provides a single pet by ID
final petDetailProvider = FutureProvider.family<dynamic, String>((
  ref,
  petId,
) async {
  final petService = ref.watch(petServiceProvider);
  return await petService.getPetById(petId: petId);
});

/// Creates a new pet (mutation)
final createPetProvider = FutureProvider.family<dynamic, Map<String, dynamic>>((
  ref,
  petData,
) async {
  final petService = ref.watch(petServiceProvider);
  return await petService.createPet(
    name: petData['name'],
    description: petData['description'],
    type: petData['type'],
    categoryId: petData['categoryId'],
    location: petData['location'],
    mediaUrl: petData['mediaUrl'],
    mediaType: petData['mediaType'],
    breed: petData['breed'],
    age: petData['age'],
    gender: petData['gender'],
    size: petData['size'],
    healthStatus: petData['healthStatus'],
    userId: petData['userId'],
  );
});

/// Updates a pet (mutation)
final updatePetProvider = FutureProvider.family<dynamic, Map<String, dynamic>>((
  ref,
  params,
) async {
  final petService = ref.watch(petServiceProvider);
  return await petService.updatePet(
    petId: params['petId'],
    name: params['name'],
    description: params['description'],
    type: params['type'],
    categoryId: params['categoryId'],
    location: params['location'],
    mediaUrl: params['mediaUrl'],
    mediaType: params['mediaType'],
    isAdopted: params['isAdopted'],
    status: params['status'],
  );
});

// ==================== CATEGORY STATE PROVIDERS ====================

/// Provides all categories
final categoriesProvider = FutureProvider<List<dynamic>>((ref) async {
  final categoryService = ref.watch(categoryServiceProvider);
  return await categoryService.getAllCategories();
});

/// Provides a single category by ID
final categoryDetailProvider = FutureProvider.family<dynamic, String>((
  ref,
  categoryId,
) async {
  final categoryService = ref.watch(categoryServiceProvider);
  return await categoryService.getCategoryById(categoryId: categoryId);
});

// ==================== COMMENT STATE PROVIDERS ====================

/// Provides comments for a specific pet
final petCommentsProvider =
    FutureProvider.family<List<dynamic>, ({String petId, int page, int limit})>(
      (ref, params) async {
        final commentService = ref.watch(commentServiceProvider);
        return await commentService.getCommentsByPet(
          petId: params.petId,
          page: params.page,
          limit: params.limit,
        );
      },
    );

/// Creates a new comment (mutation)
final createCommentProvider =
    FutureProvider.family<dynamic, Map<String, dynamic>>((
      ref,
      commentData,
    ) async {
      final commentService = ref.watch(commentServiceProvider);
      return await commentService.createComment(
        petId: commentData['petId'],
        text: commentData['text'],
        rating: commentData['rating'],
        authorId: commentData['authorId'],
      );
    });

// ==================== FILE UPLOAD STATE PROVIDERS ====================

/// Uploads pet photo (mutation)
final uploadPhotoProvider = FutureProvider.family<String, String>((
  ref,
  filePath,
) async {
  final petService = ref.watch(petServiceProvider);
  return await petService.uploadPhoto(filePath: filePath);
});

/// Uploads pet video (mutation)
final uploadVideoProvider = FutureProvider.family<String, String>((
  ref,
  filePath,
) async {
  final petService = ref.watch(petServiceProvider);
  return await petService.uploadVideo(filePath: filePath);
});

/// Uploads user profile picture (mutation)
final uploadProfilePictureProvider = FutureProvider.family<String, String>((
  ref,
  filePath,
) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.uploadProfilePicture(filePath: filePath);
});

// ==================== SEARCH & FILTER STATE PROVIDERS ====================

/// Provides search results for pets
final searchPetsProvider =
    FutureProvider.family<List<dynamic>, ({String? type, String? categoryId})>((
      ref,
      params,
    ) async {
      final petService = ref.watch(petServiceProvider);
      return await petService.searchPets(
        type: params.type,
        categoryId: params.categoryId,
      );
    });
