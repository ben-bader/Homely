import '../../../domain/entities/boost/boost_package_entity.dart';

class BoostPackageModel extends BoostPackageEntity {
  const BoostPackageModel({
    required super.id,
    required super.name,
    required super.description,
    required super.durationDays,
    required super.price,
  });

  factory BoostPackageModel.fromJson(Map<String, dynamic> json) =>
      BoostPackageModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'durationDays': durationDays,
        'price': price,
      };
}
