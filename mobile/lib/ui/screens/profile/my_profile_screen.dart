import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homely/core/theme/app_colors.dart';
import 'package:homely/ui/widgets/skeletons.dart';
import 'package:homely/ui/providers/property_providers.dart';
import 'package:homely/ui/providers/profile_providers.dart';
import 'package:homely/ui/providers/auth_providers.dart';
import 'package:homely/domain/entities/profile/profile_entity.dart';
import 'package:homely/ui/screens/visit_requests/my_visit_requests_screen.dart';
import 'package:homely/ui/screens/boost/my_boosts_screen.dart';
import 'package:homely/ui/screens/property/property_detail_screen.dart';
import 'package:homely/ui/screens/profile/profile_screen.dart'
    show
        profileStatsProvider,
        clientFavoritesProvider,
        EditProfileScreen;
import 'package:homely/ui/screens/profile/profile_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MyProfileScreen
// Route  : /my-profile  (bottom nav tab + startup redirect)
// Purpose: ONLY shown to the authenticated user for their own profile.
// ─────────────────────────────────────────────────────────────────────────────

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: profileAsync.when(
          loading: () => const SimpleListSkeleton(),
          error: (e, _) => ProfileErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(profileNotifierProvider),
          ),
          data: (profile) => _MyProfileContent(profile: profile),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MyProfileContent
// ─────────────────────────────────────────────────────────────────────────────

class _MyProfileContent extends ConsumerStatefulWidget {
  final ProfileEntity profile;
  const _MyProfileContent({required this.profile});

  @override
  ConsumerState<_MyProfileContent> createState() => _MyProfileContentState();
}

