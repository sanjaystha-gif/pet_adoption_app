import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/features/admin/presentation/notifiers/admin_auth_notifier.dart';
import 'package:pet_adoption_app/features/auth/domain/entities/auth_entity.dart';
import 'package:pet_adoption_app/features/auth/presentation/notifiers/auth_notifier.dart';

void main() {
  group('AuthState', () {
    test('starts with expected defaults', () {
      final state = AuthState();

      expect(state.isLoading, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
      expect(state.error, isNull);
    });

    test('copyWith updates selected fields', () {
      final initial = AuthState();
      final user = AuthEntity(
        authId: 'u1',
        firstName: 'Sam',
        lastName: 'Doe',
        email: 'sam@example.com',
      );

      final updated = initial.copyWith(
        isAuthenticated: true,
        user: user,
        error: 'none',
      );

      expect(updated.isAuthenticated, isTrue);
      expect(updated.user, equals(user));
      expect(updated.error, 'none');
      expect(updated.isLoading, isFalse);
    });

    test('copyWith preserves fields when null args passed', () {
      final user = AuthEntity(
        authId: 'u2',
        firstName: 'Alex',
        lastName: 'Ray',
        email: 'alex@example.com',
      );
      final initial = AuthState(
        isLoading: true,
        isAuthenticated: true,
        user: user,
        error: 'error',
      );

      final copy = initial.copyWith();
      expect(copy.isLoading, isTrue);
      expect(copy.isAuthenticated, isTrue);
      expect(copy.user, equals(user));
      expect(copy.error, isNull);
    });

    test('copyWith can clear error by passing null explicitly', () {
      final initial = AuthState(error: 'bad request');

      final cleared = initial.copyWith(error: null);
      expect(cleared.error, isNull);
    });
  });

  group('AdminAuthState', () {
    test('starts with expected defaults', () {
      final state = AdminAuthState();

      expect(state.isLoading, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.isAdmin, isFalse);
      expect(state.user, isNull);
      expect(state.error, isNull);
    });

    test('copyWith updates selected fields', () {
      final user = AuthEntity(
        authId: 'admin-1',
        firstName: 'Admin',
        lastName: 'User',
        email: 'admin@example.com',
      );
      final state = AdminAuthState();

      final updated = state.copyWith(
        isAuthenticated: true,
        isAdmin: true,
        user: user,
      );

      expect(updated.isAuthenticated, isTrue);
      expect(updated.isAdmin, isTrue);
      expect(updated.user, equals(user));
      expect(updated.error, isNull);
    });
  });
}
