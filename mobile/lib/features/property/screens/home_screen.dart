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
import 'package:mobile/features/property/providers/property_providers.dart';
import 'package:mobile/features/profile/screens/profile_screen.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/seller/screens/create_property_screen.dart';
import 'package:mobile/features/seller/screens/seller_listings_screen.dart';
import 'package:mobile/features/tours/screens/tours_screen.dart';
import 'property_detail_screen.dart';

final navIndexProvider = StateProvider<int>((ref) => 0);

// Provider to get user role
final userRoleProvider = FutureProvider<String>((ref) async {
  final authService = AuthService();
  return authService.getUserRoleFromStorage();
});

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

        return Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true,
          body: Stack(
            children: [
              IndexedStack(index: idx, children: tabs),
            ],
          ),
          bottomNavigationBar: _BottomNav(isSeller: isSeller),
        );
      },
    );
  }

  List<Widget> _buildClientTabs() {
    return [
      const _ExploreTab(),
      const ToursScreen(),
      const ConversationsScreen(),
      const _PlaceholderTab(label: 'Favorites'),
      const ProfileScreen(),
    ];
  }

  List<Widget> _buildSellerTabs() {
    // CHANGED: Listings first (0), Inbox (1), Create (2), Explore (3), Profile (4)
    return [
      const _SellerListingsTab(),
      const ConversationsScreen(),
      const _CreatePropertyPlaceholder(),
      const _ExploreTab(),
      const ProfileScreen(),
    ];
  }
}

// Placeholder for the center + button
class _CreatePropertyPlaceholder extends StatelessWidget {
  const _CreatePropertyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// Seller listings tab
class _SellerListingsTab extends StatelessWidget {
  const _SellerListingsTab();

  @override
  Widget build(BuildContext context) {
    return const SellerListingsScreen();
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});
  @override
  Widget build(BuildContext context) =>
      Center(child: Text(label, style: Theme.of(context).textTheme.titleLarge));
}

