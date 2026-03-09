import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/notifications/services/notification_service.dart';
import 'package:mobile/features/notifications/models/notifications.dart';
import 'package:mobile/features/notifications/widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  final String userId;
  const NotificationsScreen({super.key, required this.userId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _service.fetchUnread(widget.userId);
    // Deduplicate by ID to prevent multiple appearances
    final Map<String, NotificationModel> uniqueMap = {};
    for (final n in data) {
      uniqueMap[n.id] = n;
    }
    setState(() {
      _notifications = uniqueMap.values.toList();
      _loading = false;
    });
  }

  Future<void> _markRead(NotificationModel n) async {
    await _service.markAsRead(n.id);
    await _load(); // Reload to sync with backend state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            color: AppColors.accent,
            letterSpacing: -0.5,
            height: 1.1,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_notifications.length}',
                    style: GoogleFonts.outfit(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.notifications_none,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'You\'re all caught up! 🎉',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No unread notifications at the moment',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  backgroundColor: Colors.white,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      return NotificationCard(
                        notification: n,
                        onMarkRead: () => _markRead(n),
                        onTap: () async {
                          // Handle notification tap - navigate to relevant screen
                          _handleNotificationTap(n);
                        },
                      );
                    },
                  ),
                ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    switch (notification.type) {
      case 'NEW_CHAT_MESSAGE':
      case 'CONVERSATION_CREATED':
        // Navigate to chat screen
        debugPrint('Navigate to conversation');
        break;
      case 'VISIT_REQUEST_CREATED':
      case 'VISIT_REQUEST_STATUS_CHANGED':
        // Navigate to visit requests
        debugPrint('Navigate to visit requests');
        break;
      case 'PROPERTY_CREATED':
      case 'PROPERTY_STATUS_CHANGED':
        // Navigate to property details
        debugPrint('Navigate to property');
        break;
      case 'FEEDBACK_RECEIVED':
        // Navigate to feedback
        debugPrint('Navigate to feedback');
        break;
      default:
        debugPrint('Unknown notification type');
    }
  }
}
