enum ReportStatus { open, reviewed, resolved, dismissed }

extension ReportStatusX on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.open:
        return 'Open';
      case ReportStatus.reviewed:
        return 'Reviewed';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.dismissed:
        return 'Dismissed';
    }
  }

  static ReportStatus fromJson(String raw) {
    return ReportStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == raw.toUpperCase(),
      orElse: () => ReportStatus.open,
    );
  }
}

class Report {
  final String id;
  final String? reporterId;
  final String? reporterName;
  final String? reporterEmail;
  final String? reportedUserId;
  final String? reportedUserName;
  final String? reportedUserEmail;
  final String? reportedPropertyId;
  final String? reportedPropertyTitle;
  final String? reason;
  final ReportStatus status;
  final String? reviewedByAdminId;
  final String? reviewedByAdminName;

  const Report({
    required this.id,
    this.reporterId,
    this.reporterName,
    this.reporterEmail,
    this.reportedUserId,
    this.reportedUserName,
    this.reportedUserEmail,
    this.reportedPropertyId,
    this.reportedPropertyTitle,
    this.reason,
    required this.status,
    this.reviewedByAdminId,
    this.reviewedByAdminName,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json['id']?.toString() ?? '',
    reporterId: json['reporterId']?.toString(),
    reporterName: json['reporterName']?.toString(),
    reporterEmail: json['reporterEmail']?.toString(),
    reportedUserId: json['reportedUserId']?.toString(),
    reportedUserName: json['reportedUserName']?.toString(),
    reportedUserEmail: json['reportedUserEmail']?.toString(),
    reportedPropertyId: json['reportedPropertyId']?.toString(),
    reportedPropertyTitle: json['reportedPropertyTitle']?.toString(),
    reason: json['reason']?.toString(),
    status: ReportStatusX.fromJson(json['status']?.toString() ?? 'OPEN'),
    reviewedByAdminId: json['reviewedByAdminId']?.toString(),
    reviewedByAdminName: json['reviewedByAdminName']?.toString(),
  );
}
