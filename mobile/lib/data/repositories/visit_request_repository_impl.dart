import '../../domain/entities/visit_request/visit_request_entity.dart';
import '../../domain/repositories/i_visit_request_repository.dart';
import '../datasources/remote/visit_request_remote_datasource.dart';
import '../models/visit_request/visit_request_model.dart';

class VisitRequestRepositoryImpl implements IVisitRequestRepository {
  final VisitRequestRemoteDatasource _remote;

  VisitRequestRepositoryImpl(this._remote);

  @override
  Future<VisitRequestEntity> create({
    required String propertyId,
    required DateTime requestedDate,
  }) async {
    final data = await _remote.create(
        propertyId: propertyId, requestedDate: requestedDate);
    return VisitRequestModel.fromJson(data);
  }

  @override
  Future<List<VisitRequestEntity>> getMyRequests() async {
    final data = await _remote.getMyRequests();
    return data
        .map((e) =>
            VisitRequestModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<VisitRequestEntity>> getRequestsForProperty(
      String propertyId) async {
    final data = await _remote.getRequestsForProperty(propertyId);
    return data
        .map((e) =>
            VisitRequestModel.fromJson(e))
        .toList();
  }

  @override
  Future<VisitRequestEntity> updateStatus({
    required String id,
    required VisitStatus status,
  }) async {
    final data =
        await _remote.updateStatus(id: id, status: status.toJson());
    return VisitRequestModel.fromJson(data);
  }

  @override
  Future<void> delete(String id) => _remote.delete(id);
}
