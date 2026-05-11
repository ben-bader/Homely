import '../entities/visit_request/visit_request_entity.dart';

abstract class IVisitRequestRepository {
  Future<VisitRequestEntity> create({
    required String propertyId,
    required DateTime requestedDate,
  });
  Future<List<VisitRequestEntity>> getMyRequests();
  Future<List<VisitRequestEntity>> getRequestsForProperty(
      String propertyId);
  Future<VisitRequestEntity> updateStatus({
    required String id,
    required VisitStatus status,
  });
  Future<void> delete(String id);
}
