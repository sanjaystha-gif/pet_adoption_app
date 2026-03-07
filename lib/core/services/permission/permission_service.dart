import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request camera permission (camera + photos if needed)
  static Future<PermissionStatus> requestCamera() async {
    final statuses = await [Permission.camera, Permission.photos].request();
    return statuses[Permission.camera] ?? PermissionStatus.denied;
  }

  /// Request storage / photo access for picking from gallery
  static Future<PermissionStatus> requestPhotos() async {
    // On Android 13+ Permission.photos is mapped to READ_MEDIA_IMAGES/VIDEO
    final status = await Permission.photos.request();
    if (status.isGranted) return status;

    final storageStatus = await Permission.storage.request();
    return storageStatus;
  }

  /// Request microphone (for recording video with audio)
  static Future<PermissionStatus> requestMicrophone() async {
    return await Permission.microphone.request();
  }

  /// Open app settings so user can enable permissions manually
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Helper to check if permission is effectively granted
  static bool isGranted(PermissionStatus status) => status.isGranted;
}
