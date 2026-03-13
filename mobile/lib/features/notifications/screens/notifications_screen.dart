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

  // All notifications (for "All" tab)
  List<NotificationModel> _all = [];
  // Only unread (for "Unread" tab)
  List<NotificationModel> _unread = [];

  bool _loading = true;
  int _tabIndex = 0; // 0 = All, 1 = Unread

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

      // Deduplicate by ID
      final Map<String, NotificationModel> uniqueMap = {};
      for (final n in data) {
        uniqueMap[n.id] = n;
      }
      final all = uniqueMap.values.toList()
        ..sort((a, b) {
          // read ones go to bottom
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
    for (final n in _unread) {
      await _service.markAsRead(n.id);
    }
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
    final tt = Theme.of(context).textTheme;

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
            letterSpacing: -0.5,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (_unread.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _markAllRead,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    'Mark all read',
                    style: GoogleFonts.outfit(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                _TabChip(
                  label: 'All',
                  count: _all.length,
                  selected: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0),
                ),
                const SizedBox(width: 10),
                _TabChip(
                  label: 'Unread',
                  count: _unread.length,
                  selected: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                  isUnread: true,
                ),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : _current.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.subtleBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _tabIndex == 1
                          ? Icons.mark_email_read_outlined
                          : Icons.notifications_none_rounded,
                      size: 40,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _tabIndex == 1
                        ? 'All caught up! 🎉'
                        : 'No notifications yet',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tabIndex == 1
                        ? 'No unread notifications'
                        : 'You\'ll see notifications here',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              backgroundColor: AppColors.cardBackground,
              color: AppColors.primary,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                itemCount: _current.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final n = _current[index];
                  return NotificationCard(
                    notification: n,
                    onMarkRead: n.read ? () {} : () => _markRead(n),
                    onTap: () => _handleTap(n),
                  );
                },
              ),
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
class _TabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final bool isUnread;
  final VoidCallback onTap;

  const _TabChip({
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
                  // FIX: use a light tint for the background so text is visible
                  color: selected
                      ? Colors.white.withOpacity(0.25)
                      : (isUnread
                            ? AppColors.error.withOpacity(
                                0.15,
                              ) // ← was AppColors.error (solid)
                            : AppColors.primary.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    // FIX: text color now contrasts against the lighter background
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
