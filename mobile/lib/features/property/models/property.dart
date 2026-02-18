class Property {
  final String id;
  final String title;
  final String location;
  final double price;
  final String type; 
  final String status; 
  final List<String> images;
  final int beds;
  final int baths;
  final int garages;
  final double sqm;
  final String sellerId;
  final String sellerName;
  final String sellerAgency;
  final String? sellerAvatar;
  final double? lat;
  final double? lng;
  bool isFavorite;

  Property({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.type,
    required this.status,
    required this.images,
    required this.beds,
    required this.baths,
    required this.garages,
    required this.sqm,
    required this.sellerId,
    required this.sellerName,
    required this.sellerAgency,
    this.sellerAvatar,
    this.lat,
    this.lng,
    this.isFavorite = false,
  });

  factory Property.fromJson(Map<String, dynamic> json) => Property(
    id: json['id'].toString(),
    title: json['title'] ?? '',
    location: json['location'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    type: json['type'] ?? 'House',
    status: json['status'] ?? 'buy',
    images: List<String>.from(json['images'] ?? []),
    beds: json['beds'] ?? 0,
    baths: json['baths'] ?? 0,
    garages: json['garages'] ?? 0,
    sqm: (json['sqm'] ?? 0).toDouble(),
    sellerId: json['sellerId']?.toString() ?? '',
    sellerName: json['sellerName'] ?? '',
    sellerAgency: json['sellerAgency'] ?? '',
    sellerAvatar: json['sellerAvatar'],
    lat: json['lat']?.toDouble(),
    lng: json['lng']?.toDouble(),
    isFavorite: json['isFavorite'] ?? false,
  );
}
