class Favorite {
  final String id;
  final String userId;
  final String propertyId;
  final String? mediaId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Favorite({
    required this.id,
    required this.userId,
    required this.propertyId,
    this.mediaId,
    this.createdAt,
    this.updatedAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      userId: json['userId'] as String,
      propertyId: json['propertyId'] as String,
      mediaId: json['mediaId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      if (mediaId != null) 'mediaId': mediaId,
    };
  }
}