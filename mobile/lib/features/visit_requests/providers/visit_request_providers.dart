import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/visit_requests/models/visit_request.dart';
import 'package:mobile/features/visit_requests/repositories/visit_request_repository.dart';

final myVisitRequestsProvider =
    AsyncNotifierProvider<MyVisitRequestsNotifier, List<VisitRequest>>(
      MyVisitRequestsNotifier.new,
    );

class MyVisitRequestsNotifier extends AsyncNotifier<List<VisitRequest>> {
  @override
  Future<List<VisitRequest>> build() =>
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
      List<VisitRequest>,
      String
    >(SellerVisitRequestsNotifier.new);

class SellerVisitRequestsNotifier
    extends FamilyAsyncNotifier<List<VisitRequest>, String> {
  @override
  Future<List<VisitRequest>> build(String propertyId) => ref
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
                  ? VisitRequest(
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
