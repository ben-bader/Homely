// Property subtype DTOs
class ApartmentDto {
  final String propertyId;
  final int bedrooms;
  final int bathrooms;
  final int floor;
  final bool hasElevator;

  ApartmentDto({
    required this.propertyId,
    required this.bedrooms,
    required this.bathrooms,
    required this.floor,
    required this.hasElevator,
  });

  factory ApartmentDto.fromJson(Map<String, dynamic> json) => ApartmentDto(
    propertyId: json['propertyId']?.toString() ?? '',
    bedrooms: json['bedrooms'] ?? 0,
    bathrooms: json['bathrooms'] ?? 0,
    floor: json['floor'] ?? 0,
    hasElevator: json['hasElevator'] ?? false,
  );
}

class HouseDto {
  final String propertyId;
  final int bedrooms;
  final int bathrooms;
  final bool hasGarage;
  final double? landAreaSqm;

  HouseDto({
    required this.propertyId,
    required this.bedrooms,
    required this.bathrooms,
    required this.hasGarage,
    this.landAreaSqm,
  });

  factory HouseDto.fromJson(Map<String, dynamic> json) => HouseDto(
    propertyId: json['propertyId']?.toString() ?? '',
    bedrooms: json['bedrooms'] ?? 0,
    bathrooms: json['bathrooms'] ?? 0,
    hasGarage: json['hasGarage'] ?? false,
    landAreaSqm: json['landAreaSqm']?.toDouble(),
  );
  
  int get garages => hasGarage ? 1 : 0;
}

class VillaDto {
  final String propertyId;
  final int bedrooms;
  final int bathrooms;
  final bool hasPool;
  final double? landAreaSqm;

  VillaDto({
    required this.propertyId,
    required this.bedrooms,
    required this.bathrooms,
    required this.hasPool,
    this.landAreaSqm,
  });

  factory VillaDto.fromJson(Map<String, dynamic> json) => VillaDto(
    propertyId: json['propertyId']?.toString() ?? '',
    bedrooms: json['bedrooms'] ?? 0,
    bathrooms: json['bathrooms'] ?? 0,
    hasPool: json['hasPool'] ?? false,
    landAreaSqm: json['landAreaSqm']?.toDouble(),
  );
}

class StudioDto {
  final String propertyId;
  final bool furnished;

  StudioDto({
    required this.propertyId,
    required this.furnished,
  });

  factory StudioDto.fromJson(Map<String, dynamic> json) => StudioDto(
    propertyId: json['propertyId']?.toString() ?? '',
    furnished: json['furnished'] ?? false,
  );
}

class CommercialDto {
  final String propertyId;
  final String businessType;
  final double? areaSqm;

  CommercialDto({
    required this.propertyId,
    required this.businessType,
    this.areaSqm,
  });

  factory CommercialDto.fromJson(Map<String, dynamic> json) => CommercialDto(
    propertyId: json['propertyId']?.toString() ?? '',
    businessType: json['businessType'] ?? '',
    areaSqm: json['areaSqm']?.toDouble(),
  );
}

class LandDto {
  final String propertyId;
  final double? areaSqm;
  final bool constructible;

  LandDto({
    required this.propertyId,
    this.areaSqm,
    required this.constructible,
  });

  factory LandDto.fromJson(Map<String, dynamic> json) => LandDto(
    propertyId: json['propertyId']?.toString() ?? '',
    areaSqm: json['areaSqm']?.toDouble(),
    constructible: json['constructible'] ?? false,
  );
}
