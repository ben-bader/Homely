import '../../domain/entities/report/report_entity.dart';
import '../../domain/repositories/i_report_repository.dart';
import '../datasources/remote/report_remote_datasource.dart';
import '../models/report/report_model.dart';

class ReportRepositoryImpl implements IReportRepository {
  final ReportRemoteDatasource _remote;

  ReportRepositoryImpl(this._remote);

  @override
  Future<ReportEntity> createReport({
    required String reporterId,
    String? reportedUserId,
    String? reportedPropertyId,
    required String reportReasonId,
    String? details,
  }) async {
    final data = await _remote.createReport(
        reporterId: reporterId,
        reportedUserId: reportedUserId,
        reportedPropertyId: reportedPropertyId,
        reportReasonId: reportReasonId,
        details: details);
    return ReportModel.fromJson(data);
  }

  @override
  Future<List<Map<String, dynamic>>> getReportReasons() async {
    final data = await _remote.getReportReasons();
    // Return the full reason objects (id, name, active, etc.)
    // so the UI can work with both ID and display name
    return data;
  }
}
