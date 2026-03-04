enum PurchaseStatus { pending, completed, failed }

extension PurchaseStatusX on PurchaseStatus {
  String get label {
    switch (this) {
      case PurchaseStatus.pending:
        return 'Pending';
      case PurchaseStatus.completed:
        return 'Completed';
      case PurchaseStatus.failed:
        return 'Failed';
    }
  }

  static PurchaseStatus fromJson(String raw) {
    return PurchaseStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == raw.toUpperCase(),
      orElse: () => PurchaseStatus.pending,
    );
  }
}

class BoostPurchase {
  final String id;
  final String? sellerId;
  final String? propertyId;
  final String? propertyTitle;
  final String? userName;
  final String? userEmail;
  final double amount;
  final String currency;
  final int durationDays;
  final PurchaseStatus status;

  const BoostPurchase({
    required this.id,
    this.sellerId,
    this.propertyId,
    this.propertyTitle,
    this.userName,
    this.userEmail,
    required this.amount,
    required this.currency,
    required this.durationDays,
    required this.status,
  });

  factory BoostPurchase.fromJson(Map<String, dynamic> json) => BoostPurchase(
    id: json['id']?.toString() ?? '',
    sellerId: json['sellerId']?.toString(),
    propertyId: json['propertyId']?.toString(),
    propertyTitle: json['propertyTitle']?.toString(),
    userName: json['userName']?.toString(),
    userEmail: json['userEmail']?.toString(),
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    currency: json['currency']?.toString() ?? 'USD',
    durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
    status: PurchaseStatusX.fromJson(json['status']?.toString() ?? 'PENDING'),
  );
}
