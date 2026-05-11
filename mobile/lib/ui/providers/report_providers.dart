import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/report_remote_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/i_report_repository.dart';

final reportRemoteDatasourceProvider = Provider<ReportRemoteDatasource>(
  (ref) => ReportRemoteDatasourceImpl(),
);

final reportRepositoryProvider = Provider<IReportRepository>((ref) {
  return ReportRepositoryImpl(ref.read(reportRemoteDatasourceProvider));
});

enum ReportSubmitStatus { idle, loading, success, error }

class ReportState {
  final ReportSubmitStatus status;
  final String? errorMessage;

  const ReportState({this.status = ReportSubmitStatus.idle, this.errorMessage});

  ReportState copyWith({ReportSubmitStatus? status, String? errorMessage}) =>
      ReportState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class ReportNotifier extends Notifier<ReportState> {
  @override
  ReportState build() => const ReportState();

  Future<void> submit({
    required String reporterId,
    String? reportedUserId,
    String? reportedPropertyId,
    required String reason,
  }) async {
    state = state.copyWith(status: ReportSubmitStatus.loading);
    try {
      await ref
          .read(reportRepositoryProvider)
          .createReport(
            reporterId: reporterId,
            reportedUserId: reportedUserId,
            reportedPropertyId: reportedPropertyId,
            reason: reason,
          );
      state = state.copyWith(status: ReportSubmitStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: ReportSubmitStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  void reset() => state = const ReportState();
}

final reportNotifierProvider = NotifierProvider<ReportNotifier, ReportState>(
  ReportNotifier.new,
);

final reportReasonsProvider = FutureProvider<List<String>>((ref) async {
  return ref.read(reportRepositoryProvider).getReportReasons();
});
