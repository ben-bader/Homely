import 'package:homely/core/network/api_client.dart';

abstract class ReportRemoteDatasource {
  /// Create a report with a selected reason ID
  /// The reason must be an active report reason ID obtained from getReportReasons()
  Future<Map<String, dynamic>> createReport({
    required String reporterId,
    String? reportedUserId,
    String? reportedPropertyId,
    required String reportReasonId,
    String? details,
  });
  
  /// Get all active report reasons for display
  /// Returns list of reasons with id, name, active status
  Future<List<Map<String, dynamic>>> getReportReasons();
}

class ReportRemoteDatasourceImpl implements ReportRemoteDatasource {
  @override
  Future<Map<String, dynamic>> createReport({
    required String reporterId,
    String? reportedUserId,
    String? reportedPropertyId,
    required String reportReasonId,
    String? details,
  }) async {
    final body = {
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'reportedPropertyId': reportedPropertyId,
      'reportReasonId': reportReasonId,
    };
    if (details != null && details.isNotEmpty) {
      body['details'] = details;
    }

    final response = await ApiClient.post(
      '/users/reports',
      body: body,
    );
    return response;
  }

  @override
  Future<List<Map<String, dynamic>>> getReportReasons() async {
    // Fetch only active reasons from the new endpoint
    final response = await ApiClient.get('/report-reasons/active');
    return List<Map<String, dynamic>>.from(response ?? []);
  }
}
