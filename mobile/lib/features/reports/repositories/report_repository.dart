import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/features/reports/models/report.dart';

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => ReportRepository(),
);

class ReportRepository {
  Future<Report> createReport({
    required String reporterId,
    String? reportedUserId,
    String? reportedPropertyId,
    required String reason,
  }) async {
    assert(
      reportedUserId != null || reportedPropertyId != null,
      'Must provide either reportedUserId or reportedPropertyId',
    );

    final body = <String, dynamic>{
      'reporterId': reporterId,
      'reason': reason,
      'status': 'OPEN',
      if (reportedUserId != null) 'reportedUserId': reportedUserId,
      if (reportedPropertyId != null) 'reportedPropertyId': reportedPropertyId,
    };

    final data =
        await ApiClient.post('/users/reports', body: body)
            as Map<String, dynamic>;

    return Report.fromJson(data);
  }
}
