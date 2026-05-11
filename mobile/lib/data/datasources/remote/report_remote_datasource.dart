import 'package:homely/core/network/api_client.dart';

abstract class ReportRemoteDatasource {
  Future<Map<String, dynamic>> createReport({
    required String reporterId,
    String? reportedUserId,
    String? reportedPropertyId,
    required String reason,
  });
  Future<List<Map<String, dynamic>>> getReportReasons();
}

class ReportRemoteDatasourceImpl implements ReportRemoteDatasource {
  @override
  Future<Map<String, dynamic>> createReport({
    required String reporterId,
    String? reportedUserId,
    String? reportedPropertyId,
    required String reason,
  }) async {
    final response = await ApiClient.post(
      '/reports',
      body: {
        'reporterId': reporterId,
        if (reportedUserId != null) 'reportedUserId': reportedUserId,
        if (reportedPropertyId != null)
          'reportedPropertyId': reportedPropertyId,
        'reason': reason,
      },
    );
    return response;
  }

  @override
  Future<List<Map<String, dynamic>>> getReportReasons() async {
    final response = await ApiClient.get('/reports/reasons');
    return List<Map<String, dynamic>>.from(response ?? []);
  }
}
