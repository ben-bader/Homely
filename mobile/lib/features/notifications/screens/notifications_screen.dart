import 'package:flutter/material.dart';
import 'package:mobile/features/notifications/services/notification_service.dart';
import 'package:mobile/features/notifications/models/notifications.dart';
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
    setState(() {
      _notifications = data;
      _loading = false;
    });
  }

  Future<void> _markRead(NotificationModel   n) async {
    await _service.markAsRead(n.id);
    setState(() => _notifications.remove(n));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none,
                          size: 72, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('You\'re all caught up!',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      return Dismissible(
                        key: Key(n.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                        onDismissed: (_) => _markRead(n),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              _iconFor(n.type),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            _service.titleFor(n.type), // or just n.type
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(n.payload),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            tooltip: 'Mark as read',
                            onPressed: () => _markRead(n),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _iconFor(String type) {
    return switch (type) {
      'MESSAGE' => Icons.message,
      'ALERT'   => Icons.warning_amber,
      _         => Icons.notifications,
    };
  }
}

  