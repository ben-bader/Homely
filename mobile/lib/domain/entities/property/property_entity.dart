import 'package:flutter/material.dart';
import 'property_subtype_entities.dart';

enum ListingType { rent, sell }

extension ListingTypeX on ListingType {
  String toJson() => name.toUpperCase();
  static ListingType fromJson(String raw) => ListingType.values.firstWhere(
        (e) => e.name.toUpperCase() == raw.toUpperCase(),
        orElse: () => ListingType.sell,
      );
  String get label => name[0].toUpperCase() + name.substring(1);
}

enum PropertyType { apartment, house, villa, studio, commercial, land }

extension PropertyTypeX on PropertyType {
  String toJson() => name.toUpperCase();
  static PropertyType fromJson(String raw) =>
      PropertyType.values.firstWhere(
        (e) => e.name.toUpperCase() == raw.toUpperCase(),
        orElse: () => PropertyType.apartment,
      );
  String get label => name[0].toUpperCase() + name.substring(1);
  IconData get icon {
    switch (this) {
      case PropertyType.apartment:
        return Icons.apartment_outlined;
      case PropertyType.house:
        return Icons.house_outlined;
      case PropertyType.villa:
        return Icons.villa_outlined;
      case PropertyType.studio:
        return Icons.chair_outlined;
      case PropertyType.commercial:
        return Icons.business_outlined;
      case PropertyType.land:
        return Icons.landscape_outlined;
    }
  }
}

enum PropertyStatus { available, suspended, draft }

extension PropertyStatusX on PropertyStatus {
  String toJson() => name.toUpperCase();
  static PropertyStatus fromJson(String raw) =>
      PropertyStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == raw.toUpperCase(),
        orElse: () => PropertyStatus.draft,
      );
  String get label => name[0].toUpperCase() + name.substring(1);
  Color get color {
    switch (this) {
      case PropertyStatus.available:
        return const Color(0xFFFF9800);
      case PropertyStatus.suspended:
        return const Color(0xFF2196F3);
      case PropertyStatus.draft:
        return const Color(0xFF9E9E9E);
    }
  }
}

class PropertyChip {
  final IconData icon;
  final String label;
  const PropertyChip({required this.icon, required this.label});
}

class PropertyEntity {
  final String id;
  final String? sellerId;
  final String sellerName;
  final String? sellerAgency;
  final String? sellerAvatar;
  final String title;
  final String description;
  final double price;
  final String currency;
  final ListingType listingType;
  final PropertyType propertyType;
  final PropertyStatus status;
  final String address;
  final double? latitude;
  final double? longitude;
  final List<String> images;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ApartmentDataEntity? apartment;
  final HouseDataEntity? house;
  final VillaDataEntity? villa;
  final StudioDataEntity? studio;
  final CommercialDataEntity? commercial;
  final LandDataEntity? land;

  const PropertyEntity({
    required this.id,
    this.sellerId,
    this.sellerName = '',
    this.sellerAgency,
    this.sellerAvatar,
    required this.title,
    this.description = '',
    required this.price,
    this.currency = 'USD',
    required this.listingType,
    required this.propertyType,
    required this.status,
    this.address = '',
    this.latitude,
    this.longitude,
    this.images = const [],
    this.createdAt,
    this.updatedAt,
    this.apartment,
    this.house,
    this.villa,
    this.studio,
    this.commercial,
    this.land,
  });

  String get location => address;

  List<PropertyChip> get chips {
    final r = <PropertyChip>[];
    if (apartment != null) {
      r.add(PropertyChip(
          icon: Icons.bed_outlined,
          label: '${apartment!.bedrooms} Beds'));
      r.add(PropertyChip(
          icon: Icons.bathtub_outlined,
          label: '${apartment!.bathrooms} Baths'));
      r.add(PropertyChip(
          icon: Icons.layers_outlined,
          label: 'Floor ${apartment!.floor}'));
      if (apartment!.hasElevator) {
        r.add(PropertyChip(
            icon: Icons.elevator_outlined, label: 'Elevator'));
      }
    } else if (house != null) {
      r.add(PropertyChip(
          icon: Icons.bed_outlined,
          label: '${house!.bedrooms} Beds'));
      r.add(PropertyChip(
          icon: Icons.bathtub_outlined,
          label: '${house!.bathrooms} Baths'));
      if (house!.landAreaSqm != null) {
        r.add(PropertyChip(
            icon: Icons.square_foot_outlined,
            label: '${house!.landAreaSqm!.toStringAsFixed(0)} m²'));
      }
    } else if (villa != null) {
      r.add(PropertyChip(
          icon: Icons.bed_outlined,
          label: '${villa!.bedrooms} Beds'));
      r.add(PropertyChip(
          icon: Icons.bathtub_outlined,
          label: '${villa!.bathrooms} Baths'));
      r.add(PropertyChip(
          icon: Icons.pool_outlined,
          label: villa!.hasPool ? 'Pool' : 'No Pool'));
    } else if (studio != null) {
      r.add(PropertyChip(
          icon: Icons.chair_outlined,
          label: studio!.furnished ? 'Furnished' : 'Unfurnished'));
    } else if (commercial != null) {
      if (commercial!.areaSqm != null) {
        r.add(PropertyChip(
            icon: Icons.square_foot_outlined,
            label:
                '${commercial!.areaSqm!.toStringAsFixed(0)} m²'));
      }
      if (commercial!.businessType != null) {
        r.add(PropertyChip(
            icon: Icons.business_outlined,
            label: commercial!.businessType!));
      }
    } else if (land != null) {
      if (land!.areaSqm != null) {
        r.add(PropertyChip(
            icon: Icons.square_foot_outlined,
            label: '${land!.areaSqm!.toStringAsFixed(0)} m²'));
      }
      r.add(PropertyChip(
          icon: Icons.construction_outlined,
          label: land!.constructible
              ? 'Constructible'
              : 'Non-constructible'));
    }
    return r;
  }
}
