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

  static ReportStatus fromJson(String raw) =>
      ReportStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == raw.toUpperCase(),
        orElse: () => ReportStatus.open,
      );
}

class ReportEntity {
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

  const ReportEntity({
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
}
