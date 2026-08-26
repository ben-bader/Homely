class ApartmentDataEntity {
  final String? propertyId;
  final int bedrooms;
  final int bathrooms;
  final int floor;
  final bool hasElevator;

  const ApartmentDataEntity({
    this.propertyId,
    required this.bedrooms,
    required this.bathrooms,
    required this.floor,
    required this.hasElevator,
  });
}

class HouseDataEntity {
  final String? propertyId;
  final int bedrooms;
  final int bathrooms;
  final bool hasGarage;
  final double? landAreaSqm;

  const HouseDataEntity({
    this.propertyId,
    required this.bedrooms,
    required this.bathrooms,
    required this.hasGarage,
    this.landAreaSqm,
  });
}

class VillaDataEntity {
  final String? propertyId;
  final int bedrooms;
  final int bathrooms;
  final double? landAreaSqm;
  final bool hasPool;

  const VillaDataEntity({
    this.propertyId,
    required this.bedrooms,
    required this.bathrooms,
    this.landAreaSqm,
    required this.hasPool,
  });
}

class StudioDataEntity {
  final String? propertyId;
  final bool furnished;

  const StudioDataEntity({this.propertyId, required this.furnished});
}

class CommercialDataEntity {
  final String? propertyId;
  final double? areaSqm;
  final String? businessType;

  const CommercialDataEntity(
      {this.propertyId, this.areaSqm, this.businessType});
}

class LandDataEntity {
  final String? propertyId;
  final double? areaSqm;
  final bool constructible;

  const LandDataEntity(
      {this.propertyId, this.areaSqm, required this.constructible});
}
