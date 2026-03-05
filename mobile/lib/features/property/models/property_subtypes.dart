class ApartmentData {
  final String? propertyId;
  final int bedrooms;
  final int bathrooms;
  final int floor;
  final bool hasElevator;

  const ApartmentData({
    this.propertyId,
    required this.bedrooms,
    required this.bathrooms,
    required this.floor,
    required this.hasElevator,
  });

  factory ApartmentData.fromJson(Map<String, dynamic> j) => ApartmentData(
    propertyId: j['propertyId']?.toString(),
    bedrooms: (j['bedrooms'] as num?)?.toInt() ?? 0,
    bathrooms: (j['bathrooms'] as num?)?.toInt() ?? 0,
    floor: (j['floor'] as num?)?.toInt() ?? 0,
    hasElevator: j['hasElevator'] as bool? ?? false,
  );

  Map<String, dynamic> toCreateJson() => {
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'floor': floor,
    'hasElevator': hasElevator,
  };
}

class HouseData {
  final String? propertyId;
  final int bedrooms;
  final int bathrooms;
  final bool hasGarage;
  final double? landAreaSqm;

  const HouseData({
    this.propertyId,
    required this.bedrooms,
    required this.bathrooms,
    required this.hasGarage,
    this.landAreaSqm,
  });

  factory HouseData.fromJson(Map<String, dynamic> j) => HouseData(
    propertyId: j['propertyId']?.toString(),
    bedrooms: (j['bedrooms'] as num?)?.toInt() ?? 0,
    bathrooms: (j['bathrooms'] as num?)?.toInt() ?? 0,
    hasGarage: j['hasGarage'] as bool? ?? false,
    landAreaSqm: (j['landAreaSqm'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toCreateJson() => {
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'hasGarage': hasGarage,
    if (landAreaSqm != null) 'landAreaSqm': landAreaSqm,
  };
}

class VillaData {
  final String? propertyId;
  final int bedrooms;
  final int bathrooms;
  final double? landAreaSqm;
  final bool hasPool;

  const VillaData({
    this.propertyId,
    required this.bedrooms,
    required this.bathrooms,
    this.landAreaSqm,
    required this.hasPool,
  });

  factory VillaData.fromJson(Map<String, dynamic> j) => VillaData(
    propertyId: j['propertyId']?.toString(),
    bedrooms: (j['bedrooms'] as num?)?.toInt() ?? 0,
    bathrooms: (j['bathrooms'] as num?)?.toInt() ?? 0,
    landAreaSqm: (j['landAreaSqm'] as num?)?.toDouble(),
    hasPool: j['hasPool'] as bool? ?? false,
  );

  Map<String, dynamic> toCreateJson() => {
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    if (landAreaSqm != null) 'landAreaSqm': landAreaSqm,
    'hasPool': hasPool,
  };
}

class StudioData {
  final String? propertyId;
  final bool furnished;

  const StudioData({this.propertyId, required this.furnished});

  factory StudioData.fromJson(Map<String, dynamic> j) => StudioData(
    propertyId: j['propertyId']?.toString(),
    furnished: j['furnished'] as bool? ?? false,
  );

  Map<String, dynamic> toCreateJson() => {'furnished': furnished};
}

class CommercialData {
  final String? propertyId;
  final double? areaSqm;
  final String? businessType;

  const CommercialData({this.propertyId, this.areaSqm, this.businessType});

  factory CommercialData.fromJson(Map<String, dynamic> j) => CommercialData(
    propertyId: j['propertyId']?.toString(),
    areaSqm: (j['areaSqm'] as num?)?.toDouble(),
    businessType: j['businessType']?.toString(),
  );

  Map<String, dynamic> toCreateJson() => {
    if (areaSqm != null) 'areaSqm': areaSqm,
    if (businessType != null && businessType!.isNotEmpty)
      'businessType': businessType,
  };
}

class LandData {
  final String? propertyId;
  final double? areaSqm;
  final bool constructible;

  const LandData({this.propertyId, this.areaSqm, required this.constructible});

  factory LandData.fromJson(Map<String, dynamic> j) => LandData(
    propertyId: j['propertyId']?.toString(),
    areaSqm: (j['areaSqm'] as num?)?.toDouble(),
    constructible: j['constructible'] as bool? ?? false,
  );

  Map<String, dynamic> toCreateJson() => {
    if (areaSqm != null) 'areaSqm': areaSqm,
    'constructible': constructible,
  };
}
