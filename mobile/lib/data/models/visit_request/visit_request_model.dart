import '../../../domain/entities/visit_request/visit_request_entity.dart';

class VisitRequestModel extends VisitRequestEntity {
  const VisitRequestModel({
    required super.id,
    super.userId,
    super.userName,
    super.userEmail,
    required super.propertyId,
    super.propertyTitle,
    required super.requestedDate,
    required super.status,
  });

  factory VisitRequestModel.fromJson(Map<String, dynamic> json) =>
      VisitRequestModel(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString(),
        userName: json['userName']?.toString(),
        userEmail: json['userEmail']?.toString(),
        propertyId: json['propertyId']?.toString() ?? '',
        propertyTitle: json['propertyTitle']?.toString(),
        requestedDate:
            DateTime.parse(json['requestedDate'].toString()),
        status: VisitStatusX.fromJson(
            json['status']?.toString() ?? 'PENDING'),
      );
}
