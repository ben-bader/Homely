import '../../../domain/entities/property_view/property_view_entity.dart';

class PropertyViewModel extends PropertyViewEntity {
  const PropertyViewModel({
    required super.id,
    super.userId,
    required super.propertyId,
    super.ipAddress,
  });

  factory PropertyViewModel.fromJson(Map<String, dynamic> json) =>
      PropertyViewModel(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString(),
        propertyId: json['propertyId']?.toString() ?? '',
        ipAddress: json['ipAddress']?.toString(),
      );
}
