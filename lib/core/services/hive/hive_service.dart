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
    debugPrint('HiveService: Saving authData - authId: ${user.authId}, name: ${user.firstName} ${user.lastName}');
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
    debugPrint('HiveService: getAuthData - authId: ${user?.authId}, name: ${user?.firstName} ${user?.lastName}, email: ${user?.email}');
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

  /// Save profile picture URL/path for a given user id
  Future<void> saveProfilePicture(String authId, String imagePath) async {
    final box = await Hive.openBox<String>('profile_pictures');
    await box.put(authId, imagePath);
    // Also store under the active user key so UI that reads the active
    // record can still find the image when authId is missing or 'unknown'.
    await box.put(HiveTableConstant.userTable, imagePath);
    debugPrint(
      'HiveService: saved profile picture for $authId -> $imagePath (also saved as active)',
    );
  }

  /// Get saved profile picture for a given user id
  Future<String?> getProfilePicture(String authId) async {
    final box = await Hive.openBox<String>('profile_pictures');
    // Try per-user first
    var val = box.get(authId);
    if (val == null) {
      // Fallback to active user's saved picture
      val = box.get(HiveTableConstant.userTable);
      debugPrint(
        'HiveService: loaded profile picture for $authId -> null, fallback active -> $val',
      );
    } else {
      debugPrint('HiveService: loaded profile picture for $authId -> $val');
    }
    return val;
  }

  /// Remove saved profile picture for a given user id
  Future<void> deleteProfilePicture(String authId) async {
    final box = await Hive.openBox<String>('profile_pictures');
    await box.delete(authId);
    debugPrint('HiveService: deleted profile picture for $authId');
  }
}
