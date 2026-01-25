import 'package:pet_adoption_app/domain/entities/comment_entity.dart';

class CommentModel {
  final String id;
  final String text;
  final String authorId;
  final String authorName;
  final String? authorProfilePicture;
  final String petId;
  final int rating;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CommentModel({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorName,
    this.authorProfilePicture,
    required this.petId,
    required this.rating,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert from JSON response from API
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'] ?? json['id'] ?? '',
      text: json['text'] ?? json['comment'] ?? '',
      authorId: json['authorId'] is Map
          ? json['authorId']['_id'] ?? json['authorId']['id'] ?? ''
          : json['authorId'] ?? '',
      authorName: json['authorId'] is Map
          ? json['authorId']['name'] ?? ''
          : json['authorName'] ?? '',
      authorProfilePicture: json['authorId'] is Map
          ? json['authorId']['profilePicture']
          : json['authorProfilePicture'],
      petId: json['itemId'] ?? json['petId'] ?? '',
      rating: json['rating'] is int
          ? json['rating']
          : int.tryParse(json['rating'].toString()) ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'comment': text,
      'rating': rating,
      'itemId': petId,
      'petId': petId,
      'authorId': authorId,
    };
  }

  /// Convert to Entity
  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      text: text,
      authorId: authorId,
      authorName: authorName,
      authorProfilePicture: authorProfilePicture,
      petId: petId,
      rating: rating,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
