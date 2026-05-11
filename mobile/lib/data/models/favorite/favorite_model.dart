import '../../../domain/entities/favorite/favorite_entity.dart';

class FavoriteModel extends FavoriteEntity {
  const FavoriteModel({
    required super.id,
    required super.userId,
    required super.propertyId,
    super.mediaId,
    super.createdAt,
    super.updatedAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) =>
      FavoriteModel(
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

  Map<String, dynamic> toJson() => {
        'propertyId': propertyId,
        if (mediaId != null) 'mediaId': mediaId,
      };
}
