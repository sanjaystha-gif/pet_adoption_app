import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String text;
  final String authorId;
  final String authorName;
  final String? authorProfilePicture;
  final String petId;
  final int rating;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CommentEntity({
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

  @override
  List<Object?> get props => [
    id,
    text,
    authorId,
    authorName,
    authorProfilePicture,
    petId,
    rating,
    createdAt,
    updatedAt,
  ];
}
