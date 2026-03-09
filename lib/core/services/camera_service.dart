import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling camera operations and permissions
class CameraService {
  static final CameraService _instance = CameraService._internal();

  final ImagePicker _imagePicker = ImagePicker();

  CameraService._internal();

  factory CameraService() {
    return _instance;
  }

  /// Request camera permission
  /// Returns true if permission is granted, false otherwise
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Take photo using device camera
  /// Returns File object of the captured photo
  /// Returns null if user cancels or permission is denied
  Future<File?> takePicture() async {
    try {
      // Check permission first
      final hasPermission = await requestCameraPermission();
      if (!hasPermission) {
        debugPrint('[Error] [CameraService] Camera permission denied');
        return null;
      }

      debugPrint('[Camera] [CameraService] Launching camera...');

      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Compress to 85% quality
        preferredCameraDevice: CameraDevice.rear, // Use rear camera
      );

      if (photo != null) {
        final File photoFile = File(photo.path);
        debugPrint('[Success] [CameraService] Photo captured: ${photo.name}');
        return photoFile;
      } else {
        debugPrint('[Warning] [CameraService] Camera cancelled by user');
        return null;
      }
    } catch (e) {
      debugPrint('[Error] [CameraService] Error taking photo: $e');
      return null;
    }
  }

  /// Check if camera permission is already granted
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }
}
