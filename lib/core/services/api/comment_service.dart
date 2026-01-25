import 'package:pet_adoption_app/core/error/failure.dart';
import 'package:pet_adoption_app/core/services/api/api_service.dart';
import 'package:pet_adoption_app/data/models/comment_model.dart';
import 'package:pet_adoption_app/domain/entities/comment_entity.dart';

/// Comment Service
///
/// Manages comments and reviews on pet listings.
/// Provides methods to:
/// - Create comments/reviews
/// - Retrieve comments for a pet
/// - Update own comments
/// - Delete own comments
class CommentService {
  final ApiService _apiService;

  static const String _commentsEndpoint = '/comments';

  CommentService({required ApiService apiService}) : _apiService = apiService;

  /// Create a comment/review on a pet
  ///
  /// Adds a new comment/review to a pet listing.
  /// Requires authentication.
  Future<CommentEntity> createComment({
    required String petId,
    required String text,
    required int rating,
    required String authorId,
  }) async {
    try {
      final response = await _apiService.postAuth(
        _commentsEndpoint,
        data: {
          'itemId': petId,
          'petId': petId,
          'text': text,
          'comment': text,
          'rating': rating,
          'authorId': authorId,
        },
      );

      if (response.statusCode == 201) {
        final commentModel = CommentModel.fromJson(
          response.data['data'] ?? response.data,
        );
        return commentModel.toEntity();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Comment creation failed',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Create comment error: ${e.toString()}');
    }
  }

  /// Get all comments for a pet
  ///
  /// Retrieves all comments/reviews for a specific pet listing.
  /// Supports pagination.
  Future<List<CommentEntity>> getCommentsByPet({
    required String petId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        _commentsEndpoint,
        queryParameters: {
          'itemId': petId,
          'petId': petId,
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> comments = response.data['data'] ?? response.data;
        return comments
            .map((comment) => CommentModel.fromJson(comment).toEntity())
            .toList();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Failed to fetch comments',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Get comments by pet error: ${e.toString()}');
    }
  }

  /// Get comment by ID
  ///
  /// Retrieves a specific comment's details.
  Future<CommentEntity> getCommentById({required String commentId}) async {
    try {
      final response = await _apiService.get('$_commentsEndpoint/$commentId');

      if (response.statusCode == 200) {
        final commentModel = CommentModel.fromJson(
          response.data['data'] ?? response.data,
        );
        return commentModel.toEntity();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Comment not found',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Get comment by ID error: ${e.toString()}');
    }
  }

  /// Update a comment
  ///
  /// Updates the user's own comment/review.
  /// Only the comment author can update it.
  /// Requires authentication.
  Future<CommentEntity> updateComment({
    required String commentId,
    String? text,
    int? rating,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (text != null) {
        data['text'] = text;
        data['comment'] = text;
      }
      if (rating != null) data['rating'] = rating;

      final response = await _apiService.putAuth(
        '$_commentsEndpoint/$commentId',
        data: data,
      );

      if (response.statusCode == 200) {
        final commentModel = CommentModel.fromJson(
          response.data['data'] ?? response.data,
        );
        return commentModel.toEntity();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Comment update failed',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Update comment error: ${e.toString()}');
    }
  }

  /// Delete a comment
  ///
  /// Permanently deletes a comment.
  /// Only the comment author or admin can delete it.
  /// Requires authentication.
  Future<void> deleteComment({required String commentId}) async {
    try {
      final response = await _apiService.deleteAuth(
        '$_commentsEndpoint/$commentId',
      );

      if (response.statusCode != 200) {
        throw ApiFailure(
          message: response.data['message'] ?? 'Comment deletion failed',
          statusCode: response.statusCode,
        );
      }
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Delete comment error: ${e.toString()}');
    }
  }

  /// Get comments by user
  ///
  /// Retrieves all comments made by a specific user.
  Future<List<CommentEntity>> getCommentsByUser({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        _commentsEndpoint,
        queryParameters: {'authorId': userId, 'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> comments = response.data['data'] ?? response.data;
        return comments
            .map((comment) => CommentModel.fromJson(comment).toEntity())
            .toList();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Failed to fetch user comments',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Get comments by user error: ${e.toString()}');
    }
  }

  /// Get all comments (Admin only)
  ///
  /// Retrieves all comments in the system.
  /// Requires admin authentication.
  Future<List<CommentEntity>> getAllComments({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.getAuth(
        _commentsEndpoint,
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> comments = response.data['data'] ?? response.data;
        return comments
            .map((comment) => CommentModel.fromJson(comment).toEntity())
            .toList();
      }

      throw ApiFailure(
        message: response.data['message'] ?? 'Failed to fetch comments',
        statusCode: response.statusCode,
      );
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFailure(message: 'Get all comments error: ${e.toString()}');
    }
  }
}
