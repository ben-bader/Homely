import '../../../domain/entities/media/property_media_entity.dart';

class PropertyMediaModel extends PropertyMediaEntity {
  const PropertyMediaModel({
    required super.id,
    required super.propertyId,
    required super.mediaType,
    required super.url,
    super.thumbnailUrl,
    required super.displayOrder,
    required super.durationSeconds,
  });

  factory PropertyMediaModel.fromJson(Map<String, dynamic> json) =>
      PropertyMediaModel(
        id: json['id']?.toString() ?? '',
        propertyId: json['propertyId']?.toString() ?? '',
        mediaType:
            MediaTypeX.fromJson(json['mediaType']?.toString() ?? 'IMAGE'),
        url: json['url']?.toString() ?? '',
        thumbnailUrl: json['thumbnailUrl']?.toString(),
        displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
        durationSeconds:
            (json['durationSeconds'] as num?)?.toInt() ?? 0,
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
