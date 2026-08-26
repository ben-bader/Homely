import '../../../domain/entities/property/property_subtype_entities.dart';

class ApartmentDataModel extends ApartmentDataEntity {
  const ApartmentDataModel({
    super.propertyId,
    required super.bedrooms,
    required super.bathrooms,
    required super.floor,
    required super.hasElevator,
  });

  factory ApartmentDataModel.fromJson(Map<String, dynamic> j) =>
      ApartmentDataModel(
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

class HouseDataModel extends HouseDataEntity {
  const HouseDataModel({
    super.propertyId,
    required super.bedrooms,
    required super.bathrooms,
    required super.hasGarage,
    super.landAreaSqm,
  });

  factory HouseDataModel.fromJson(Map<String, dynamic> j) =>
      HouseDataModel(
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

class VillaDataModel extends VillaDataEntity {
  const VillaDataModel({
    super.propertyId,
    required super.bedrooms,
    required super.bathrooms,
    super.landAreaSqm,
    required super.hasPool,
  });

  factory VillaDataModel.fromJson(Map<String, dynamic> j) =>
      VillaDataModel(
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

class StudioDataModel extends StudioDataEntity {
  const StudioDataModel({super.propertyId, required super.furnished});

  factory StudioDataModel.fromJson(Map<String, dynamic> j) =>
      StudioDataModel(
        propertyId: j['propertyId']?.toString(),
        furnished: j['furnished'] as bool? ?? false,
      );

  Map<String, dynamic> toCreateJson() => {'furnished': furnished};
}

class CommercialDataModel extends CommercialDataEntity {
  const CommercialDataModel(
      {super.propertyId, super.areaSqm, super.businessType});

  factory CommercialDataModel.fromJson(Map<String, dynamic> j) =>
      CommercialDataModel(
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

class LandDataModel extends LandDataEntity {
  const LandDataModel(
      {super.propertyId, super.areaSqm, required super.constructible});

  factory LandDataModel.fromJson(Map<String, dynamic> j) =>
      LandDataModel(
        propertyId: j['propertyId']?.toString(),
        areaSqm: (j['areaSqm'] as num?)?.toDouble(),
        constructible: j['constructible'] as bool? ?? false,
      );

  Map<String, dynamic> toCreateJson() => {
        if (areaSqm != null) 'areaSqm': areaSqm,
        'constructible': constructible,
      };
}
