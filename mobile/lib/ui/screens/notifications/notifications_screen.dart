import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homely/core/theme/app_colors.dart';
import 'package:homely/ui/screens/boost/my_boosts_screen.dart';
import 'package:homely/domain/entities/notification/notification_entity.dart';
import 'package:homely/ui/screens/chat/conversations_screen.dart';
import 'package:homely/ui/screens/visit_requests/seller_visit_requests_screen.dart';
import 'package:homely/ui/screens/property/property_detail_screen.dart';
import 'package:homely/ui/widgets/boost/boost_sheet.dart';
import 'package:homely/ui/screens/chat/chat_screen.dart';
import 'package:homely/ui/providers/notification_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  final String userId;
  const NotificationsScreen({super.key, required this.userId});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _tabIndex = 0;
  bool _searchOpen = false;
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<NotificationEntity> _filterNotifications(List<NotificationEntity> notifications) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return notifications;

    return notifications.where((notification) {
      try {
        final data = jsonDecode(notification.payload) as Map<String, dynamic>;
        final message = (data['message'] ?? '').toString().toLowerCase();
        final title = (data['propertyTitle'] ?? '').toString().toLowerCase();
        return message.contains(query) ||
            title.contains(query) ||
            notification.type.toLowerCase().contains(query);
      } catch (_) {
        return notification.type.toLowerCase().contains(query);
      }
    }).toList();
  }

  Future<void> _markRead(NotificationEntity notification) async {
    await ref.read(notificationRepositoryProvider).markAsRead(notification.id);
    ref.invalidate(notificationsProvider(widget.userId));
  }

  Future<void> _markAllRead(List<NotificationEntity> notifications) async {
    for (final notification in notifications.where((n) => !n.read)) {
      await ref.read(notificationRepositoryProvider).markAsRead(notification.id);
    }
    ref.invalidate(notificationsProvider(widget.userId));
  }

  void _handleTap(NotificationEntity notification) {
    try {
      final data = jsonDecode(notification.payload) as Map<String, dynamic>;

      switch (notification.type) {
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
                  chatTitle: data['senderName'] as String? ??
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
        case 'BOOST_CREATED':
        case 'BOOST_STATUS_CHANGED':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyBoostsScreen()),
          );
          break;
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
    final notificationsAsync = ref.watch(notificationsProvider(widget.userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: notificationsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                e.toString(),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (notifications) {
            final allNotifications = notifications;
            final unreadNotifications =
                allNotifications.where((n) => !n.read).toList();
            final filteredNotifications =
                _filterNotifications(allNotifications);

            return Column(
              children: [
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
                          icon: const Icon(Icons.search,
                              color: AppColors.accent),
                          onPressed: () => setState(() => _searchOpen = true),
                        ),
                        if (unreadNotifications.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.done_all_rounded,
                              color: AppColors.primary,
                            ),
                            tooltip: 'Mark all read',
                            onPressed: () => _markAllRead(allNotifications),
                          ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      _TabChip(
                        label: 'All',
                        count: allNotifications.length,
                        selected: _tabIndex == 0,
                        onTap: () => setState(() => _tabIndex = 0),
                      ),
                      const SizedBox(width: 8),
                      _TabChip(
                        label: 'Unread',
                        count: unreadNotifications.length,
                        selected: _tabIndex == 1,
                        onTap: () => setState(() => _tabIndex = 1),
                        isUnread: true,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredNotifications.isEmpty
                      ? _EmptyState(
                          tabIndex: _tabIndex,
                          hasQuery: _query.isNotEmpty,
                          query: _query,
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(
                                notificationsProvider(widget.userId));
                          },
                          backgroundColor: AppColors.cardBackground,
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 4, bottom: 40),
                            itemCount: filteredNotifications.length,
                            itemBuilder: (_, i) {
                              final notification = filteredNotifications[i];
                              return _NotificationTile(
                                notification: notification,
                                onTap: () => _handleTap(notification),
                                onMarkRead: notification.read
                                    ? null
                                    : () => _markRead(notification),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
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
