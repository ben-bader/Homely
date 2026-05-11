from pathlib import Path
import re

def replace_in_file(path, pattern, repl, flags=0):
    text = path.read_text(encoding='utf-8')
    new_text = re.sub(pattern, repl, text, flags=flags)
    if new_text != text:
        path.write_text(new_text, encoding='utf-8')
        print(f'Updated {path}')

root = Path('lib')

# Notification screen full rewrite of state class
ns_path = root/'ui'/'screens'/'notifications'/'notifications_screen.dart'
if ns_path.exists():
    text = ns_path.read_text(encoding='utf-8')
    text = text.replace("import 'package:mobile/infrastructure/services/notification_service.dart';\n", '')
    text = text.replace("import 'package:mobile/data/models/notification/notification_model.dart';\n", "import 'package:mobile/domain/entities/notification/notification_entity.dart';\n")
    start = 'class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {'
    end = 'class _NotificationTile extends StatelessWidget {'
    if start in text and end in text:
        before, rest = text.split(start, 1)
        _, after = rest.split(end, 1)
        new_state = '''class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
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
'''
        text = before + new_state + end + after
        ns_path.write_text(text, encoding='utf-8')
        print(f'Rewritten {ns_path}')

# General UI fixes
replacements = [
    # Favorites screen
    ('lib/ui/screens/favorites/favorites_screen.dart',
     "import 'package:mobile/features/favorites/models/favorite.dart';\n",
     "import 'package:mobile/domain/entities/favorite/favorite_entity.dart';\n"),
    ('lib/ui/screens/favorites/favorites_screen.dart',
     "import 'package:mobile/features/favorites/providers/favorite_providers.dart';\n",
     "import 'package:mobile/ui/providers/favorite_providers.dart';\n"),
    ('lib/ui/screens/favorites/favorites_screen.dart',
     "import 'package:mobile/features/property/models/property.dart';\n",
     "import 'package:mobile/domain/entities/property/property_entity.dart';\n"),
    ('lib/ui/screens/favorites/favorites_screen.dart',
     "import 'package:mobile/features/property/providers/property_providers.dart';\n",
     "import 'package:mobile/ui/providers/property_providers.dart';\n"),
    ('lib/ui/screens/favorites/favorites_screen.dart',
     "import 'package:mobile/features/property/screens/property_detail_screen.dart';\n",
     "import 'package:mobile/ui/screens/property/property_detail_screen.dart';\n"),
    ('lib/ui/screens/favorites/favorites_screen.dart',
     r'final List<Favorite> favorites;',
     'final List<FavoriteEntity> favorites;'),
    ('lib/ui/screens/favorites/favorites_screen.dart',
     r'final Favorite favorite;',
     'final FavoriteEntity favorite;'),
    ('lib/ui/screens/favorites/favorites_screen.dart',
     r'final Property property;',
     'final PropertyEntity property;'),

    # Notification card
    ('lib/ui/widgets/notifications/notification_card.dart',
     "import '../../../data/models/notification/notification.dart';\n",
     "import 'package:mobile/domain/entities/notification/notification_entity.dart';\n"),
    ('lib/ui/widgets/notifications/notification_card.dart',
     r'final NotificationModel notification;',
     'final NotificationEntity notification;'),
    ('lib/ui/widgets/notifications/notification_card.dart',
     r'required this.notification,',
     'required this.notification,'),

    # Report sheet auth provider
    ('lib/ui/widgets/reports/report_sheet.dart',
     "import '../../../infrastructure/services/auth_service.dart';\n",
     "import 'package:mobile/ui/providers/auth_providers.dart';\n"),
    ('lib/ui/widgets/reports/report_sheet.dart',
     r'final authService = AuthService\(\);\n      final currentUserId = await authService.getCurrentUserId\(\);',
     'final currentUserId = await ref.read(authRepositoryProvider).getCurrentUserId();'),

    # Property detail screen imports
    ('lib/ui/screens/property/property_detail_screen.dart',
     "import '../../../data/models/property/property.dart';\n",
     "import 'package:mobile/domain/entities/property/property_entity.dart';\n"),
    ('lib/ui/screens/property/property_detail_screen.dart',
     "import '../../../data/models/media/property_media.dart';\n",
     "import 'package:mobile/domain/entities/media/property_media_entity.dart';\n"),

    # Media gallery import
    ('lib/ui/widgets/media/property_media_gallery.dart',
     "import '../../../data/models/media/property_media.dart';\n",
     "import 'package:mobile/domain/entities/media/property_media_entity.dart';\n"),

    # Boost sheet import
    ('lib/ui/widgets/boost/boost_sheet.dart',
     "import '../../../data/models/boost/boost_package.dart';\n",
     "import 'package:mobile/domain/entities/boost/boost_package_entity.dart';\n"),

    # Tours screen imports
    ('lib/ui/screens/tours/tours_screen.dart',
     "import '../../../data/models/media/property_media.dart';\n",
     "import 'package:mobile/domain/entities/media/property_media_entity.dart';\n"),
    ('lib/ui/screens/tours/tours_screen.dart',
     "import '../../../data/repositories/media_repository.dart';\n",
     "import '../../../ui/providers/media_providers.dart';\n"),
    ('lib/ui/screens/tours/tours_screen.dart',
     "import '../../../data/models/property/property.dart';\n",
     "import 'package:mobile/domain/entities/property/property_entity.dart';\n"),

    # Video player screen imports
    ('lib/ui/widgets/tours/video_player_screen.dart',
     "import '../../../data/repositories/chat_repository.dart';\n",
     "import '../../../ui/providers/chat_providers.dart';\n"),
    ('lib/ui/widgets/tours/video_player_screen.dart',
     "import '../../../data/models/media/property_media.dart';\n",
     "import 'package:mobile/domain/entities/media/property_media_entity.dart';\n"),
    ('lib/ui/widgets/tours/video_player_screen.dart',
     "import '../../../data/models/property/property.dart';\n",
     "import 'package:mobile/domain/entities/property/property_entity.dart';\n"),

    # Feedback list import
    ('lib/ui/widgets/feedback/feedback_list.dart',
     "import '../../../data/models/feedback/feedback.dart' as fb;\n",
     "import 'package:mobile/domain/entities/feedback/feedback_entity.dart' as fb;\n"),

    # Visit requests import
    ('lib/ui/screens/visit_requests/my_visit_requests_screen.dart',
     "import '../../../data/models/visit_request/visit_request.dart';\n",
     "import 'package:mobile/domain/entities/visit_request/visit_request_entity.dart';\n"),
    ('lib/ui/screens/visit_requests/seller_visit_requests_screen.dart',
     "import '../../../data/models/visit_request/visit_request.dart';\n",
     "import 'package:mobile/domain/entities/visit_request/visit_request_entity.dart';\n"),
]

