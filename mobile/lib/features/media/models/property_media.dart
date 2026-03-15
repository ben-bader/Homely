import 'dart:io';

// ── Media type ─────────────────────────────────────────────────────────────

enum MediaType {
  IMAGE,
  VIDEO;

  String toJson() => name.toUpperCase();

  static MediaType fromJson(String raw) {
    return MediaType.values.firstWhere(
      (e) => e.name.toUpperCase() == raw.toUpperCase(),
      orElse: () => MediaType.IMAGE,
    );
  }
}

// ── Property media ─────────────────────────────────────────────────────────

class PropertyMedia {
  final String id;
  final String propertyId;
  final MediaType mediaType;
  final String url;
  final String? thumbnailUrl;
  final int displayOrder;
  final int durationSeconds;

  const PropertyMedia({
    required this.id,
    required this.propertyId,
    required this.mediaType,
    required this.url,
    this.thumbnailUrl,
    required this.displayOrder,
    required this.durationSeconds,
  });

  bool get isVideo => mediaType == MediaType.VIDEO;
  bool get isImage => mediaType == MediaType.IMAGE;

  factory PropertyMedia.fromJson(Map<String, dynamic> json) => PropertyMedia(
        id: json['id']?.toString() ?? '',
        propertyId: json['propertyId']?.toString() ?? '',
        mediaType: MediaType.fromJson(json['mediaType']?.toString() ?? 'IMAGE'),
        url: json['url']?.toString() ?? '',
        thumbnailUrl: json['thumbnailUrl']?.toString(),
        displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
        durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'propertyId': propertyId,
        'mediaType': mediaType.toJson(),
        'url': url,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        'displayOrder': displayOrder,
        'durationSeconds': durationSeconds,
      };
}

// ── Request models ─────────────────────────────────────────────────────────

class PropertyMediaCreateRequest {
  final String propertyId;
  final MediaType mediaType;
  final String? url;
  final String? thumbnailUrl;
  final int displayOrder;
  final int durationSeconds;

  const PropertyMediaCreateRequest({
    required this.propertyId,
    required this.mediaType,
    this.url,
    this.thumbnailUrl,
    this.displayOrder = 0,
    this.durationSeconds = 0,
  });

  Map<String, dynamic> toJson() => {
        'propertyId': propertyId,
        'mediaType': mediaType.toJson(),
        if (url != null) 'url': url,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        'displayOrder': displayOrder,
        'durationSeconds': durationSeconds,
      };
}

class ImageUploadRequest {
  final String propertyId;
  final File file;
  final int displayOrder;

  const ImageUploadRequest({
    required this.propertyId,
    required this.file,
    required this.displayOrder,
  });
}

class VideoUploadRequest {
  final String propertyId;
  final File file;
  final int displayOrder;

  const VideoUploadRequest({
    required this.propertyId,
    required this.file,
    required this.displayOrder,
  });
}