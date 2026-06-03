import '../entities/report/report_entity.dart';

abstract class IReportRepository {
  /// Create a report with the selected reason ID
  /// The reportReasonId must be from the active reasons list
  Future<ReportEntity> createReport({
    required String reporterId,
    String? reportedUserId,
    String? reportedPropertyId,
    required String reportReasonId,
    String? details,
  });
  
  /// Get all active report reasons
  /// Returns list of reason objects with id, name, active status
  Future<List<Map<String, dynamic>>> getReportReasons();
}
