import '../../../domain/entities/report/report_entity.dart';

class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    super.reporterId,
    super.reporterName,
    super.reporterEmail,
    super.reportedUserId,
    super.reportedUserName,
    super.reportedUserEmail,
    super.reportedPropertyId,
    super.reportedPropertyTitle,
    super.reason,
    required super.status,
    super.reviewedByAdminId,
    super.reviewedByAdminName,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
        id: json['id']?.toString() ?? '',
        reporterId: json['reporterId']?.toString(),
        reporterName: json['reporterName']?.toString(),
        reporterEmail: json['reporterEmail']?.toString(),
        reportedUserId: json['reportedUserId']?.toString(),
        reportedUserName: json['reportedUserName']?.toString(),
        reportedUserEmail: json['reportedUserEmail']?.toString(),
        reportedPropertyId: json['reportedPropertyId']?.toString(),
        reportedPropertyTitle:
            json['reportedPropertyTitle']?.toString(),
        reason: json['reason']?.toString(),
        status: ReportStatusX.fromJson(
            json['status']?.toString() ?? 'OPEN'),
        reviewedByAdminId: json['reviewedByAdminId']?.toString(),
        reviewedByAdminName: json['reviewedByAdminName']?.toString(),
      );
}