for file_path, old, new in replacements:
    replace_in_file(Path(file_path), re.escape(old), new)

# Type replacements in specific files
replace_in_file(Path('lib/ui/screens/favorites/favorites_screen.dart'), r'\bFavorite\b', 'FavoriteEntity')
replace_in_file(Path('lib/ui/screens/favorites/favorites_screen.dart'), r'\bProperty\b', 'PropertyEntity')
replace_in_file(Path('lib/ui/widgets/notifications/notification_card.dart'), r'\bNotificationModel\b', 'NotificationEntity')
replace_in_file(Path('lib/ui/widgets/media/property_media_gallery.dart'), r'\bPropertyMedia\b', 'PropertyMediaEntity')
replace_in_file(Path('lib/ui/widgets/boost/boost_sheet.dart'), r'\bBoostPackage\b', 'BoostPackageEntity')
replace_in_file(Path('lib/ui/screens/tours/tours_screen.dart'), r'\bPropertyMedia\b', 'PropertyMediaEntity')
replace_in_file(Path('lib/ui/screens/tours/tours_screen.dart'), r'\bProperty\b', 'PropertyEntity')
replace_in_file(Path('lib/ui/widgets/tours/video_player_screen.dart'), r'\bPropertyMedia\b', 'PropertyMediaEntity')
replace_in_file(Path('lib/ui/widgets/tours/video_player_screen.dart'), r'\bProperty\b', 'PropertyEntity')
replace_in_file(Path('lib/ui/widgets/feedback/feedback_list.dart'), r'\bbf\.Feedback\b', 'fb.FeedbackEntity')
replace_in_file(Path('lib/ui/screens/visit_requests/my_visit_requests_screen.dart'), r'\bVisitRequest\b', 'VisitRequestEntity')
replace_in_file(Path('lib/ui/screens/visit_requests/seller_visit_requests_screen.dart'), r'\bVisitRequest\b', 'VisitRequestEntity')

# Profile screen updates
profile_path = Path('lib/ui/screens/profile/profile_screen.dart')
profile_text = profile_path.read_text(encoding='utf-8')
profile_text = profile_text.replace("import 'package:mobile/data/models/profile/profile_model.dart';\n", '')
profile_text = profile_text.replace("import 'package:mobile/data/repositories/profile_repository_impl.dart';\n", '')
profile_text = profile_text.replace("import 'package:mobile/ui/providers/property_providers.dart';\n", "import 'package:mobile/ui/providers/property_providers.dart';\nimport 'package:mobile/ui/providers/profile_providers.dart';\nimport 'package:mobile/ui/providers/auth_providers.dart';\nimport 'package:mobile/domain/entities/profile/profile_entity.dart';\nimport 'package:mobile/domain/entities/property/property_entity.dart';\n")
profile_text = re.sub(r'final Profile profile;', 'final ProfileEntity profile;', profile_text)
profile_text = profile_text.replace('await AuthService().logout();', 'await ref.read(authRepositoryProvider).logout();')
profile_path.write_text(profile_text, encoding='utf-8')
print(f'Updated {profile_path} for profile and auth')

# Property detail and related widgets type replacements
replace_in_file(Path('lib/ui/screens/property/property_detail_screen.dart'), r'\bProperty\b', 'PropertyEntity')
replace_in_file(Path('lib/ui/screens/property/property_detail_screen.dart'), r'\bPropertyMedia\b', 'PropertyMediaEntity')
replace_in_file(Path('lib/ui/widgets/media/property_media_gallery.dart'), r'\bPropertyMedia\b', 'PropertyMediaEntity')
replace_in_file(Path('lib/ui/widgets/tours/video_player_screen.dart'), r'\bPropertyMedia\b', 'PropertyMediaEntity')
replace_in_file(Path('lib/ui/screens/visit_requests/my_visit_requests_screen.dart'), r'\bVisitRequestEntity\b', 'VisitRequestEntity')
replace_in_file(Path('lib/ui/screens/visit_requests/seller_visit_requests_screen.dart'), r'\bVisitRequestEntity\b', 'VisitRequestEntity')

print('Patch complete')
