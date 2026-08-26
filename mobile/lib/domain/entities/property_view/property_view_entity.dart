class PropertyViewEntity {
  final String id;
  final String? userId;
  final String propertyId;
  final String? ipAddress;

  const PropertyViewEntity({
    required this.id,
    this.userId,
    required this.propertyId,
    this.ipAddress,
  });
}
