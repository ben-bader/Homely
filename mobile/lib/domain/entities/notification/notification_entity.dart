import 'dart:convert';

class NotificationEntity {
  final String id;
  final String type;
  final String payload;
  final bool read;
  late final Map<String, dynamic> _payloadData;

  NotificationEntity({
    required this.id,
    required this.type,
    required this.payload,
    required this.read,
  }) {
    try {
      _payloadData = jsonDecode(payload) as Map<String, dynamic>;
    } catch (e) {
      _payloadData = {'message': payload};
    }
  }

  String getTitle() {
    return switch (type) {
      'NEW_CHAT_MESSAGE' => '💬 New Message',
      'CONVERSATION_CREATED' => '💬 New Conversation',
      'VISIT_REQUEST_CREATED' => '👁️ Visit Request',
      'VISIT_REQUEST_STATUS_CHANGED' => '👁️ Visit Request Updated',
      'PROPERTY_CREATED' => '🏠 New Property',
      'PROPERTY_STATUS_CHANGED' => '🏠 Property Updated',
      'BOOST_PURCHASED' => '⚡ Boost Purchased',
      'BOOST_STATUS_CHANGED' => '⚡ Boost Updated',
      'FEEDBACK_RECEIVED' => '⭐ New Feedback',
      _ => '📬 Notification',
    };
  }

  String getSubtitle() {
    try {
      return switch (type) {
        'NEW_CHAT_MESSAGE' =>
          _payloadData['senderName'] ?? 'New message received',
        'CONVERSATION_CREATED' =>
          _payloadData['senderName'] ?? 'Started a conversation',
        'VISIT_REQUEST_CREATED' => 'New visit request received',
        'VISIT_REQUEST_STATUS_CHANGED' =>
          'Visit request: ${_payloadData['newStatus'] ?? 'updated'}',
        'PROPERTY_CREATED' =>
          _payloadData['propertyTitle'] ?? 'New property listed',
        'PROPERTY_STATUS_CHANGED' =>
          _payloadData['propertyTitle'] ?? 'Property updated',
        'BOOST_PURCHASED' =>
          'Boost for ${_payloadData['propertyTitle'] ?? 'your property'}',
        'BOOST_STATUS_CHANGED' =>
          _payloadData['newStatus'] ?? 'Boost updated',
        'FEEDBACK_RECEIVED' => 'New feedback received',
        _ => payload,
      };
    } catch (e) {
      return payload;
    }
  }

  String getDetailedMessage() {
    try {
      return switch (type) {
        'NEW_CHAT_MESSAGE' =>
          _payloadData['messagePreview'] ??
              _payloadData['payload'] ??
              'New message',
        'VISIT_REQUEST_CREATED' =>
          'Someone wants to visit your property',
        'FEEDBACK_RECEIVED' =>
          'You received new feedback on your property',
        'PROPERTY_CREATED' =>
          '${_payloadData['propertyTitle'] ?? 'Property'} has been listed',
        _ =>
          _payloadData['message'] ??
              _payloadData['payload'] ??
              payload,
      };
    } catch (e) {
      return payload;
    }
  }
}
