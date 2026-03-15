import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/boost/screens/my_boosts_screen.dart';
import 'package:mobile/features/notifications/services/notification_service.dart';
import 'package:mobile/features/notifications/models/notifications.dart';
import 'package:mobile/features/chat/screens/conversation_screen.dart';
import 'package:mobile/features/visit_requests/screens/seller_visit_requests_screen.dart';
import 'package:mobile/features/property/screens/property_detail_screen.dart';
import 'package:mobile/features/boost/widgets/boost_sheet.dart';
import 'package:mobile/features/chat/screens/chat_screen.dart';

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
  bool _searchOpen = false;
  String _query = '';
  final _searchCtrl = TextEditingController();

  List<NotificationModel> get _current => _tabIndex == 0 ? _all : _unread;

  List<NotificationModel> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _current;
    return _current.where((n) {
      try {
        final data = jsonDecode(n.payload) as Map<String, dynamic>;
        final msg = (data['message'] ?? '').toString().toLowerCase();
        final title = (data['propertyTitle'] ?? '').toString().toLowerCase();
        return msg.contains(q) ||
            title.contains(q) ||
            n.type.toLowerCase().contains(q);
      } catch (_) {
        return n.type.toLowerCase().contains(q);
      }
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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

  void _handleTap(NotificationModel n) {
    if (!n.read) _markRead(n);

    try {
      final data = jsonDecode(n.payload) as Map<String, dynamic>;

      switch (n.type) {
        // ── Chat / conversation ──────────────────────────────────────────────
        case 'NEW_CHAT_MESSAGE':
        case 'NEW_CONVERSATION':
        case 'CONVERSATION_CREATED':
          final conversationId = data['conversationId'] as String?;
          if (conversationId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  conversationId: conversationId,
                  currentUserId: widget.userId,
                  chatTitle:
                      data['senderName'] as String? ??
                      data['clientName'] as String? ??
                      'Chat',
                  chatSubtitle: data['propertyTitle'] as String? ?? '',
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConversationsScreen()),
            );
          }
          break;

        // ── Property detail ──────────────────────────────────────────────────
        case 'PROPERTY_CREATED':
          final propertyId = data['propertyId'] as String?;
          if (propertyId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PropertyDetailScreen(propertyId: propertyId),
              ),
            );
          }
          break;

        // ── Boost ────────────────────────────────────────────────────────────
        // ── Boost ────────────────────────────────────────────────────────────────
        // ── Boost ────────────────────────────────────────────────────────────────
        case 'BOOST_CREATED':
        case 'BOOST_STATUS_CHANGED':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyBoostsScreen()),
          );
          break;

        // ── Visit requests ───────────────────────────────────────────────────
        case 'VISIT_REQUEST_CREATED':
        case 'VISIT_REQUEST_STATUS_CHANGED':
          final visitPropertyId = data['propertyId'] as String?;
          final visitPropertyTitle =
              data['propertyTitle'] as String? ?? 'Property';
          if (visitPropertyId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SellerVisitRequestsScreen(
                  propertyId: visitPropertyId,
                  propertyTitle: visitPropertyTitle,
                ),
              ),
            );
          }
          break;

        default:
          break;
      }
    } catch (e) {
      debugPrint('[Notifications] handleTap error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _searchOpen
                        ? _SearchField(
                            controller: _searchCtrl,
                            onChanged: (v) => setState(() => _query = v),
                            onClose: () => setState(() {
                              _searchOpen = false;
                              _query = '';
                              _searchCtrl.clear();
                            }),
                          )
                        : Text(
                            'Notifications',
                            style: GoogleFonts.outfit(
                              color: AppColors.accent,
                              letterSpacing: -0.5,
                              height: 1.1,
                              fontSize: 30,
                            ),
                          ),
                  ),
                  if (!_searchOpen) ...[
                    IconButton(
                      icon: const Icon(Icons.search, color: AppColors.accent),
                      onPressed: () => setState(() => _searchOpen = true),
                    ),
                    if (_unread.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.done_all_rounded,
                          color: AppColors.primary,
                        ),
                        tooltip: 'Mark all read',
                        onPressed: _markAllRead,
                      ),
                  ],
                ],
              ),
            ),

            // ── Tabs ─────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  _TabChip(
                    label: 'All',
                    count: _all.length,
                    selected: _tabIndex == 0,
                    onTap: () => setState(() => _tabIndex = 0),
                  ),
                  const SizedBox(width: 8),
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

            // ── List ─────────────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : _filtered.isEmpty
                  ? _EmptyState(
                      tabIndex: _tabIndex,
                      hasQuery: _query.isNotEmpty,
                      query: _query,
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      backgroundColor: AppColors.cardBackground,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 40),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) => _NotificationTile(
                          notification: _filtered[i],
                          onTap: () => _handleTap(_filtered[i]),
                          onMarkRead: _filtered[i].read
                              ? null
                              : () => _markRead(_filtered[i]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATION TILE — mirrors ConversationTile style exactly
// ═══════════════════════════════════════════════════════════════════════════════

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    this.onMarkRead,
  });

  // Derive readable title + body from type and payload
  _NotifContent _parse() {
    try {
      final data = jsonDecode(notification.payload) as Map<String, dynamic>;
      final msg = data['message'] as String? ?? '';
      final propertyTitle = data['propertyTitle'] as String? ?? '';

      switch (notification.type) {
        case 'NEW_CHAT_MESSAGE':
          final sender = data['senderName'] as String? ?? 'Someone';
          final preview = data['messagePreview'] as String? ?? '';
          return _NotifContent(
            icon: Icons.chat_bubble_outline_rounded,
            iconColor: AppColors.primary,
            title: sender,
            body: preview.isNotEmpty ? preview : 'Sent you a message',
            sub: propertyTitle,
          );
        case 'NEW_CONVERSATION':
          final client = data['clientName'] as String? ?? 'Someone';
          return _NotifContent(
            icon: Icons.forum_outlined,
            iconColor: AppColors.primary,
            title: client,
            body: 'Started a conversation',
            sub: propertyTitle,
          );
        case 'VISIT_REQUEST_CREATED':
          return _NotifContent(
            icon: Icons.calendar_today_outlined,
            iconColor: const Color(0xFF7B61FF),
            title: 'Visit Request',
            body: msg.isNotEmpty ? msg : 'New visit request received',
            sub: propertyTitle,
          );
        case 'VISIT_REQUEST_STATUS_CHANGED':
          final status = data['status'] as String? ?? '';
          return _NotifContent(
            icon: Icons.event_available_outlined,
            iconColor: status == 'APPROVED'
                ? AppColors.success
                : AppColors.error,
            title: 'Visit Update',
            body: msg.isNotEmpty ? msg : 'Your visit request was updated',
            sub: propertyTitle,
          );
        case 'BOOST_CREATED':
          return _NotifContent(
            icon: Icons.rocket_launch_outlined,
            iconColor: const Color(0xFFFF9800),
            title: 'Boost Created',
            body: msg.isNotEmpty ? msg : 'Your boost has been created',
            sub: propertyTitle,
          );
        case 'BOOST_STATUS_CHANGED':
          return _NotifContent(
            icon: Icons.rocket_launch_rounded,
            iconColor: const Color(0xFFFF9800),
            title: 'Boost Update',
            body: msg.isNotEmpty ? msg : 'Your boost status changed',
            sub: propertyTitle,
          );
        case 'PROPERTY_CREATED':
          return _NotifContent(
            icon: Icons.home_outlined,
            iconColor: AppColors.primary,
            title: 'Property Created',
            body: msg.isNotEmpty ? msg : 'Your property has been created',
            sub: propertyTitle,
          );
        default:
          return _NotifContent(
            icon: Icons.notifications_outlined,
            iconColor: AppColors.textSecondary,
            title: notification.type
                .replaceAll('_', ' ')
                .toLowerCase()
                .split(' ')
                .map(
                  (w) =>
                      w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}',
                )
                .join(' '),
            body: msg.isNotEmpty ? msg : 'New notification',
            sub: propertyTitle,
          );
      }
    } catch (_) {
      return _NotifContent(
        icon: Icons.notifications_outlined,
        iconColor: AppColors.textSecondary,
        title: 'Notification',
        body: notification.payload,
        sub: '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _parse();
    final unread = !notification.read;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: unread
              ? AppColors.primary.withOpacity(0.03)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: AppColors.borderLight, width: 0.8),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon avatar ───────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: content.iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(content.icon, color: content.iconColor, size: 22),
            ),
            const SizedBox(width: 14),

            // ── Content ───────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          content.title,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: unread
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      if (unread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  if (content.sub.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.home_outlined,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            content.sub,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Mark read button ──────────────────────────
            if (onMarkRead != null)
              GestureDetector(
                onTap: onMarkRead,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: AppColors.primary.withOpacity(0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotifContent {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String sub;
  const _NotifContent({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.sub,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// SEARCH FIELD — identical to ConversationsScreen
// ═══════════════════════════════════════════════════════════════════════════════

class _SearchField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => FocusScope.of(context).requestFocus(_focus),
    );
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.subtleBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              onChanged: widget.onChanged,
              decoration: const InputDecoration(
                hintText: 'Search notifications...',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB CHIP
// ═══════════════════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final int tabIndex;
  final bool hasQuery;
  final String query;

  const _EmptyState({
    required this.tabIndex,
    required this.hasQuery,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final isSearch = hasQuery;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.subtleBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearch
                  ? Icons.search_off_rounded
                  : tabIndex == 1
                  ? Icons.mark_email_read_outlined
                  : Icons.notifications_none_rounded,
              size: 32,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSearch
                ? 'No results for "$query"'
                : tabIndex == 1
                ? 'All caught up!'
                : 'No notifications yet',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isSearch
                ? 'Try a different search term'
                : tabIndex == 1
                ? 'No unread notifications'
                : "You'll see notifications here",
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
