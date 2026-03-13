import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/chat/screens/conversation_screen.dart';
import 'package:mobile/features/notifications/screens/notifications_screen.dart';
import 'package:mobile/features/notifications/services/notification_service.dart';
import 'package:mobile/features/property/models/property.dart';
import 'package:mobile/features/property/providers/property_providers.dart'
    hide sellerListingsProvider;
import 'package:mobile/features/profile/screens/profile_screen.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/seller/screens/create_property_screen.dart';
import 'package:mobile/features/seller/screens/edit_property_screen.dart';
import 'package:mobile/features/seller/providers/seller_providers.dart';
import 'package:mobile/features/boost/widgets/boost_sheet.dart';
import 'package:mobile/features/visit_requests/screens/seller_visit_requests_screen.dart';
import 'package:mobile/features/tours/screens/tours_screen.dart';
import 'property_detail_screen.dart';

final navIndexProvider = StateProvider<int>((ref) => 0);

final userRoleProvider = FutureProvider<String>((ref) async {
  final authService = AuthService();
  return authService.getUserRoleFromStorage();
});

// ── Nav badge counts ──────────────────────────────────────────────────────────
class _NavBadges {
  final int inbox;
  final int listings;
  const _NavBadges({this.inbox = 0, this.listings = 0});
}

final navBadgesProvider = FutureProvider.autoDispose<_NavBadges>((ref) async {
  final authService = AuthService();
  final userId = await authService.getCurrentUserId();
  if (userId == null) return const _NavBadges();

  final notifications = await NotificationService().fetchUnread(userId);
  final unread = notifications.where((n) => !n.read).toList();

  const inboxTypes = {'NEW_CHAT_MESSAGE', 'CONVERSATION_CREATED'};
  const listingsTypes = {
    'VISIT_REQUEST_CREATED',
    'VISIT_REQUEST_STATUS_CHANGED',
    'BOOST_STATUS_CHANGED',
    'BOOST_PURCHASED',
    'FEEDBACK_RECEIVED',
  };

  final inbox = unread.where((n) => inboxTypes.contains(n.type)).length;
  final listings = unread.where((n) => listingsTypes.contains(n.type)).length;

  return _NavBadges(inbox: inbox, listings: listings);
});

// ── Seller listing filter ─────────────────────────────────────────────────────
class SellerListingFilter {
  final String? search;
  final PropertyType? propertyType;
  final PropertyStatus? status;

  const SellerListingFilter({this.search, this.propertyType, this.status});

  bool get isFiltering =>
      (search != null && search!.isNotEmpty) ||
      propertyType != null ||
      status != null;

  SellerListingFilter copyWith({
    String? search,
    PropertyType? propertyType,
    PropertyStatus? status,
    bool clearSearch = false,
    bool clearType = false,
    bool clearStatus = false,
  }) => SellerListingFilter(
    search: clearSearch ? null : (search ?? this.search),
    propertyType: clearType ? null : (propertyType ?? this.propertyType),
    status: clearStatus ? null : (status ?? this.status),
  );
}

final sellerListingFilterProvider = StateProvider<SellerListingFilter>(
  (ref) => const SellerListingFilter(),
);

// ═════════════════════════════════════════════════════════════════════════════
// HomeScreen
// ═════════════════════════════════════════════════════════════════════════════
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(navIndexProvider);
    final userRoleAsync = ref.watch(userRoleProvider);

    return userRoleAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: AppColors.background,
        body: const _PlaceholderTab(label: 'Error loading user'),
      ),
      data: (userRole) {
        final isSeller = userRole == 'SELLER';
        final tabs = isSeller ? _buildSellerTabs() : _buildClientTabs();

        ref.listen(navIndexProvider, (_, __) {
          ref.invalidate(navBadgesProvider);
        });

        return Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true,
          body: Stack(
            children: [IndexedStack(index: idx, children: tabs)],
          ),
          bottomNavigationBar: _BottomNav(isSeller: isSeller),
        );
      },
    );
  }

  List<Widget> _buildClientTabs() => [
    const _ExploreTab(),
    const ToursScreen(),
    const ConversationsScreen(),
    const _PlaceholderTab(label: 'Favorites'),
    const ProfileScreen(),
  ];

  List<Widget> _buildSellerTabs() => [
    const _SellerListingsTab(),
    const ConversationsScreen(),
    const _CreatePropertyPlaceholder(),
    const _ExploreTab(),
    const ProfileScreen(),
  ];
}

