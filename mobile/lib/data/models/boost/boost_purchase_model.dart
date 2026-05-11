import '../../../domain/entities/boost/boost_purchase_entity.dart';

class BoostPurchaseModel extends BoostPurchaseEntity {
  const BoostPurchaseModel({
    required super.id,
    super.sellerId,
    super.propertyId,
    super.propertyTitle,
    super.userName,
    super.userEmail,
    required super.amount,
    required super.currency,
    required super.durationDays,
    required super.status,
  });

  factory BoostPurchaseModel.fromJson(Map<String, dynamic> json) =>
      BoostPurchaseModel(
        id: json['id']?.toString() ?? '',
        sellerId: json['sellerId']?.toString(),
        propertyId: json['propertyId']?.toString(),
        propertyTitle: json['propertyTitle']?.toString(),
        userName: json['userName']?.toString(),
        userEmail: json['userEmail']?.toString(),
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency']?.toString() ?? 'USD',
        durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
        status: PurchaseStatusX.fromJson(
            json['status']?.toString() ?? 'PENDING'),
      );
}
