import '../entities/report/report_entity.dart';

abstract class IReportRepository {
  Future<ReportEntity> createReport({
    required String reporterId,
    String? reportedUserId,
    String? reportedPropertyId,
    required String reason,
  });
  Future<List<String>> getReportReasons();
}
