import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet_adoption_app/core/constants/hive_table_constant.dart';
import 'package:pet_adoption_app/features/auth/data/models/auth_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  /// Initialize Hive
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init('${directory.path}/${HiveTableConstant.dbName}');

    _registerAdapters();
    await _openBoxes();
  }

  /// Register all Hive adapters
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.userTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  /// Open all required boxes
  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.userTable);
  }

  /// Close all Hive boxes
  Future<void> close() async {
    await Hive.close();
  }

  /// Save authentication data
  Future<void> saveAuthData(AuthHiveModel user) async {
    final box = await Hive.openBox<AuthHiveModel>(HiveTableConstant.userTable);
    // Persist the provided user under its authId (if available) so multiple
    // accounts can be cached locally. Also keep the legacy key so existing
    // callers that rely on getAuthData() continue to work and return the
    // currently active user.
    debugPrint(
      'HiveService: Saving authData - authId: ${user.authId}, name: ${user.firstName} ${user.lastName}',
    );
    if (user.authId != null && user.authId!.isNotEmpty) {
      await box.put(user.authId!, user);
    }
    await box.put(HiveTableConstant.userTable, user);
    debugPrint('HiveService: Auth data saved successfully');
  }

  /// Get saved authentication data
  Future<AuthHiveModel?> getAuthData() async {
    final box = await Hive.openBox<AuthHiveModel>(HiveTableConstant.userTable);
    final user = box.get(HiveTableConstant.userTable);
    debugPrint(
      'HiveService: getAuthData - authId: ${user?.authId}, name: ${user?.firstName} ${user?.lastName}, email: ${user?.email}',
    );
    return user;
  }

  /// Clear authentication data
  Future<void> clearAuthData() async {
    final box = await Hive.openBox<AuthHiveModel>(HiveTableConstant.userTable);
    // Only remove the active user reference. We intentionally avoid
    // deleting any per-user entries keyed by authId so cached accounts remain
    // available for quicker restores if needed.
    await box.delete(HiveTableConstant.userTable);
  }

  /// Delete authentication data (alias for clearAuthData)
  Future<void> deleteAuthData() async {
    await clearAuthData();
  }

  /// Save authentication token
  Future<void> saveToken(String token) async {
    final box = await Hive.openBox<String>('token_box');
    await box.put('auth_token', token);
  }

  /// Get saved authentication token
  Future<String?> getToken() async {
    final box = await Hive.openBox<String>('token_box');
    return box.get('auth_token');
  }

  /// Delete authentication token
  Future<void> deleteToken() async {
    final box = await Hive.openBox<String>('token_box');
    await box.delete('auth_token');
  }

  /// Save current authenticated user role (e.g., admin, adopter)
  Future<void> saveUserRole(String role) async {
    final box = await Hive.openBox<String>('token_box');
    await box.put('auth_role', role);
  }

  /// Get current authenticated user role
  Future<String?> getUserRole() async {
    final box = await Hive.openBox<String>('token_box');
    return box.get('auth_role');
  }

  /// Delete current authenticated user role
  Future<void> deleteUserRole() async {
    final box = await Hive.openBox<String>('token_box');
    await box.delete('auth_role');
  }

  /// Save profile picture URL/path for a given user id
  Future<void> saveProfilePicture(String authId, String imagePath) async {
    final box = await Hive.openBox<String>('profile_pictures');
    await box.put(authId, imagePath);
    debugPrint('HiveService: saved profile picture for $authId -> $imagePath');
  }

  /// Get saved profile picture for a given user id
  Future<String?> getProfilePicture(String authId) async {
    final box = await Hive.openBox<String>('profile_pictures');
    var val = box.get(authId);
    debugPrint('HiveService: loaded profile picture for $authId -> $val');
    return val;
  }

  /// Remove saved profile picture for a given user id
  Future<void> deleteProfilePicture(String authId) async {
    final box = await Hive.openBox<String>('profile_pictures');
    await box.delete(authId);
    debugPrint('HiveService: deleted profile picture for $authId');
  }

  /// Save biometric login preference for a specific user.
  Future<void> saveBiometricLoginEnabled(String authId, bool enabled) async {
    final box = await Hive.openBox<bool>('biometric_prefs');
    await box.put('biometric_enabled_$authId', enabled);
    debugPrint(
      'HiveService: biometric preference saved for $authId -> $enabled',
    );
  }

  /// Read biometric login preference for a specific user.
  Future<bool> isBiometricLoginEnabled(String authId) async {
    final box = await Hive.openBox<bool>('biometric_prefs');
    return box.get('biometric_enabled_$authId', defaultValue: false) ?? false;
  }

  /// Save token for biometric login (separate from regular token, not cleared on logout)
  Future<void> saveBiometricToken(
    String authId,
    String token,
    String role,
  ) async {
    final box = await Hive.openBox<String>('biometric_tokens');
    await box.put('token_$authId', token);
    await box.put('role_$authId', role);
    debugPrint('HiveService: saved biometric token for $authId');
  }

  /// Get saved biometric token for a specific user
  Future<Map<String, String>?> getBiometricToken(String authId) async {
    final box = await Hive.openBox<String>('biometric_tokens');
    final token = box.get('token_$authId');
    final role = box.get('role_$authId');

    if (token != null && role != null) {
      return {'token': token, 'role': role};
    }
    return null;
  }

  /// Delete biometric token for a specific user
  Future<void> deleteBiometricToken(String authId) async {
    final box = await Hive.openBox<String>('biometric_tokens');
    await box.delete('token_$authId');
    await box.delete('role_$authId');
    debugPrint('HiveService: deleted biometric token for $authId');
  }

  /// Save last logged in user ID (for biometric login after logout)
  Future<void> saveLastBiometricUser(String authId) async {
    final box = await Hive.openBox<String>('biometric_tokens');
    await box.put('last_user', authId);
  }

  /// Get last logged in user ID (for biometric login after logout)
  Future<String?> getLastBiometricUser() async {
    final box = await Hive.openBox<String>('biometric_tokens');
    return box.get('last_user');
  }
}
