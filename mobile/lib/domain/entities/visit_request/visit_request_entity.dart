enum VisitStatus { pending, approved, rejected }

extension VisitStatusX on VisitStatus {
  String get label {
    switch (this) {
      case VisitStatus.pending:
        return 'Pending';
      case VisitStatus.approved:
        return 'Approved';
      case VisitStatus.rejected:
        return 'Rejected';
    }
  }

  String toJson() => name.toUpperCase();

  static VisitStatus fromJson(String raw) =>
      VisitStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == raw.toUpperCase(),
        orElse: () => VisitStatus.pending,
      );
}

class VisitRequestEntity {
  final String id;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String propertyId;
  final String? propertyTitle;
  final DateTime requestedDate;
  final VisitStatus status;

  const VisitRequestEntity({
    required this.id,
    this.userId,
    this.userName,
    this.userEmail,
    required this.propertyId,
    this.propertyTitle,
    required this.requestedDate,
    required this.status,
  });
}
