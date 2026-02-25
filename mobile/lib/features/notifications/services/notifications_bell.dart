import 'package:flutter/material.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/notifications/screens/notifications_screen.dart';
import 'package:mobile/features/notifications/services/notification_service.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _service = NotificationService();
  final _authService = AuthService();
  int _unreadCount = 0;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _userId = await _authService.getCurrentUserId();
    await _refresh();
  }

  Future<void> _refresh() async {
    if (_userId == null) return;
    final data = await _service.fetchUnread(_userId!);
    if (mounted) setState(() => _unreadCount = data.length);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Badge(
        isLabelVisible: _unreadCount > 0,
        label: Text('$_unreadCount'),
        child: const Icon(Icons.notifications_outlined),
      ),
      onPressed: () async {
        if (_userId == null) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationsScreen(userId: _userId!),
          ),
        );
        _refresh(); // refresh count when returning from screen
      },
    );
  }
}