class _MyProfileContentState extends ConsumerState<_MyProfileContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  UserRole get _role => normalizeRole(widget.profile.role);

  @override
  void initState() {
    super.initState();
    // Step-1 debug log — shows the exact role string from the backend.
    // Remove once the correct role is confirmed in production.
    debugPrint('>>> RAW profile.role = "${widget.profile.role}"');
    _tabController = TabController(
      length: _role == UserRole.seller ? 2 : 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> _logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _showLogoutConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => ProfileLogoutSheet(
        onConfirm: () {
          Navigator.pop(ctx);
          _logout();
        },
      ),
    );
  }

  // ── More options ────────────────────────────────────────────────────────────

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _MyMoreOptionsSheet(
        profile: widget.profile,
        role: _role,
        onNavigate: (route) {
          Navigator.pop(ctx);
          Navigator.push(context, MaterialPageRoute(builder: (_) => route));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(profileStatsProvider(_role));
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navBarHeight = kBottomNavigationBarHeight + bottomPadding;

    final tabBar = TabBar(
      controller: _tabController,
      indicatorColor: AppColors.accent,
      indicatorWeight: 1.5,
      labelColor: AppColors.accent,
      unselectedLabelColor: AppColors.textSecondary,
      // Seller: Posts | Reels  — Client: Saved
      tabs: _role == UserRole.seller
          ? const [
              Tab(icon: Icon(Icons.grid_on_rounded, size: 22), text: 'Posts'),
              Tab(
                  icon: Icon(Icons.play_circle_outline_rounded, size: 22),
                  text: 'Reels'),
            ]
          : const [
              Tab(
                  icon: Icon(Icons.favorite_border_rounded, size: 22),
                  text: 'Saved'),
            ],
    );

    return NestedScrollView(
      physics: const BouncingScrollPhysics(),
      headerSliverBuilder: (context, _) => [
        SliverToBoxAdapter(
          child: _MyTopBar(
            username: widget.profile.name.trim().isNotEmpty
                ? widget.profile.name
                : 'Profile',
            onLogoutTap: _showLogoutConfirmation,
            onMoreTap: _showMoreOptions,
          ),
        ),
        SliverToBoxAdapter(
          child: _MyProfileHeader(
            profile: widget.profile,
            role: _role,
            statsAsync: statsAsync,
            onEditProfile: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EditProfileScreen(profile: widget.profile),
              ),
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: ProfileStickyTabBarDelegate(tabBar),
        ),
      ],
      body: TabBarView(
          controller: _tabController,
          children: _role == UserRole.seller
              ? [
                  _MySellerPropertiesTab(bottomInset: navBarHeight),
                  _MyReelsTab(bottomInset: navBarHeight),
                ]
              : [
                  _MyClientFavoritesTab(bottomInset: navBarHeight),
                ],
        ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP BAR — own profile (username + logout icon + more-options icon)
// ─────────────────────────────────────────────────────────────────────────────

class _MyTopBar extends StatelessWidget {
  final String username;
  final VoidCallback onLogoutTap;
  final VoidCallback onMoreTap;

  const _MyTopBar({
    required this.username,
    required this.onLogoutTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                username.isNotEmpty ? username : 'Profile',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ProfileIconBtn(
              icon: Icons.logout_rounded,
              color: AppColors.error,
              onTap: onLogoutTap,
            ),
            const SizedBox(width: 4),
            ProfileIconBtn(
              icon: Icons.more_horiz_rounded,
              color: AppColors.accent,
              onTap: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE HEADER — own (ProfileLargeAvatar with camera + Edit Profile button)
// ─────────────────────────────────────────────────────────────────────────────

class _MyProfileHeader extends StatelessWidget {
  final ProfileEntity profile;
  final UserRole role;
  final AsyncValue<ProfileStats> statsAsync;
  final VoidCallback onEditProfile;

  const _MyProfileHeader({
    required this.profile,
    required this.role,
    required this.statsAsync,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── Avatar + Stats ─────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfileLargeAvatar(profile: profile),
              const SizedBox(width: 24),
              Expanded(
                child: statsAsync.when(
                  loading: () => const ProfileStatsRowSkeleton(),
                  error: (_, __) => ProfileStatsRow(
                      stats: ProfileStats.empty(), role: role),
                  data: (stats) =>
                      ProfileStatsRow(stats: stats, role: role),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Name + Bio ────────────────────────────────────────────────────
          Row(
            children: [
              Text(
                profile.name.isNotEmpty ? profile.name : '—',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  letterSpacing: -0.3,
                ),
              ),
              if (profile.verified) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              profile.bio!,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          ProfileRoleBadge(role: role, verified: profile.verified),

          const SizedBox(height: 14),

          // ── Action: Edit Profile ONLY — no Message, no Share ───────────────
          Row(
            children: [
              Expanded(
                child: ProfileActionButton(
                  label: 'Edit Profile',
                  onTap: onEditProfile,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MORE OPTIONS SHEET — own profile
// Personal Info / My Visits / My Listings (seller) / My Boosts (seller)
// ─────────────────────────────────────────────────────────────────────────────

class _MyMoreOptionsSheet extends StatelessWidget {
  final ProfileEntity profile;
  final UserRole role;
  final void Function(Widget route) onNavigate;

  const _MyMoreOptionsSheet({
    required this.profile,
    required this.role,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ProfileSheetHandle(),
          const SizedBox(height: 20),
          _tile(
            icon: Icons.person_outline_rounded,
            label: 'Personal Info',
            onTap: () => onNavigate(_PersonalInfoScreen(profile: profile)),
          ),
          if (role == UserRole.client)
            _tile(
              icon: Icons.calendar_today_outlined,
              label: 'My Visits',
              onTap: () => onNavigate(const MyVisitRequestsScreen()),
            ),
          if (role == UserRole.seller) ...[
            _tile(
              icon: Icons.door_front_door_outlined,
              label: 'Visit Requests',
              onTap: () => onNavigate(const MyVisitRequestsScreen()),
            ),
            _tile(
              icon: Icons.home_outlined,
              label: 'My Listings',
              onTap: () => onNavigate(const _MyListingsScreen()),
            ),
            _tile(
              icon: Icons.rocket_launch_outlined,
              label: 'My Boosts',
              onTap: () => onNavigate(const MyBoostsScreen()),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.subtleBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 19, color: AppColors.accentLight),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SELLER — Properties Tab (own listings via sellerListingsProvider)
// ─────────────────────────────────────────────────────────────────────────────

class _MySellerPropertiesTab extends ConsumerWidget {
  final double bottomInset;
  const _MySellerPropertiesTab({required this.bottomInset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(sellerListingsProvider);
    return listingsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
            strokeWidth: 2, color: AppColors.primary),
      ),
      error: (e, _) => ProfileEmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load listings',
        subtitle: e.toString(),
      ),
      data: (listings) {
        if (listings.isEmpty) {
          return const ProfileEmptyState(
            icon: Icons.home_outlined,
            title: 'No properties yet',
            subtitle: 'Start selling by publishing your first property.',
          );
        }
        return GridView.builder(
          padding: EdgeInsets.only(
              left: 1, right: 1, top: 1, bottom: bottomInset + 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1.5,
            mainAxisSpacing: 1.5,
            childAspectRatio: 1.0,
          ),
          itemCount: listings.length,
          itemBuilder: (_, i) => ProfilePropertyGridTile(
            property: listings[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PropertyDetailScreen(propertyId: listings[i].id),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SELLER — Reels Tab (own — placeholder until feature is ready)
// ─────────────────────────────────────────────────────────────────────────────

class _MyReelsTab extends StatelessWidget {
  final double bottomInset;
  const _MyReelsTab({required this.bottomInset});

  @override
  Widget build(BuildContext context) => const ProfileEmptyState(
        icon: Icons.play_circle_outline_rounded,
        title: 'No video content yet',
        subtitle: 'Property reels will appear here',
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT — Favorites Tab (own)
// ─────────────────────────────────────────────────────────────────────────────

class _MyClientFavoritesTab extends ConsumerWidget {
  final double bottomInset;
  const _MyClientFavoritesTab({required this.bottomInset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(clientFavoritesProvider);
    return favoritesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
            strokeWidth: 2, color: AppColors.primary),
      ),
      error: (e, _) => ProfileEmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load favorites',
        subtitle: e.toString(),
      ),
      data: (listings) {
        if (listings.isEmpty) {
          return const ProfileEmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'No favorite properties yet',
            subtitle: 'Properties you save will appear here.',
          );
        }
        return GridView.builder(
          padding: EdgeInsets.only(
              left: 1, right: 1, top: 1, bottom: bottomInset + 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1.5,
            mainAxisSpacing: 1.5,
            childAspectRatio: 1.0,
          ),
          itemCount: listings.length,
          itemBuilder: (_, i) => ProfilePropertyGridTile(
            property: listings[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PropertyDetailScreen(propertyId: listings[i].id),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PERSONAL INFO SCREEN (inline — owner only, accessed from more-options)
// ─────────────────────────────────────────────────────────────────────────────

class _PersonalInfoScreen extends StatelessWidget {
  final ProfileEntity profile;
  const _PersonalInfoScreen({required this.profile});

  @override
  Widget build(BuildContext context) {
    final items = <_InfoData>[
      _InfoData(
        icon: Icons.person_outline_rounded,
        label: 'Full Name',
        value: profile.name.isNotEmpty ? profile.name : '—',
      ),
      _InfoData(
        icon: Icons.email_outlined,
        label: 'Email',
        value: profile.email.isNotEmpty ? profile.email : '—',
      ),
      _InfoData(
        icon: Icons.phone_outlined,
        label: 'Phone',
        value: profile.phone ?? '—',
      ),
      _InfoData(
        icon: Icons.location_on_outlined,
        label: 'Address',
        value: profile.address ?? '—',
      ),
      _InfoData(
        icon: Icons.verified_outlined,
        label: 'Verification',
        value: profile.verified ? 'Verified' : 'Not verified',
        valueColor: profile.verified
            ? const Color(0xFF00B894)
            : AppColors.textSecondary,
      ),
      if (profile.bio != null && profile.bio!.isNotEmpty)
        _InfoData(
            icon: Icons.notes_rounded, label: 'Bio', value: profile.bio!),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: AppColors.accent),
        title: Text(
          'Personal Info',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: List.generate(items.length, (i) {
                final isLast = i == items.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(
                              items[i].icon,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  items[i].label,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: AppColors.textTertiary,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  items[i].value,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: items[i].valueColor ??
                                        AppColors.accent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 66,
                        endIndent: 18,
                        color: AppColors.borderLight,
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoData {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoData({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// MY LISTINGS SCREEN (seller-only, from more-options)
// ─────────────────────────────────────────────────────────────────────────────

class _MyListingsScreen extends ConsumerWidget {
  const _MyListingsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(sellerListingsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: AppColors.accent),
        title: Text(
          'My Listings',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: listingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (listings) {
          if (listings.isEmpty) {
            return const ProfileEmptyState(
              icon: Icons.home_outlined,
              title: 'No listings yet',
              subtitle: 'Your properties will appear here',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            itemCount: listings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) =>
                ProfileListingCard(property: listings[i]),
          );
        },
      ),
    );
  }
}
