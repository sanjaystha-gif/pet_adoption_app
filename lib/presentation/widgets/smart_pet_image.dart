import 'package:flutter/material.dart';
import 'package:pet_adoption_app/core/services/api/api_service.dart';

/// A widget that intelligently displays pet images from network URLs (like Cloudinary)
/// or local assets with automatic fallback handling.
class SmartPetImage extends StatelessWidget {
  final String? imageSource;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;

  const SmartPetImage({
    super.key,
    this.imageSource,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    var source = (imageSource ?? '').trim();

    // Handle values persisted as stringified arrays/maps, e.g. "[https://...]".
    if (source.startsWith('[') && source.endsWith(']')) {
      source = source.substring(1, source.length - 1).trim();
    }
    source = source.replaceAll('"', '').replaceAll("'", '').trim();

    // Backend can return relative upload paths like "/uploads/x.jpg".
    // Convert them to absolute URLs so they are rendered as network images.
    if (_looksLikeRelativeBackendPath(source)) {
      source = _toAbsoluteBackendUrl(source);
    }

    // Default fallback widget
    final fallback =
        errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Icon(Icons.pets, size: 48, color: Colors.grey[400]),
        );

    // Empty or null source
    if (source.isEmpty) {
      return _buildAssetImage('assets/images/main_logo.png', fallback);
    }

    // Network URL (Cloudinary or any http/https URL)
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            _buildAssetImage('assets/images/main_logo.png', fallback),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey[100],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    }

    // Local asset path
    String assetPath;
    if (source.startsWith('assets/')) {
      assetPath = source;
    } else {
      assetPath = 'assets/images/$source';
    }

    return _buildAssetImage(assetPath, fallback);
  }

  bool _looksLikeRelativeBackendPath(String source) {
    if (source.isEmpty) return false;
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return false;
    }
    return source.startsWith('/') || source.startsWith('uploads/');
  }

  String _toAbsoluteBackendUrl(String source) {
    final base = Uri.parse(ApiService.baseUrl);
    final hostRoot =
        '${base.scheme}://${base.host}${base.hasPort ? ':${base.port}' : ''}';
    final normalizedPath = source.startsWith('/') ? source : '/$source';
    return '$hostRoot$normalizedPath';
  }

  Widget _buildAssetImage(String path, Widget fallback) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
