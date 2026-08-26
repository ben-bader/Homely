enum VisitStatus { pending, approved, rejected, completed }

class VisitRequest {
  final String id;
  final String propertyId;
  final String requesterId;
  final String requesterName;
  final String requesterEmail;
  final String requesterPhone;
  final DateTime requestedDate;
  final String message;
  final VisitStatus status;
  final DateTime createdAt;

  VisitRequest({
    required this.id,
    required this.propertyId,
    required this.requesterId,
    required this.requesterName,
    required this.requesterEmail,
    required this.requesterPhone,
    required this.requestedDate,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory VisitRequest.fromJson(Map<String, dynamic> json) {
    return VisitRequest(
      id: json['id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      requesterId: json['requesterId'] ?? '',
      requesterName: json['requesterName'] ?? '',
      requesterEmail: json['requesterEmail'] ?? '',
      requesterPhone: json['requesterPhone'] ?? '',
      requestedDate: DateTime.parse(
        json['requestedDate'] ?? DateTime.now().toIso8601String(),
      ),
      message: json['message'] ?? '',
      status: VisitStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VisitStatus.pending,
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
