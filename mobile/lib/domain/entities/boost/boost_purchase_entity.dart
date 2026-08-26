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

  static PurchaseStatus fromJson(String raw) =>
      PurchaseStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == raw.toUpperCase(),
        orElse: () => PurchaseStatus.pending,
      );
}

class BoostPurchaseEntity {
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

  const BoostPurchaseEntity({
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
}
