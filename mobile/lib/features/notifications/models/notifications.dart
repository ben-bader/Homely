import 'dart:convert';

class NotificationModel {
  final String id;
  final String type;
  final String payload;
  final bool read;
  late final Map<String, dynamic> _payloadData;

  NotificationModel({
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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      payload: json['payload'],
      read: json['read'],
    );
  }

  /// Get formatted title based on notification type
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

  /// Get formatted subtitle with relevant details
  String getSubtitle() {
    try {
      return switch (type) {
        'NEW_CHAT_MESSAGE' => _payloadData['senderName'] ?? 'New message received',
        'CONVERSATION_CREATED' => _payloadData['senderName'] ?? 'Started a conversation',
        'VISIT_REQUEST_CREATED' => 'New visit request received',
        'VISIT_REQUEST_STATUS_CHANGED' => 'Visit request: ${_payloadData['newStatus'] ?? 'updated'}',
        'PROPERTY_CREATED' => _payloadData['propertyTitle'] ?? 'New property listed',
        'PROPERTY_STATUS_CHANGED' => _payloadData['propertyTitle'] ?? 'Property updated',
        'BOOST_PURCHASED' => 'Boost for ${_payloadData['propertyTitle'] ?? 'your property'}',
        'BOOST_STATUS_CHANGED' => _payloadData['newStatus'] ?? 'Boost updated',
        'FEEDBACK_RECEIVED' => 'New feedback received',
        _ => payload,
      };
    } catch (e) {
      return payload;
    }
  }

  /// Get detailed message for notification
  String getDetailedMessage() {
    try {
      return switch (type) {
        'NEW_CHAT_MESSAGE' => _payloadData['messagePreview'] ?? _payloadData['payload'] ?? 'New message',
        'VISIT_REQUEST_CREATED' => 'Someone wants to visit your property',
        'FEEDBACK_RECEIVED' => 'You received new feedback on your property',
        'PROPERTY_CREATED' => '${_payloadData['propertyTitle'] ?? 'Property'} has been listed',
        _ => _payloadData['message'] ?? _payloadData['payload'] ?? payload,
      };
    } catch (e) {
      return payload;
    }
  }

  /// Get the icon data based on notification type
  String getIconEmoji() {
    return switch (type) {
      'NEW_CHAT_MESSAGE' => '💬',
      'CONVERSATION_CREATED' => '💬',
      'VISIT_REQUEST_CREATED' => '👁️',
      'VISIT_REQUEST_STATUS_CHANGED' => '👁️',
      'PROPERTY_CREATED' => '🏠',
      'PROPERTY_STATUS_CHANGED' => '🏠',
      'BOOST_PURCHASED' => '⚡',
      'BOOST_STATUS_CHANGED' => '⚡',
      'FEEDBACK_RECEIVED' => '⭐',
      _ => '📬',
    };
  }

  /// Get associated color for notification type
  String getColorHex() {
    return switch (type) {
      'NEW_CHAT_MESSAGE' || 'CONVERSATION_CREATED' => '0xFF2196F3',
      'VISIT_REQUEST_CREATED' || 'VISIT_REQUEST_STATUS_CHANGED' => '0xFF9C27B0',
      'PROPERTY_CREATED' || 'PROPERTY_STATUS_CHANGED' => '0xFF4CAF50',
      'BOOST_PURCHASED' || 'BOOST_STATUS_CHANGED' => '0xFFFF9800',
      'FEEDBACK_RECEIVED' => '0xFFFFC107',
      _ => '0xFF607D8B',
    };
  }
}

