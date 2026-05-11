enum MediaType { image, video }

class PropertyMedia {
  final String id;
  final String propertyId;
  final String url;
  final MediaType mediaType;
  final int displayOrder;
  final String thumbnailUrl;

  PropertyMedia({
    required this.id,
    required this.propertyId,
    required this.url,
    required this.mediaType,
    required this.displayOrder,
    this.thumbnailUrl = '',
  });

  factory PropertyMedia.fromJson(Map<String, dynamic> json) {
    return PropertyMedia(
      id: json['id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      url: json['url'] ?? '',
      mediaType: MediaType.values.firstWhere(
        (e) => e.name == json['mediaType'],
        orElse: () => MediaType.image,
      ),
      displayOrder: json['displayOrder'] ?? 0,
      thumbnailUrl: json['thumbnailUrl'] ?? '',
    );
  }
}
