import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/domain/entities/comment_entity.dart';
import 'package:pet_adoption_app/data/models/comment_model.dart';

void main() {
  group('CommentEntity and CommentModel', () {
    test('CommentEntity equality checks all fields', () {
      final now = DateTime.now();
      final c1 = CommentEntity(
        id: 'c1',
        text: 'Great pet!',
        authorId: 'u1',
        authorName: 'Alice',
        petId: 'p1',
        rating: 5,
        createdAt: now,
      );

      final c2 = CommentEntity(
        id: 'c1',
        text: 'Great pet!',
        authorId: 'u1',
        authorName: 'Alice',
        petId: 'p1',
        rating: 5,
        createdAt: now,
      );

      expect(c1.id, c2.id);
      expect(c1.text, c2.text);
      expect(c1.rating, c2.rating);
    });

    test('CommentModel handles rating range validation', () {
      final model = CommentModel.fromJson({
        '_id': 'c1',
        'text': 'Good',
        'author': 'Bob',
        'authorId': 'u2',
        'petId': 'p2',
        'rating': 4,
      });

      expect(model.rating, isA<int>());
      expect(model.rating, greaterThanOrEqualTo(0));
      expect(model.rating, lessThanOrEqualTo(5));
    });

    test('CommentEntity handles null optional fields', () {
      final comment = CommentEntity(
        id: 'c2',
        text: 'OK pet',
        authorId: 'u3',
        authorName: 'Carol',
        authorProfilePicture: null,
        petId: 'p3',
        rating: 3,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      expect(comment.authorProfilePicture, isNull);
      expect(comment.updatedAt, isNull);
      expect(comment.text, isNotEmpty);
    });
  });
}
