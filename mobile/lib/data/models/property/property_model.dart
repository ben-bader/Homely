import 'package:flutter/material.dart';
import '../../../domain/entities/property/property_entity.dart';
import '../../../domain/entities/property/property_subtype_entities.dart';
import 'property_subtype_models.dart';

class PropertyModel extends PropertyEntity {
  const PropertyModel({
    required super.id,
    super.sellerId,
    super.sellerName,
    super.sellerAgency,
    super.sellerAvatar,
    required super.title,
    super.description,
    required super.price,
    super.currency,
    required super.listingType,
    required super.propertyType,
    required super.status,
    super.address,
    super.latitude,
    super.longitude,
    super.images,
    super.createdAt,
    super.updatedAt,
    super.apartment,
    super.house,
    super.villa,
    super.studio,
    super.commercial,
    super.land,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> j) => PropertyModel(
        id: j['id']?.toString() ?? '',
        sellerId: j['sellerId']?.toString(),
        sellerName: j['sellerName']?.toString() ?? '',
        sellerAgency: j['sellerAgency']?.toString(),
        sellerAvatar: j['sellerAvatar']?.toString(),
        title: j['title']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        price: (j['price'] as num?)?.toDouble() ?? 0.0,
        currency: j['currency']?.toString() ?? 'USD',
        listingType:
            ListingTypeX.fromJson(j['listingType']?.toString() ?? 'SELL'),
        propertyType: PropertyTypeX.fromJson(
            j['propertyType']?.toString() ?? 'APARTMENT'),
        status: PropertyStatusX.fromJson(
            j['status']?.toString() ?? 'DRAFT'),
        address: j['address']?.toString() ?? '',
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        images: (j['images'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'].toString())
            : null,
        updatedAt: j['updatedAt'] != null
            ? DateTime.tryParse(j['updatedAt'].toString())
            : null,
        apartment: j['apartment'] != null
            ? ApartmentDataModel.fromJson(
                j['apartment'] as Map<String, dynamic>)
            : null,
        house: j['house'] != null
            ? HouseDataModel.fromJson(
                j['house'] as Map<String, dynamic>)
            : null,
        villa: j['villa'] != null
            ? VillaDataModel.fromJson(
                j['villa'] as Map<String, dynamic>)
            : null,
        studio: j['studio'] != null
            ? StudioDataModel.fromJson(
                j['studio'] as Map<String, dynamic>)
            : null,
        commercial: j['commercial'] != null
            ? CommercialDataModel.fromJson(
                j['commercial'] as Map<String, dynamic>)
            : null,
        land: j['land'] != null
            ? LandDataModel.fromJson(
                j['land'] as Map<String, dynamic>)
            : null,
      );
}
