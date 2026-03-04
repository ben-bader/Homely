class PropertyView {
  final String id;
  final String? userId;
  final String propertyId;
  final String? ipAddress;

  const PropertyView({
    required this.id,
    this.userId,
    required this.propertyId,
    this.ipAddress,
  });

  factory PropertyView.fromJson(Map<String, dynamic> json) => PropertyView(
    id: json['id']?.toString() ?? '',
    userId: json['userId']?.toString(),
    propertyId: json['propertyId']?.toString() ?? '',
    ipAddress: json['ipAddress']?.toString(),
  );
}
