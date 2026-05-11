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
    required String reason,
  }) async {
    final data = await _remote.createReport(
        reporterId: reporterId,
        reportedUserId: reportedUserId,
        reportedPropertyId: reportedPropertyId,
        reason: reason);
    return ReportModel.fromJson(data);
  }

  @override
  Future<List<String>> getReportReasons() async {
    final data = await _remote.getReportReasons();
    return data.map((e) => e['reason'] as String).toList();
  }
}