class _CreatePropertyPlaceholder extends StatelessWidget {
  const _CreatePropertyPlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});
  @override
  Widget build(BuildContext context) =>
      Center(child: Text(label, style: Theme.of(context).textTheme.titleLarge));
}

// ═════════════════════════════════════════════════════════════════════════════
// SELLER LISTINGS TAB
// ═════════════════════════════════════════════════════════════════════════════
class _SellerListingsTab extends ConsumerStatefulWidget {
  const _SellerListingsTab();
  @override
  ConsumerState<_SellerListingsTab> createState() => _SellerListingsTabState();
}

class _SellerListingsTabState extends ConsumerState<_SellerListingsTab> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _scrollController = ScrollController();
  Timer? _debounce;
  bool _searchFocused = false;
  List<String> _suggestions = [];

  final _authService = AuthService();
  String? _userId;

  static const _statusChips = [
    'All',
    'Active',
    'Inactive',
    'Sold',
    'Rented',
    'Draft',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _searchFocusNode.addListener(() {
      setState(() => _searchFocused = _searchFocusNode.hasFocus);
      if (!_searchFocusNode.hasFocus) setState(() => _suggestions = []);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    _userId = await _authService.getCurrentUserId();
    if (mounted) setState(() {});
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    final allListings = ref
        .read(sellerListingsProvider)
        .maybeWhen(data: (l) => l, orElse: () => <Property>[]);
    if (value.trim().isEmpty) {
      setState(() => _suggestions = []);
    } else {
      final q = value.trim().toLowerCase();
      final Set<String> seen = {};
      final List<String> results = [];
      for (final p in allListings) {
        if (p.title.toLowerCase().contains(q) && seen.add(p.title))
          results.add(p.title);
        if (p.address.toLowerCase().contains(q) && seen.add(p.address))
          results.add(p.address);
      }
      setState(() => _suggestions = results.take(5).toList());
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref
          .read(sellerListingFilterProvider.notifier)
          .update((s) => s.copyWith(search: value.trim()));
    });
  }

  void _onSearchSubmitted(String value) {
    _debounce?.cancel();
    setState(() => _suggestions = []);
    _searchFocusNode.unfocus();
    ref
        .read(sellerListingFilterProvider.notifier)
        .update((s) => s.copyWith(search: value.trim()));
  }

  void _onSuggestionTap(String s) {
    _searchController.text = s;
    setState(() => _suggestions = []);
    _searchFocusNode.unfocus();
    ref
        .read(sellerListingFilterProvider.notifier)
        .update((f) => f.copyWith(search: s));
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _suggestions = []);
    ref
        .read(sellerListingFilterProvider.notifier)
        .update((s) => s.copyWith(clearSearch: true));
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final filter = ref.watch(sellerListingFilterProvider);
    final listingsAsync = ref.watch(sellerListingsProvider);

    final filtered = listingsAsync.maybeWhen(
      data: (list) {
        var result = list;
        if (filter.search != null && filter.search!.isNotEmpty) {
          final q = filter.search!.toLowerCase();
          result = result
              .where(
                (p) =>
                    p.title.toLowerCase().contains(q) ||
                    p.address.toLowerCase().contains(q),
              )
              .toList();
        }
        if (filter.propertyType != null) {
          result = result
              .where((p) => p.propertyType == filter.propertyType)
              .toList();
        }
        if (filter.status != null) {
          result = result.where((p) => p.status == filter.status).toList();
        }
        return result;
      },
      orElse: () => <Property>[],
    );

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'My Listings',
                      style: tt.headlineSmall?.copyWith(
                        color: AppColors.accent,
                        letterSpacing: -0.5,
                        height: 1.1,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _NotifBtn(
                    onTap: () async {
                      if (_userId == null) await _loadUserId();
                      if (_userId == null || !mounted) return;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationsScreen(userId: _userId!),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                  const SizedBox(width: 10),
                  const _AvatarBtn(),
                ],
              ),
            ),
          ),

          // ── Search bar + suggestions ──────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.subtleBackground,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(1, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(
                          Icons.search_rounded,
                          color: _searchFocused
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: _onSearchChanged,
                            onSubmitted: _onSearchSubmitted,
                            style: tt.bodyLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search your listings...',
                              hintStyle: tt.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _searchController,
                          builder: (_, value, __) => value.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: _clearSearch,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: AppColors.textTertiary,
                                      size: 18,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: AppColors.borderLight,
                        ),
                        GestureDetector(
                          onTap: () => ref.invalidate(sellerListingsProvider),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(
                              Icons.refresh_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_suggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: _suggestions.asMap().entries.map((entry) {
                          final i = entry.key;
                          final s = entry.value;
                          final isLast = i == _suggestions.length - 1;
                          return Column(
                            children: [
                              InkWell(
                                onTap: () => _onSuggestionTap(s),
                                borderRadius: BorderRadius.vertical(
                                  top: i == 0
                                      ? const Radius.circular(16)
                                      : Radius.zero,
                                  bottom: isLast
                                      ? const Radius.circular(16)
                                      : Radius.zero,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 13,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.search_rounded,
                                        size: 17,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          s,
                                          style: tt.bodyMedium?.copyWith(
                                            color: AppColors.accent,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Divider(
                                  height: 1,
                                  color: AppColors.borderLight,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Status filter chips ───────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                itemCount: _statusChips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final chip = _statusChips[i];
                  final selected = chip == 'All'
                      ? filter.status == null
                      : filter.status?.label == chip;
                  return GestureDetector(
                    onTap: () {
                      if (chip == 'All') {
                        ref
                            .read(sellerListingFilterProvider.notifier)
                            .update((s) => s.copyWith(clearStatus: true));
                      } else {
                        final st = PropertyStatus.values.firstWhere(
                          (e) => e.label == chip,
                          orElse: () =>
                              PropertyStatus.values.first,
                        );
                        final isSame = filter.status == st;
                        ref
                            .read(sellerListingFilterProvider.notifier)
                            .update(
                              (s) => s.copyWith(
                                clearStatus: isSame,
                                status: isSame ? null : st,
                              ),
                            );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.borderMedium,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          chip,
                          style: tt.labelMedium?.copyWith(
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 14,
                            color: selected ? Colors.white : AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Section header ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    filter.isFiltering ? 'Filtered' : 'All Listings',
                    style: tt.titleLarge?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  if (filter.isFiltering)
                    GestureDetector(
                      onTap: () => ref
                          .read(sellerListingFilterProvider.notifier)
                          .update((_) => const SellerListingFilter()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Clear all',
                          style: tt.labelSmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    listingsAsync.maybeWhen(
                      data: (l) => Text(
                        '${l.length} properties',
                        style: tt.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
          ),

          // ── Listings content ──────────────────────────────
          listingsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
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
                      child: const Icon(
                        Icons.wifi_off_rounded,
                        size: 32,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      style: tt.titleSmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$e',
                      textAlign: TextAlign.center,
                      style: tt.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(sellerListingsProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Try Again',
                        style: tt.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (_) => filtered.isEmpty
                ? SliverFillRemaining(
                    child: Center(
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
                            child: const Icon(
                              Icons.home_outlined,
                              size: 32,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            filter.isFiltering
                                ? 'No listings match'
                                : 'No listings yet',
                            style: tt.titleSmall?.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            filter.isFiltering
                                ? 'Try adjusting your filters'
                                : 'Tap + to create your first listing',
                            style: tt.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) => _SellerPropertyCard(
                        property: filtered[i],
                        onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => PropertyDetailScreen(
                              propertyId: filtered[i].id,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

// ── Seller property card ──────────────────────────────────────────────────────
class _SellerPropertyCard extends ConsumerWidget {
  final Property property;
  final VoidCallback onTap;
  const _SellerPropertyCard({required this.property, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: property.images.isNotEmpty
                    ? Image.network(
                        property.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleSmall?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${_fmt(property.price)}',
                        style: tt.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: property.status.color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      property.status.label.toUpperCase(),
                      style: tt.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _CardBtn(
                          icon: Icons.calendar_today_outlined,
                          label: 'Visits',
                          color: AppColors.primary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SellerVisitRequestsScreen(
                                propertyId: property.id,
                                propertyTitle: property.title,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CardBtn(
                          icon: Icons.rocket_launch_rounded,
                          label: 'Boost',
                          color: AppColors.warning,
                          onTap: () => BoostSheet.show(
                            context,
                            propertyId: property.id,
                            propertyTitle: property.title,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CardBtn(
                          icon: Icons.edit_outlined,
                          label: 'Edit',
                          color: AppColors.accent,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditPropertyScreen(property: property),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    height: 150,
    color: AppColors.subtleBackground,
    child: const Center(
      child: Icon(Icons.home_outlined, size: 40, color: AppColors.textTertiary),
    ),
  );

  String _fmt(double p) {
    if (p >= 1000000) return '${(p / 1000000).toStringAsFixed(1)}M';
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(0)}K';
    return p.toStringAsFixed(0);
  }
}

// ── Card action button ────────────────────────────────────────────────────────
class _CardBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _CardBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// EXPLORE TAB
// ═════════════════════════════════════════════════════════════════════════════
class _ExploreTab extends ConsumerStatefulWidget {
  const _ExploreTab();
  @override
  ConsumerState<_ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends ConsumerState<_ExploreTab> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _layerLink = LayerLink();
  final _focusNode = FocusNode();
  OverlayEntry? _suggestionEntry;
  Timer? _debounce;
  bool _searchFocused = false;

  static const _types = [
    'All types',
    'Rent',
    'Sell',
    'House',
    'Apartment',
    'Villa',
  ];
  static const _listingTypes = {'Rent', 'Sell'};

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  final _authService = AuthService();
  String? _userId;

  Future<void> _loadUserId() async {
    _userId = await _authService.getCurrentUserId();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _hideSuggestion();
    _searchController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _showSuggestion(String text) {
    _hideSuggestion();
    if (text.trim().isEmpty) return;
    _suggestionEntry = OverlayEntry(
      builder: (_) => Positioned(
        width: MediaQuery.of(context).size.width - 48,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                title: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  _hideSuggestion();
                  _focusNode.unfocus();
                  _onSearchSubmitted(text);
                },
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_suggestionEntry!);
  }

  void _hideSuggestion() {
    _suggestionEntry?.remove();
    _suggestionEntry = null;
  }

  void _onSearchChanged(String value) {
    if (value.trim().isEmpty) {
      _hideSuggestion();
    } else {
      _showSuggestion(value.trim());
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref
          .read(propertyFilterProvider.notifier)
          .update((s) => s.copyWith(search: value.trim()));
    });
  }

  void _onSearchSubmitted(String value) {
    _hideSuggestion();
    _debounce?.cancel();
    ref
        .read(propertyFilterProvider.notifier)
        .update((s) => s.copyWith(search: value.trim()));
  }

  void _onChipTap(String tapped) {
    final notifier = ref.read(propertyFilterProvider.notifier);
    if (tapped == 'All types') {
      notifier.update((s) => s.clearFilters());
      return;
    }
    final filter = ref.read(propertyFilterProvider);
    if (_listingTypes.contains(tapped)) {
      final mapped = tapped == 'Rent' ? ListingType.rent : ListingType.sell;
      final isSame = filter.listingType == mapped;
      notifier.update(
        (s) => s.copyWith(
          clearListingType: isSame,
          listingType: isSame ? null : mapped,
        ),
      );
    } else {
      final mapped = PropertyType.values.firstWhere(
        (e) => e.label == tapped,
        orElse: () => PropertyType.apartment,
      );
      final isSame = filter.propertyType == mapped;
      notifier.update(
        (s) => s.copyWith(
          clearPropertyType: isSame,
          propertyType: isSame ? null : mapped,
        ),
      );
    }
  }

  bool _isChipSelected(String chip, PropertyFilter filter) {
    if (chip == 'All types') return !filter.isFiltering;
    if (_listingTypes.contains(chip)) {
      return filter.listingType ==
          (chip == 'Rent' ? ListingType.rent : ListingType.sell);
    }
    final mapped = PropertyType.values.firstWhere(
      (e) => e.label == chip,
      orElse: () => PropertyType.apartment,
    );
    return filter.propertyType == mapped;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final filter = ref.watch(propertyFilterProvider);
    final badgeCount = filter.activeFilterCount;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Explore',
                      style: tt.headlineSmall?.copyWith(
                        color: AppColors.accent,
                        letterSpacing: -0.5,
                        height: 1.1,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  _NotifBtn(
                    onTap: () async {
                      if (_userId == null) await _loadUserId();
                      if (_userId == null || !mounted) return;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationsScreen(userId: _userId!),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                  const SizedBox(width: 10),
                  const _AvatarBtn(),
                ],
              ),
            ),
          ),

          // ── Search bar ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: CompositedTransformTarget(
                link: _layerLink,
                child: Focus(
                  onFocusChange: (v) {
                    setState(() => _searchFocused = v);
                    if (!v) _hideSuggestion();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.subtleBackground,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(1, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(
                          Icons.search_rounded,
                          color: _searchFocused
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            onChanged: _onSearchChanged,
                            onSubmitted: (v) {
                              _hideSuggestion();
                              _onSearchSubmitted(v);
                            },
                            style: tt.bodyLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'City, neighborhood, address...',
                              hintStyle: tt.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _searchController,
                          builder: (_, value, __) => value.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _hideSuggestion();
                                    _searchController.clear();
                                    ref
                                        .read(propertyFilterProvider.notifier)
                                        .update(
                                          (s) => s.copyWith(clearSearch: true),
                                        );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: AppColors.textTertiary,
                                      size: 18,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: AppColors.borderLight,
                        ),
                        GestureDetector(
                          onTap: () => _showFilterSheet(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  Icons.tune_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                if (badgeCount > 0)
                                  Positioned(
                                    top: -5,
                                    right: -7,
                                    child: Container(
                                      width: 15,
                                      height: 15,
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$badgeCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Filter chips ──────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                itemCount: _types.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final t = _types[i];
                  final selected = _isChipSelected(t, filter);
                  return GestureDetector(
                    onTap: () => _onChipTap(t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.borderMedium,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          t,
                          style: tt.labelMedium?.copyWith(
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 14,
                            color: selected ? Colors.white : AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          if (!filter.isFiltering &&
              (filter.search == null || filter.search!.isEmpty))
            const _FeaturedSection(),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filter.search != null && filter.search!.isNotEmpty
                            ? 'Results'
                            : filter.isFiltering
                            ? 'Filtered'
                            : 'Best Offers',
                        style: tt.titleLarge?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      if (filter.search != null && filter.search!.isNotEmpty)
                        Text(
                          'for "${filter.search}"',
                          style: tt.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  if (filter.isFiltering)
                    GestureDetector(
                      onTap: () => ref
                          .read(propertyFilterProvider.notifier)
                          .update((s) => s.clearFilters()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Clear all',
                          style: tt.labelSmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      'See all',
                      style: tt.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const _PropertyList(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// FEATURED SECTION
// ═════════════════════════════════════════════════════════════════════════════
class _FeaturedSection extends ConsumerWidget {
  const _FeaturedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final propertiesAsync = ref.watch(propertiesProvider);

    return propertiesAsync.maybeWhen(
      data: (props) {
        if (props.isEmpty)
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        final featured = props.take(5).toList();
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured',
                      style: tt.titleLarge?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'See all',
                      style: tt.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  itemCount: featured.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (ctx, i) => _FeaturedCard(
                    property: featured[i],
                    onTap: () => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) =>
                            PropertyDetailScreen(propertyId: featured[i].id),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  const _FeaturedCard({required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              property.images.isNotEmpty
                  ? Image.network(
                      property.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.subtleBackground,
                        child: const Icon(
                          Icons.home_outlined,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.subtleBackground,
                      child: const Icon(
                        Icons.home_outlined,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                    ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.65),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      property.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${_fmt(property.price)}',
                      style: tt.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    property.propertyType.label,
                    style: tt.labelSmall?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(double p) {
    if (p >= 1000000) return '${(p / 1000000).toStringAsFixed(1)}M';
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(0)}K';
    return p.toStringAsFixed(0);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PROPERTY LIST
// ═════════════════════════════════════════════════════════════════════════════
class _PropertyList extends ConsumerWidget {
  const _PropertyList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final propertiesAsync = ref.watch(propertiesProvider);
    final filter = ref.watch(propertyFilterProvider);

    return propertiesAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(
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
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 32,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: tt.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$e',
                style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => ref.invalidate(propertiesProvider),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Try again',
                  style: tt.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (props) => props.isEmpty
          ? SliverFillRemaining(
              child: Center(
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
                      child: const Icon(
                        Icons.search_off_rounded,
                        size: 32,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No properties found',
                      style: tt.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Try adjusting your filters',
                      style: tt.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              sliver: SliverList.separated(
                itemCount: props.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) => PropertyCard(
                  property: props[i],
                  searchQuery: filter.search ?? '',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PropertyDetailScreen(propertyId: props[i].id),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// FILTER SHEET
// ═════════════════════════════════════════════════════════════════════════════
class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();
  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late ListingType? _listingType;
  late PropertyType? _propertyType;
  late TextEditingController _cityController;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  DateTime? _fromDate;
  DateTime? _toDate;

  static const _statuses = ['All', 'Rent', 'Buy'];
  static const _propertyTypes = [
    'Any type',
    'House',
    'Apartment',
    'Villa',
    'Studio',
    'Commercial',
    'Land',
  ];

  @override
  void initState() {
    super.initState();
    final f = ref.read(propertyFilterProvider);
    _listingType = f.listingType;
    _propertyType = f.propertyType;
    _cityController = TextEditingController(text: f.city ?? '');
    _minPriceController = TextEditingController(
      text: f.minPrice != null ? f.minPrice!.toStringAsFixed(0) : '',
    );
    _maxPriceController = TextEditingController(
      text: f.maxPrice != null ? f.maxPrice!.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  String get _statusLabel {
    if (_listingType == null) return 'All';
    if (_listingType == ListingType.rent) return 'Rent';
    return 'Buy';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Select date';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = isFrom ? (_fromDate ?? now) : (_toDate ?? _fromDate ?? now);
    final first = isFrom ? DateTime(2020) : (_fromDate ?? DateTime(2020));
    final last = DateTime(now.year + 5);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.cardBackground,
            onSurface: AppColors.accent,
          ),
          dialogBackgroundColor: AppColors.cardBackground,
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate != null && _toDate!.isBefore(picked)) _toDate = null;
      } else {
        _toDate = picked;
      }
    });
  }

  void _apply() {
    final minText = _minPriceController.text.trim();
    final maxText = _maxPriceController.text.trim();
    ref
        .read(propertyFilterProvider.notifier)
        .update(
          (f) => PropertyFilter(
            search: f.search,
            listingType: _listingType,
            propertyType: _propertyType,
            city: _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
            minPrice: minText.isEmpty ? null : double.tryParse(minText),
            maxPrice: maxText.isEmpty ? null : double.tryParse(maxText),
          ),
        );
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _listingType = null;
      _propertyType = null;
      _cityController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _fromDate = null;
      _toDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: tt.headlineSmall?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                GestureDetector(
                  onTap: _reset,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Reset all',
                      style: tt.labelSmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Listing type',
              style: tt.labelLarge?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: _statuses.map((s) {
                final sel = _statusLabel == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      if (s == 'All')
                        _listingType = null;
                      else if (s == 'Rent')
                        _listingType = ListingType.rent;
                      else
                        _listingType = ListingType.sell;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primary
                            : AppColors.subtleBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        s,
                        style: tt.labelLarge?.copyWith(
                          color: sel ? Colors.white : AppColors.accent,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Property type',
              style: tt.labelLarge?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _propertyTypes.map((t) {
                final sel = t == 'Any type'
                    ? _propertyType == null
                    : _propertyType?.label == t;
                return GestureDetector(
                  onTap: () => setState(() {
                    if (t == 'Any type') {
                      _propertyType = null;
                    } else {
                      _propertyType = PropertyType.values.firstWhere(
                        (e) => e.label == t,
                        orElse: () => PropertyType.apartment,
                      );
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.primary
                          : AppColors.subtleBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      t,
                      style: tt.labelLarge?.copyWith(
                        color: sel ? Colors.white : AppColors.accent,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'City',
              style: tt.labelLarge?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _FilterTextField(
              controller: _cityController,
              hint: 'e.g. Casablanca, Rabat...',
              icon: Icons.location_city_outlined,
            ),
            const SizedBox(height: 24),
            Text(
              'Price range (\$)',
              style: tt.labelLarge?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _FilterTextField(
                    controller: _minPriceController,
                    hint: 'Min',
                    icon: Icons.arrow_downward_rounded,
                    numeric: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '–',
                    style: tt.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: _FilterTextField(
                    controller: _maxPriceController,
                    hint: 'Max',
                    icon: Icons.arrow_upward_rounded,
                    numeric: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Date range',
              style: tt.labelLarge?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    label: 'From',
                    value: _formatDate(_fromDate),
                    hasValue: _fromDate != null,
                    onTap: () => _pickDate(isFrom: true),
                    onClear: () => setState(() => _fromDate = null),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '–',
                    style: tt.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: _DatePickerField(
                    label: 'To',
                    value: _formatDate(_toDate),
                    hasValue: _toDate != null,
                    onTap: () => _pickDate(isFrom: false),
                    onClear: () => setState(() => _toDate = null),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Apply filters',
                  style: tt.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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

// ── Date Picker Field ─────────────────────────────────────────────────────────
class _DatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final bool hasValue;
  final VoidCallback onTap;
  final VoidCallback onClear;
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.hasValue,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: hasValue
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.subtleBackground,
          borderRadius: BorderRadius.circular(12),
          border: hasValue
              ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: hasValue ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                hasValue ? value : label,
                overflow: TextOverflow.ellipsis,
                style: tt.bodySmall?.copyWith(
                  color: hasValue ? AppColors.accent : AppColors.textTertiary,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ),
            if (hasValue)
              GestureDetector(
                onTap: onClear,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

// ── Filter TextField ──────────────────────────────────────────────────────────
class _FilterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool numeric;
  const _FilterTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.numeric = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.subtleBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: numeric ? TextInputType.number : TextInputType.text,
              inputFormatters: numeric
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              style: tt.bodyMedium?.copyWith(color: AppColors.accent),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: tt.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PROPERTY CARD — with search highlight
// ═════════════════════════════════════════════════════════════════════════════
class PropertyCard extends ConsumerWidget {
  final Property property;
  final VoidCallback onTap;
  final String searchQuery;
  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: SizedBox(
                    height: 190,
                    width: double.infinity,
                    child: property.images.isNotEmpty
                        ? Image.network(
                            property.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      property.propertyType.label,
                      style: tt.labelMedium?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 18,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _HighlightText(
                          text: property.title,
                          query: searchQuery,
                          baseStyle: tt.titleSmall?.copyWith(
                            color: AppColors.accent,
                            letterSpacing: -0.3,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${_fmt(property.price)}',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                          letterSpacing: -0.4,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: _HighlightText(
                          text: property.location,
                          query: searchQuery,
                          baseStyle: tt.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: property.chips
                        .take(3)
                        .map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _Chip(icon: c.icon, label: c.label),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double p) {
    if (p >= 1000000) return '${(p / 1000000).toStringAsFixed(1)}M';
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(0)}K';
    return p.toStringAsFixed(0);
  }

  Widget _placeholder() => Container(
    height: 190,
    color: AppColors.subtleBackground,
    child: const Center(
      child: Icon(Icons.home_outlined, size: 48, color: AppColors.textTertiary),
    ),
  );
}

// ── Highlight Text ────────────────────────────────────────────────────────────
class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? baseStyle;
  const _HighlightText({
    required this.text,
    required this.query,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return Text(
        text,
        style: baseStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    final lower = text.toLowerCase();
    final q = query.trim().toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final idx = lower.indexOf(q, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }
      if (idx > start)
        spans.add(TextSpan(text: text.substring(start, idx), style: baseStyle));
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + q.length),
          style: baseStyle?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            backgroundColor: AppColors.primary.withOpacity(0.1),
          ),
        ),
      );
      start = idx + q.length;
    }
    return Text.rich(
      TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ── Chip ──────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.subtleBackground,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// NOTIFICATION BUTTON
// ═════════════════════════════════════════════════════════════════════════════
class _NotifBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _NotifBtn({required this.onTap});
  @override
  State<_NotifBtn> createState() => _NotifBtnState();
}

class _NotifBtnState extends State<_NotifBtn> {
  final _service = NotificationService();
  final _authService = AuthService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = await _authService.getCurrentUserId();
    if (userId == null) return;
    final data = await _service.fetchUnread(userId);
    if (mounted)
      setState(() => _unreadCount = data.where((n) => !n.read).length);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.subtleBackground,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: AppColors.accentLight,
            size: 20,
          ),
        ),
        if (_unreadCount > 0)
          Positioned(
            top: 1,
            right: 1,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

// ── Avatar Button ─────────────────────────────────────────────────────────────
class _AvatarBtn extends StatelessWidget {
  const _AvatarBtn();
  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: AppColors.accentLight,
      borderRadius: BorderRadius.circular(50),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: const Icon(
      Icons.person_rounded,
      color: AppColors.background,
      size: 22,
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// BOTTOM NAV
// ═════════════════════════════════════════════════════════════════════════════
class _BottomNav extends ConsumerWidget {
  final bool isSeller;
  const _BottomNav({this.isSeller = false});

  static const _clientItems = [
    (
      icon: Icons.search_rounded,
      outlinedIcon: Icons.search_rounded,
      label: 'Explore',
    ),
    (
      icon: Icons.slow_motion_video_rounded,
      outlinedIcon: Icons.slow_motion_video_rounded,
      label: 'Tours',
    ),
    (
      icon: Icons.chat_bubble_rounded,
      outlinedIcon: Icons.chat_bubble_outline_rounded,
      label: 'Inbox',
    ),
    (
      icon: Icons.favorite_rounded,
      outlinedIcon: Icons.favorite_border_rounded,
      label: 'Wishlists',
    ),
    (
      icon: Icons.person_rounded,
      outlinedIcon: Icons.person_outline_rounded,
      label: 'Profile',
    ),
  ];

  static const _sellerItems = [
    (
      icon: Icons.home_rounded,
      outlinedIcon: Icons.home_outlined,
      label: 'Listings',
    ),
    (
      icon: Icons.chat_bubble_rounded,
      outlinedIcon: Icons.chat_bubble_outline_rounded,
      label: 'Inbox',
    ),
    (icon: Icons.add_rounded, outlinedIcon: Icons.add_rounded, label: 'Create'),
    (
      icon: Icons.search_rounded,
      outlinedIcon: Icons.search_rounded,
      label: 'Explore',
    ),
    (
      icon: Icons.person_rounded,
      outlinedIcon: Icons.person_outline_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(navIndexProvider);
    final items = isSeller ? _sellerItems : _clientItems;
    final badges = ref
        .watch(navBadgesProvider)
        .maybeWhen(data: (b) => b, orElse: () => const _NavBadges());

    int badgeFor(String label) {
      switch (label) {
        case 'Inbox':
          return badges.inbox;
        case 'Listings':
          return badges.listings;
        default:
          return 0;
      }
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(
                color: Colors.black.withOpacity(0.08),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                children: List.generate(items.length, (i) {
                  final active = i == idx;
                  final item = items[i];
                  final badgeCount = badgeFor(item.label);

                  if (isSeller && i == 2) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreatePropertyScreen(),
                          ),
                        ),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                size: 26,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(navIndexProvider.notifier).state = i,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (child, anim) =>
                                      ScaleTransition(
                                        scale: anim,
                                        child: child,
                                      ),
                                  child: Icon(
                                    active ? item.icon : item.outlinedIcon,
                                    key: ValueKey(active),
                                    size: 26,
                                    color: active
                                        ? AppColors.primary
                                        : AppColors.accent.withAlpha(120),
                                  ),
                                ),
                                if (badgeCount > 0)
                                  Positioned(
                                    top: -4,
                                    right: -6,
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          badgeCount > 99
                                              ? '99+'
                                              : '$badgeCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 150),
                              style: TextStyle(
                                fontFamily: GoogleFonts.outfit().fontFamily,
                                fontSize: 10,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: active
                                    ? AppColors.primary
                                    : AppColors.accent.withAlpha(120),
                                letterSpacing: 0.1,
                              ),
                              child: Text(item.label),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
