import 'package:pet_adoption_app/core/error/failure.dart';
import 'package:pet_adoption_app/core/services/api/api_service.dart';
import 'package:pet_adoption_app/data/models/category_model.dart';
import 'package:pet_adoption_app/domain/entities/category_entity.dart';

/// Category Service
///
/// Manages pet categories (e.g., Dog, Cat, Rabbit).
/// Provides methods to:
/// - Retrieve all categories
/// - Get specific category by ID
/// - Create category (admin only)
/// - Update category (admin only)
/// - Delete category (admin only)
class CategoryService {
  final ApiService _apiService;

  static const String _categoriesEndpoint = '/categories';

  CategoryService({required ApiService apiService}) : _apiService = apiService;

  /// Get all categories
  ///
  /// Retrieves the complete list of pet categories available in the system.
  Future<List<CategoryEntity>> getAllCategories() async {
    try {
      final response = await _apiService.get(_categoriesEndpoint);

      if (response.statusCode == 200) {
        final List<dynamic> categories = response.data['data'] ?? response.data;
        return categories
            .map((cat) => CategoryModel.fromJson(cat).toEntity())
            .toList();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Failed to fetch categories',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Get all categories error: ${e.toString()}');
    }
  }

  /// Get category by ID
  ///
  /// Retrieves details for a specific category.
  Future<CategoryEntity> getCategoryById({required String categoryId}) async {
    try {
      final response = await _apiService.get(
        '$_categoriesEndpoint/$categoryId',
      );

      if (response.statusCode == 200) {
        final categoryModel = CategoryModel.fromJson(
          response.data['data'] ?? response.data,
        );
        return categoryModel.toEntity();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Category not found',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Get category by ID error: ${e.toString()}');
    }
  }

  /// Create new category
  ///
  /// Creates a new pet category (admin only).
  /// Requires authentication.
  Future<CategoryEntity> createCategory({
    required String name,
    required String description,
    String? icon,
  }) async {
    try {
      final response = await _apiService.postAuth(
        _categoriesEndpoint,
        data: {'name': name, 'description': description, 'icon': icon},
      );

      if (response.statusCode == 201) {
        final categoryModel = CategoryModel.fromJson(
          response.data['data'] ?? response.data,
        );
        return categoryModel.toEntity();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Category creation failed',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Create category error: ${e.toString()}');
    }
  }

  /// Update category
  ///
  /// Updates an existing category (admin only).
  /// Only the fields you want to update need to be provided.
  /// Requires authentication.
  Future<CategoryEntity> updateCategory({
    required String categoryId,
    String? name,
    String? description,
    String? icon,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (icon != null) data['icon'] = icon;

      final response = await _apiService.putAuth(
        '$_categoriesEndpoint/$categoryId',
        data: data,
      );

      if (response.statusCode == 200) {
        final categoryModel = CategoryModel.fromJson(
          response.data['data'] ?? response.data,
        );
        return categoryModel.toEntity();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Category update failed',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Update category error: ${e.toString()}');
    }
  }

  /// Delete category
  ///
  /// Permanently deletes a category (admin only).
  /// Requires authentication.
  Future<void> deleteCategory({required String categoryId}) async {
    try {
      final response = await _apiService.deleteAuth(
        '$_categoriesEndpoint/$categoryId',
      );

      if (response.statusCode != 200) {
        throw ApiFailure(
          message: response.data['message'] ?? 'Category deletion failed',
          statusCode: response.statusCode,
        );
      }
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Delete category error: ${e.toString()}');
    }
  }
}
