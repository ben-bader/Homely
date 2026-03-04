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

  static VisitStatus fromJson(String raw) {
    return VisitStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == raw.toUpperCase(),
      orElse: () => VisitStatus.pending,
    );
  }
}

class VisitRequest {
  final String id;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String propertyId;
  final String? propertyTitle;
  final DateTime requestedDate;
  final VisitStatus status;

  const VisitRequest({
    required this.id,
    this.userId,
    this.userName,
    this.userEmail,
    required this.propertyId,
    this.propertyTitle,
    required this.requestedDate,
    required this.status,
  });

  factory VisitRequest.fromJson(Map<String, dynamic> json) => VisitRequest(
    id: json['id']?.toString() ?? '',
    userId: json['userId']?.toString(),
    userName: json['userName']?.toString(),
    userEmail: json['userEmail']?.toString(),
    propertyId: json['propertyId']?.toString() ?? '',
    propertyTitle: json['propertyTitle']?.toString(),
    requestedDate: DateTime.parse(json['requestedDate'].toString()),
    status: VisitStatusX.fromJson(json['status']?.toString() ?? 'PENDING'),
  );
}
