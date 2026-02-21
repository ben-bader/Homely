import 'package:flutter/material.dart';

import 'property_subtypes.dart';

class Property {
  final String id;
  final String title;
  final String description;
  final String location;
  final double price;
  final String currency;
  final String type;       // propertyType
  final String listingType; // RENT | BUY
  final String status;
  final List<String> images;
  final String sellerId;
  final String sellerName;
  final String sellerAgency;
  final String? sellerAvatar;
  final double? lat;
  final double? lng;
  bool isFavorite;

  // Subtypes
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
    this.listingType = 'BUY',
    required this.status,
    required this.images,
    required this.sellerId,
    this.sellerName = '',
    this.sellerAgency = '',
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

  // ── Computed attributes based on subtype ──────────────────
  int get beds {
    if (apartment != null) return apartment!.bedrooms;
    if (house != null) return house!.bedrooms;
    if (villa != null) return villa!.bedrooms;
    return 0;
  }

  int get baths {
    if (apartment != null) return apartment!.bathrooms;
    if (house != null) return house!.bathrooms;
    if (villa != null) return villa!.bathrooms;
    return 0;
  }

  int get garages => house?.garages ?? 0;

  double get sqm {
    if (house != null) return house!.landAreaSqm ?? 0;
    if (villa != null) return villa!.landAreaSqm ?? 0;
    if (commercial != null) return commercial!.areaSqm ?? 0;
    if (land != null) return land!.areaSqm ?? 0;
    return 0;
  }

  int get floor => apartment?.floor ?? 0;
  bool get hasElevator => apartment?.hasElevator ?? false;
  bool get hasPool => villa?.hasPool ?? false;
  bool get hasGarage => house?.hasGarage ?? false;
  bool get furnished => studio?.furnished ?? false;
  bool get constructible => land?.constructible ?? false;
  String get businessType => commercial?.businessType ?? '';

  // ── Chips to show per type ────────────────────────────────
  List<_PropertyChipData> get chips {
    final t = type.toUpperCase();
    switch (t) {
      case 'APARTMENT':
        return [
          _PropertyChipData(icon: Icons.bed_outlined, label: '$beds Beds'),
          _PropertyChipData(icon: Icons.bathtub_outlined, label: '$baths Baths'),
          _PropertyChipData(icon: Icons.layers_outlined, label: 'Floor $floor'),
        ];
      case 'HOUSE':
        return [
          _PropertyChipData(icon: Icons.bed_outlined, label: '$beds Beds'),
          _PropertyChipData(icon: Icons.bathtub_outlined, label: '$baths Baths'),
          _PropertyChipData(icon: Icons.garage_outlined, label: hasGarage ? 'Garage' : 'No Garage'),
        ];
      case 'VILLA':
        return [
          _PropertyChipData(icon: Icons.bed_outlined, label: '$beds Beds'),
          _PropertyChipData(icon: Icons.bathtub_outlined, label: '$baths Baths'),
          _PropertyChipData(icon: Icons.pool_outlined, label: hasPool ? 'Pool' : 'No Pool'),
        ];
      case 'STUDIO':
        return [
          _PropertyChipData(icon: Icons.chair_outlined, label: furnished ? 'Furnished' : 'Unfurnished'),
          _PropertyChipData(icon: Icons.apartment_outlined, label: 'Studio'),
        ];
      case 'COMMERCIAL':
        return [
          _PropertyChipData(icon: Icons.store_outlined, label: businessType),
          _PropertyChipData(icon: Icons.square_foot_outlined, label: '${sqm.toInt()} sqm'),
        ];
      case 'LAND':
        return [
          _PropertyChipData(icon: Icons.landscape_outlined, label: '${sqm.toInt()} sqm'),
          _PropertyChipData(icon: Icons.build_outlined, label: constructible ? 'Constructible' : 'Non-constructible'),
        ];
      default:
        return [
          _PropertyChipData(icon: Icons.home_outlined, label: type),
        ];
    }
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    ApartmentDto? apartment;
    HouseDto? house;
    VillaDto? villa;
    StudioDto? studio;
    CommercialDto? commercial;
    LandDto? land;

    if (json['apartment'] != null) apartment = ApartmentDto.fromJson(json['apartment']);
    if (json['house'] != null) house = HouseDto.fromJson(json['house']);
    if (json['villa'] != null) villa = VillaDto.fromJson(json['villa']);
    if (json['studio'] != null) studio = StudioDto.fromJson(json['studio']);
    if (json['commercial'] != null) commercial = CommercialDto.fromJson(json['commercial']);
    if (json['land'] != null) land = LandDto.fromJson(json['land']);

    return Property(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['address'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      type: json['propertyType']?.toString() ?? 'HOUSE',
      listingType: json['listingType']?.toString() ?? 'BUY',
      status: json['status']?.toString() ?? 'AVAILABLE',
      images: List<String>.from(json['images'] ?? []),
      sellerId: json['sellerId']?.toString() ?? '',
      sellerName: json['sellerName'] ?? '',
      sellerAgency: json['sellerAgency'] ?? '',
      sellerAvatar: json['sellerAvatar'],
      lat: json['latitude']?.toDouble(),
      lng: json['longitude']?.toDouble(),
      isFavorite: json['isFavorite'] ?? false,
      apartment: apartment,
      house: house,
      villa: villa,
      studio: studio,
      commercial: commercial,
      land: land,
    );
  }
  Property copyWith({
  String? id,
  String? title,
  String? description,
  String? location,
  double? price,
  String? currency,
  String? type,
  String? listingType,
  String? status,
  List<String>? images,
  String? sellerId,
  String? sellerName,
  String? sellerAgency,
  String? sellerAvatar,
  double? lat,
  double? lng,
  bool? isFavorite,
  ApartmentDto? apartment,
  HouseDto? house,
  VillaDto? villa,
  StudioDto? studio,
  CommercialDto? commercial,
  LandDto? land,
}) {
  return Property(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    location: location ?? this.location,
    price: price ?? this.price,
    currency: currency ?? this.currency,
    type: type ?? this.type,
    listingType: listingType ?? this.listingType,
    status: status ?? this.status,
    images: images ?? this.images,
    sellerId: sellerId ?? this.sellerId,
    sellerName: sellerName ?? this.sellerName,
    sellerAgency: sellerAgency ?? this.sellerAgency,
    sellerAvatar: sellerAvatar ?? this.sellerAvatar,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    isFavorite: isFavorite ?? this.isFavorite,
    apartment: apartment ?? this.apartment,
    house: house ?? this.house,
    villa: villa ?? this.villa,
    studio: studio ?? this.studio,
    commercial: commercial ?? this.commercial,
    land: land ?? this.land,
  );
}
}

// Simple data class for chip rendering
class _PropertyChipData {
  final IconData icon;
  final String label;
  const _PropertyChipData({required this.icon, required this.label});
}