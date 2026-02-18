import 'property_subtypes.dart';

class Property {
  final String id;
  final String title;
  final String description;
  final String location;
  final double price;
  final String currency;
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
  
  // Subtype DTOs
  final ApartmentDto? apartment;
  final HouseDto? house;
  final VillaDto? villa;
  final StudioDto? studio;
  final CommercialDto? commercial;
  final LandDto? land;

  Property({
    required this.id,
    required this.title,
    this.description = '',
    required this.location,
    required this.price,
    this.currency = 'USD',
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
    this.apartment,
    this.house,
    this.villa,
    this.studio,
    this.commercial,
    this.land,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    // Extract subtype based on propertyType
    final propertyType = json['propertyType']?.toString().toUpperCase() ?? 'HOUSE';
    
    ApartmentDto? apartment;
    HouseDto? house;
    VillaDto? villa;
    StudioDto? studio;
    CommercialDto? commercial;
    LandDto? land;
    
    if (json['apartment'] != null) {
      apartment = ApartmentDto.fromJson(json['apartment']);
    }
    if (json['house'] != null) {
      house = HouseDto.fromJson(json['house']);
    }
    if (json['villa'] != null) {
      villa = VillaDto.fromJson(json['villa']);
    }
    if (json['studio'] != null) {
      studio = StudioDto.fromJson(json['studio']);
    }
    if (json['commercial'] != null) {
      commercial = CommercialDto.fromJson(json['commercial']);
    }
    if (json['land'] != null) {
      land = LandDto.fromJson(json['land']);
    }
    
    // Extract beds/baths from subtype if available
    int beds = 0;
    int baths = 0;
    int garages = 0;
    double sqm = 0;
    
    if (apartment != null) {
      beds = apartment.bedrooms;
      baths = apartment.bathrooms;
    } else if (house != null) {
      beds = house.bedrooms;
      baths = house.bathrooms;
      garages = house.hasGarage ? 1 : 0;
      sqm = house.landAreaSqm?.toDouble() ?? 0;
    } else if (villa != null) {
      beds = villa.bedrooms;
      baths = villa.bathrooms;
      sqm = villa.landAreaSqm?.toDouble() ?? 0;
    } else if (studio != null) {
      beds = 0; // Studio typically has no separate bedroom
      baths = 0; // Studio DTO doesn't have bathrooms field
    } else if (commercial != null) {
      sqm = commercial.areaSqm ?? 0;
    } else if (land != null) {
      sqm = land.areaSqm ?? 0;
    }
    
    // Fallback to direct fields if subtype not available
    beds = beds > 0 ? beds : (json['beds'] ?? 0);
    baths = baths > 0 ? baths : (json['baths'] ?? 0);
    garages = garages > 0 ? garages : (json['garages'] ?? 0);
    sqm = sqm > 0 ? sqm : ((json['sqm'] ?? 0).toDouble());
    
    return Property(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['address'] ?? json['location'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      type: json['propertyType']?.toString() ?? json['type'] ?? 'HOUSE',
      status: json['status']?.toString() ?? 'AVAILABLE',
      images: List<String>.from(json['images'] ?? []),
      beds: beds,
      baths: baths,
      garages: garages,
      sqm: sqm,
      sellerId: json['sellerId']?.toString() ?? '',
      sellerName: json['sellerName'] ?? '',
      sellerAgency: json['sellerAgency'] ?? '',
      sellerAvatar: json['sellerAvatar'],
      lat: json['latitude']?.toDouble() ?? json['lat']?.toDouble(),
      lng: json['longitude']?.toDouble() ?? json['lng']?.toDouble(),
      isFavorite: json['isFavorite'] ?? false,
      apartment: apartment,
      house: house,
      villa: villa,
      studio: studio,
      commercial: commercial,
      land: land,
    );
  }
}
