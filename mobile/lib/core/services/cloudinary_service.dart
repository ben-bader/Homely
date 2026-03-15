import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const _cloudName = 'dmnsrbaw9';
  static const _uploadPreset = 'homely_unsigned';

  // ── Supported extensions ──────────────────────────────────────────
  static const _imageExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'heic'];
  static const _videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'];

  // ── Public entry point — auto-detects type ────────────────────────
  Future<CloudinaryUploadResult> upload({
    required File file,
    required String propertyId,
    required int displayOrder,
  }) async {
    final ext = file.path.split('.').last.toLowerCase();

    if (_imageExtensions.contains(ext)) {
      return _uploadAs(
        file: file,
        propertyId: propertyId,
        displayOrder: displayOrder,
        resourceType: 'image',
        mediaType: CloudinaryMediaType.image,
      );
    } else if (_videoExtensions.contains(ext)) {
      return _uploadAs(
        file: file,
        propertyId: propertyId,
        displayOrder: displayOrder,
        resourceType: 'video',
        mediaType: CloudinaryMediaType.video,
      );
    } else {
      throw Exception('Unsupported file type: $ext');
    }
  }

  // ── Internal upload ───────────────────────────────────────────────
  Future<CloudinaryUploadResult> _uploadAs({
    required File file,
    required String propertyId,
    required int displayOrder,
    required String resourceType,   // 'image' or 'video'
    required CloudinaryMediaType mediaType,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload',
    );

    debugPrint('[Cloudinary] Uploading $resourceType → $uri');
    debugPrint('[Cloudinary] File: ${file.path}');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = 'properties/$propertyId'
      ..fields['public_id'] =
          '${propertyId}_${displayOrder}_${DateTime.now().millisecondsSinceEpoch}'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send().timeout(
      Duration(seconds: resourceType == 'video' ? 120 : 30),
    );
    final response = await http.Response.fromStream(streamed);

    debugPrint('[Cloudinary] Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final url = json['secure_url'] as String;
      // Cloudinary returns a thumbnail URL for videos
      final thumbnailUrl = mediaType == CloudinaryMediaType.video
          ? (json['secure_url'] as String).replaceAll(
              RegExp(r'\.(mp4|mov|avi|mkv|webm)$'), '.jpg')
          : null;

      debugPrint('[Cloudinary] ✅ $resourceType uploaded: $url');

      return CloudinaryUploadResult(
        url: url,
        thumbnailUrl: thumbnailUrl,
        mediaType: mediaType,
      );
    }

    throw Exception(
      'Cloudinary upload failed (${response.statusCode}): ${response.body}',
    );
  }
}

// ── Result model ──────────────────────────────────────────────────────────

enum CloudinaryMediaType { image, video }

class CloudinaryUploadResult {
  final String url;
  final String? thumbnailUrl;
  final CloudinaryMediaType mediaType;

  const CloudinaryUploadResult({
    required this.url,
    required this.mediaType,
    this.thumbnailUrl,
  });
}