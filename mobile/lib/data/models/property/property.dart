class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final String location;
  final String propertyType;
  final String listingType;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final List<String> images;
  final String status;
  final DateTime createdAt;
  final String ownerId;
  final String ownerName;
  final List<String> chips;
  final String sellerAvatar;
  final String sellerName;
  final String sellerAgency;
  final String sellerId;
  final double latitude;
  final double longitude;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.location,
    required this.propertyType,
    required this.listingType,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.images,
    required this.status,
    required this.createdAt,
    required this.ownerId,
    required this.ownerName,
    this.chips = const [],
    this.sellerAvatar = '',
    this.sellerName = '',
    this.sellerAgency = '',
    this.sellerId = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      location: json['location'] ?? '',
      propertyType: json['propertyType'] ?? '',
      listingType: json['listingType'] ?? '',
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      images: List<String>.from(json['images'] ?? []),
      status: json['status'] ?? 'ACTIVE',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? '',
      chips: List<String>.from(json['chips'] ?? []),
      sellerAvatar: json['sellerAvatar'] ?? '',
      sellerName: json['sellerName'] ?? '',
      sellerAgency: json['sellerAgency'] ?? '',
      sellerId: json['sellerId'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

enum ListingType { rent, sale }

enum PropertyStatus { active, inactive, sold, rented }
