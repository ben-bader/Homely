class NotificationModel {
  final String id;
  final String type;
  final String payload;
  final bool read;

  NotificationModel({
    required this.id,
    required this.type,
    required this.payload,
    required this.read,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      payload: json['payload'],
      read: json['read'],
    );
  }
}