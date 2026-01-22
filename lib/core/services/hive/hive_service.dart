import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    await box.put(HiveTableConstant.userTable, user);
  }

  /// Get saved authentication data
  Future<AuthHiveModel?> getAuthData() async {
    final box = await Hive.openBox<AuthHiveModel>(HiveTableConstant.userTable);
    return box.get(HiveTableConstant.userTable);
  }

  /// Clear authentication data
  Future<void> clearAuthData() async {
    final box = await Hive.openBox<AuthHiveModel>(HiveTableConstant.userTable);
    await box.delete(HiveTableConstant.userTable);
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
}
