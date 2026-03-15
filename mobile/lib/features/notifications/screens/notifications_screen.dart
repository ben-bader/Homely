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

  List<NotificationModel> _all = [];
  List<NotificationModel> _unread = [];

  bool _loading = true;
  int _tabIndex = 0;

  List<NotificationModel> get _current => _tabIndex == 0 ? _all : _unread;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchUnread(widget.userId);
      final Map<String, NotificationModel> unique = {};
      for (final n in data) unique[n.id] = n;
      final all = unique.values.toList()
        ..sort((a, b) {
          if (a.read && !b.read) return 1;
          if (!a.read && b.read) return -1;
          return 0;
        });
      setState(() {
        _all = all;
        _unread = all.where((n) => !n.read).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _markRead(NotificationModel n) async {
    await _service.markAsRead(n.id);
    setState(() {
      final updated = NotificationModel(
        id: n.id,
        type: n.type,
        payload: n.payload,
        read: true,
      );
      _all = [
        for (final item in _all)
          if (item.id == n.id) updated else item,
      ];
      _unread = _all.where((item) => !item.read).toList();
    });
  }

  Future<void> _markAllRead() async {
    for (final n in _unread) await _service.markAsRead(n.id);
    setState(() {
      _all = _all
          .map(
            (n) => NotificationModel(
              id: n.id,
              type: n.type,
              payload: n.payload,
              read: true,
            ),
          )
          .toList();
      _unread = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.subtleBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.accent,
              size: 16,
            ),
          ),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            color: AppColors.accent,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (_unread.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _markAllRead,
                child: Text(
                  'Mark all read',
                  style: GoogleFonts.outfit(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Tab row ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                _Tab(
                  label: 'All',
                  count: _all.length,
                  selected: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0),
                ),
                const SizedBox(width: 8),
                _Tab(
                  label: 'Unread',
                  count: _unread.length,
                  selected: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                  isUnread: true,
                ),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : _current.isEmpty
                ? _emptyState()
                : RefreshIndicator(
                    onRefresh: _load,
                    backgroundColor: AppColors.cardBackground,
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      itemCount: _current.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final n = _current[i];
                        return NotificationCard(
                          notification: n,
                          onMarkRead: n.read ? null : () => _markRead(n),
                          onTap: () => _handleTap(n),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.subtleBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _tabIndex == 1
                  ? Icons.mark_email_read_outlined
                  : Icons.notifications_none_rounded,
              size: 32,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _tabIndex == 1 ? 'All caught up!' : 'No notifications yet',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _tabIndex == 1
                ? 'No unread notifications'
                : 'You\'ll see notifications here',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(NotificationModel n) {
    if (!n.read) _markRead(n);
    switch (n.type) {
      case 'NEW_CHAT_MESSAGE':
      case 'CONVERSATION_CREATED':
        debugPrint('Navigate to conversation');
        break;
      case 'VISIT_REQUEST_CREATED':
      case 'VISIT_REQUEST_STATUS_CHANGED':
        debugPrint('Navigate to visit requests');
        break;
      case 'PROPERTY_CREATED':
      case 'PROPERTY_STATUS_CHANGED':
        debugPrint('Navigate to property');
        break;
      case 'FEEDBACK_RECEIVED':
        debugPrint('Navigate to feedback');
        break;
      default:
        break;
    }
  }
}

// ── Tab chip ──────────────────────────────────────────────────────────────────
class _Tab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final bool isUnread;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.subtleBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.accent,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(0.25)
                      : (isUnread
                            ? AppColors.error.withOpacity(0.12)
                            : AppColors.primary.withOpacity(0.12)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : (isUnread ? AppColors.error : AppColors.primary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
