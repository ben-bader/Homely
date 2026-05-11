import 'dart:convert';
import '../../../domain/entities/notification/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required super.id,
    required super.type,
    required super.payload,
    required super.read,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'],
        type: json['type'],
        payload: json['payload'],
        read: json['read'],
      );
}
