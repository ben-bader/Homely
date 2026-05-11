class FavoriteEntity {
  final String id;
  final String userId;
  final String propertyId;
  final String? mediaId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FavoriteEntity({
    required this.id,
    required this.userId,
    required this.propertyId,
    this.mediaId,
    this.createdAt,
    this.updatedAt,
  });
}
