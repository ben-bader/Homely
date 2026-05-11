import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/visit_request_remote_datasource.dart';
import '../../data/repositories/visit_request_repository_impl.dart';
import '../../domain/entities/visit_request/visit_request_entity.dart';
import '../../domain/repositories/i_visit_request_repository.dart';

final visitRequestRemoteDatasourceProvider =
    Provider<VisitRequestRemoteDatasource>(
      (ref) => VisitRequestRemoteDatasourceImpl(),
    );

final visitRequestRepositoryProvider = Provider<IVisitRequestRepository>((ref) {
  return VisitRequestRepositoryImpl(
    ref.read(visitRequestRemoteDatasourceProvider),
  );
});

final myVisitRequestsProvider =
    AsyncNotifierProvider<MyVisitRequestsNotifier, List<VisitRequestEntity>>(
      MyVisitRequestsNotifier.new,
    );

class MyVisitRequestsNotifier extends AsyncNotifier<List<VisitRequestEntity>> {
  @override
  Future<List<VisitRequestEntity>> build() =>
      ref.read(visitRequestRepositoryProvider).getMyRequests();

  Future<void> create({
    required String propertyId,
    required DateTime requestedDate,
  }) async {
    final previous = state;
    try {
      final created = await ref
          .read(visitRequestRepositoryProvider)
          .create(propertyId: propertyId, requestedDate: requestedDate);
      state.whenData((list) => state = AsyncData([created, ...list]));
    } catch (e, st) {
      state = previous;
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> cancel(String id) async {
    final previous = state;
    state.whenData(
      (list) => state = AsyncData(list.where((r) => r.id != id).toList()),
    );
    try {
      await ref.read(visitRequestRepositoryProvider).delete(id);
    } catch (e, st) {
      state = previous;
      Error.throwWithStackTrace(e, st);
    }
  }
}

final sellerVisitRequestsProvider =
    AsyncNotifierProviderFamily<
      SellerVisitRequestsNotifier,
      List<VisitRequestEntity>,
      String
    >(SellerVisitRequestsNotifier.new);

class SellerVisitRequestsNotifier
    extends FamilyAsyncNotifier<List<VisitRequestEntity>, String> {
  @override
  Future<List<VisitRequestEntity>> build(String propertyId) => ref
      .read(visitRequestRepositoryProvider)
      .getRequestsForProperty(propertyId);

  Future<void> updateStatus({
    required String requestId,
    required VisitStatus status,
  }) async {
    final previous = state;
    state.whenData(
      (list) => state = AsyncData(
        list
            .map(
              (r) => r.id == requestId
                  ? VisitRequestEntity(
                      id: r.id,
                      userId: r.userId,
                      userName: r.userName,
                      userEmail: r.userEmail,
                      propertyId: r.propertyId,
                      propertyTitle: r.propertyTitle,
                      requestedDate: r.requestedDate,
                      status: status,
                    )
                  : r,
            )
            .toList(),
      ),
    );
    try {
      final updated = await ref
          .read(visitRequestRepositoryProvider)
          .updateStatus(id: requestId, status: status);
      state.whenData(
        (list) => state = AsyncData(
          list.map((r) => r.id == requestId ? updated : r).toList(),
        ),
      );
    } catch (e, st) {
      state = previous;
      Error.throwWithStackTrace(e, st);
    }
  }
}