// ── Explore Tab ───────────────────────────────────────────────────────────────
class _ExploreTab extends ConsumerStatefulWidget {
  const _ExploreTab();
  @override
  ConsumerState<_ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends ConsumerState<_ExploreTab> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
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
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref
          .read(propertyFilterProvider.notifier)
          .update((s) => s.copyWith(search: value.trim()));
    });
  }

  final _authService = AuthService();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    _userId = await _authService.getCurrentUserId();
    if (mounted) setState(() {});
  }

  void _onSearchSubmitted(String value) {
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
      final mapped = chip == 'Rent' ? ListingType.rent : ListingType.sell;
      return filter.listingType == mapped;
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
          // ── Header ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore',
                          style: tt.headlineSmall?.copyWith(
                            color: AppColors.accent,
                            letterSpacing: -0.5,
                            height: 1.1,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _NotifBtn(
                    onTap: () async {
                      if (_userId == null) {
                        await _loadUserId();
                      }
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

          // ── Search bar ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Focus(
                onFocusChange: (v) => setState(() => _searchFocused = v),
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
                          onChanged: _onSearchChanged,
                          onSubmitted: _onSearchSubmitted,
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

          // ── Filter chips ─────────────────────────────────
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

          // ── Featured / horizontal scroll ─────────────────
          if (!filter.isFiltering &&
              (filter.search == null || filter.search!.isEmpty))
            const _FeaturedSection(),

          // ── Section header ───────────────────────────────
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

          // ── Property list ─────────────────────────────────
          const _PropertyList(),

          // ── Bottom padding for nav bar ────────────────────
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

// ── Featured Section (horizontal scroll cards) ────────────────────────────────
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
                        color: const Color(0xFFF0E9E3),
                        child: const Icon(
                          Icons.home_outlined,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFF0E9E3),
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

// ── Property List ─────────────────────────────────────────────────────────────
class _PropertyList extends ConsumerWidget {
  const _PropertyList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final propertiesAsync = ref.watch(propertiesProvider);

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

// ── Filter Sheet ──────────────────────────────────────────────────────────────
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
    _fromDate = f.fromDate;
    _toDate = f.toDate;
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
    final initial = isFrom
        ? (_fromDate ?? now)
        : (_toDate ?? _fromDate ?? now);
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

    ref.read(propertyFilterProvider.notifier).update(
          (f) => PropertyFilter(
            search: f.search,
            listingType: _listingType,
            propertyType: _propertyType,
            city: _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
            minPrice: minText.isEmpty ? null : double.tryParse(minText),
            maxPrice: maxText.isEmpty ? null : double.tryParse(maxText),
            fromDate: _fromDate,
            toDate: _toDate,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      if (s == 'All') {
                        _listingType = null;
                      } else if (s == 'Rent') {
                        _listingType = ListingType.rent;
                      } else {
                        _listingType = ListingType.sell;
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 11),
                      decoration: BoxDecoration(
                        color:
                            sel ? AppColors.primary : AppColors.subtleBackground,
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
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          sel ? AppColors.primary : AppColors.subtleBackground,
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
                    style: tt.titleMedium
                        ?.copyWith(color: AppColors.textSecondary),
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
                    style: tt.titleMedium
                        ?.copyWith(color: AppColors.textSecondary),
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

// ── Filter text field ─────────────────────────────────────────────────────────
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

// ── Property Card ─────────────────────────────────────────────────────────────
class PropertyCard extends ConsumerWidget {
  final Property property;
  final VoidCallback onTap;
  const PropertyCard({super.key, required this.property, required this.onTap});

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
                        child: Text(
                          property.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleSmall?.copyWith(
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
                        child: Text(
                          property.location,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodySmall?.copyWith(
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
    color: const Color(0xFFF0E9E3),
    child: const Center(
      child: Icon(Icons.home_outlined, size: 48, color: AppColors.textTertiary),
    ),
  );
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

// ── Notification Button ───────────────────────────────────────────────────────
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
    if (mounted) setState(() => _unreadCount = data.length);
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

// ── Bottom Nav ────────────────────────────────────────────────────────────────
class _BottomNav extends ConsumerWidget {
  final bool isSeller;
  const _BottomNav({this.isSeller = false});

  static const _clientItems = [
    (icon: Icons.search_rounded,            outlinedIcon: Icons.search_rounded,             label: 'Explore'),
    (icon: Icons.slow_motion_video_rounded, outlinedIcon: Icons.slow_motion_video_rounded,  label: 'Tours'),
    (icon: Icons.chat_bubble_rounded,       outlinedIcon: Icons.chat_bubble_outline_rounded, label: 'Inbox'),
    (icon: Icons.favorite_rounded,          outlinedIcon: Icons.favorite_border_rounded,     label: 'Wishlists'),
    (icon: Icons.person_rounded,            outlinedIcon: Icons.person_outline_rounded,      label: 'Profile'),
  ];

  // CHANGED: Listings first, Explore moved to index 3
  static const _sellerItems = [
    (icon: Icons.home_rounded,        outlinedIcon: Icons.home_outlined,              label: 'Listings'),
    (icon: Icons.chat_bubble_rounded, outlinedIcon: Icons.chat_bubble_outline_rounded, label: 'Inbox'),
    (icon: Icons.add_rounded,         outlinedIcon: Icons.add_rounded,                label: 'Create'),
    (icon: Icons.search_rounded,      outlinedIcon: Icons.search_rounded,             label: 'Explore'),
    (icon: Icons.person_rounded,      outlinedIcon: Icons.person_outline_rounded,     label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(navIndexProvider);
    final items = isSeller ? _sellerItems : _clientItems;

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

                  if (isSeller && i == 2) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreatePropertyScreen(),
                            ),
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
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
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                active ? item.icon : item.outlinedIcon,
                                key: ValueKey(active),
                                size: 26,
                                color: active
                                    ? AppColors.primary
                                    : AppColors.accent.withAlpha(120),
                              ),
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