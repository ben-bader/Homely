enum MediaType { IMAGE, VIDEO }

extension MediaTypeX on MediaType {
  String toJson() => name.toUpperCase();

  static MediaType fromJson(String raw) => MediaType.values.firstWhere(
        (e) => e.name.toUpperCase() == raw.toUpperCase(),
        orElse: () => MediaType.IMAGE,
      );
}

class PropertyMediaEntity {
  final String id;
  final String propertyId;
  final MediaType mediaType;
  final String url;
  final String? thumbnailUrl;
  final int displayOrder;
  final int durationSeconds;

  const PropertyMediaEntity({
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
}
