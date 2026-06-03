import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:homely/core/theme/app_colors.dart';
import 'package:homely/ui/widgets/skeletons.dart';
import 'package:homely/ui/providers/property_providers.dart';
import 'package:homely/ui/providers/profile_providers.dart';
import 'package:homely/ui/providers/auth_providers.dart';
import 'package:homely/domain/entities/profile/profile_entity.dart';
import 'package:homely/domain/entities/property/property_entity.dart';
import 'package:homely/ui/screens/visit_requests/my_visit_requests_screen.dart';
import 'package:homely/ui/screens/boost/my_boosts_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: profileAsync.when(
          loading: () => const SimpleListSkeleton(),
          error: (e, _) => _ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(profileNotifierProvider),
          ),
          data: (profile) => _ProfileContent(profile: profile),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROFILE CONTENT
// ═══════════════════════════════════════════════════════════════════════════════

class _ProfileContent extends ConsumerStatefulWidget {
  final ProfileEntity profile;
  const _ProfileContent({required this.profile});

  @override
  ConsumerState<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<_ProfileContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
      builder: (ctx) => _LogoutSheet(
        onConfirm: () {
          Navigator.pop(ctx);
          _logout();
        },
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _MoreOptionsSheet(
        profile: widget.profile,
        onNavigate: (route) {
          Navigator.pop(ctx);
          Navigator.push(context, MaterialPageRoute(builder: (_) => route));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(sellerListingsProvider);
    final listingCount = listingsAsync.maybeWhen(
      data: (l) => l.length,
      orElse: () => 0,
    );
    final listings = listingsAsync.maybeWhen(
      data: (l) => l,
      orElse: () => <PropertyEntity>[],
    );

    // Mock stats — replace with backend values when available
    const int soldCount = 24;
    const int visitsCount = 183;

    return NestedScrollView(
      physics: const BouncingScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: Column(
            children: [
              // ── Top Bar ─────────────────────────────────
              _TopBar(
                username: widget.profile.name,
                onMoreTap: _showMoreOptions,
                onLogoutTap: _showLogoutConfirmation,
              ),

              // ── Profile Header ───────────────────────────
              _ProfileHeader(
                profile: widget.profile,
                listingCount: listingCount,
                soldCount: soldCount,
                visitsCount: visitsCount,
                onEditProfile: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(profile: widget.profile),
                  ),
                ),
                onShareProfile: () => _shareProfile(context, widget.profile),
              ),

              const SizedBox(height: 4),
            ],
          ),
        ),

        // ── Tab Bar ─────────────────────────────────────
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyTabBarDelegate(
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.accent,
              indicatorWeight: 1.5,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(icon: Icon(Icons.grid_on_rounded, size: 22)),
                Tab(icon: Icon(Icons.play_circle_outline_rounded, size: 22)),
              ],
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Properties Tab ──────────────────────────────
          _PropertiesTab(listings: listings, listingsAsync: listingsAsync),

          // ── Reels Tab ───────────────────────────────────
          _ReelsTab(profile: widget.profile),
        ],
      ),
    );
  }

  void _shareProfile(BuildContext context, ProfileEntity profile) {
    // Integration layer — connect to backend endpoint when available
    final link = 'https://homely.app/seller/${profile.userId}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.link_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              'Profile link copied!',
              style: GoogleFonts.outfit(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
    Clipboard.setData(ClipboardData(text: link));
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TOP BAR
// ═══════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  final String username;
  final VoidCallback onMoreTap;
  final VoidCallback onLogoutTap;

  const _TopBar({
    required this.username,
    required this.onMoreTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Username / title
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

            // Logout icon
            _IconBtn(
              icon: Icons.logout_rounded,
              color: AppColors.error,
              onTap: onLogoutTap,
            ),
            const SizedBox(width: 4),

            // Three-dots menu
            _IconBtn(
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

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: color),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROFILE HEADER (Instagram-style)
// ═══════════════════════════════════════════════════════════════════════════════

class _ProfileHeader extends StatelessWidget {
  final ProfileEntity profile;
  final int listingCount;
  final int soldCount;
  final int visitsCount;
  final VoidCallback onEditProfile;
  final VoidCallback onShareProfile;

  const _ProfileHeader({
    required this.profile,
    required this.listingCount,
    required this.soldCount,
    required this.visitsCount,
    required this.onEditProfile,
    required this.onShareProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── Avatar + Stats Row ─────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              _LargeAvatar(profile: profile),

              const SizedBox(width: 24),

              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatColumn(value: '$listingCount', label: 'Listings'),
                    _StatDivider(),
                    _StatColumn(value: '$soldCount', label: 'Sold'),
                    _StatDivider(),
                    _StatColumn(value: '$visitsCount', label: 'Visits'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Name + Email ────────────────────────────────
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
                Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            profile.email.isNotEmpty ? profile.email : '—',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 8),

          // ── Seller Badge ────────────────────────────────
          _SellerBadge(verified: profile.verified),

          // ── Bio ─────────────────────────────────────────
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              profile.bio!,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 14),

          // ── Action Buttons Row (Instagram-style) ─────────
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Edit Profile',
                  onTap: onEditProfile,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: 'Share Profile',
                  onTap: onShareProfile,
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

// ── Large Avatar ──────────────────────────────────────────────────────────────

class _LargeAvatar extends ConsumerWidget {
  final ProfileEntity profile;
  const _LargeAvatar({required this.profile});

  String _initials() {
    final src = profile.name.trim().isNotEmpty ? profile.name : profile.email;
    final parts = src.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarPathAsync = ref.watch(localAvatarPathProvider(profile.userId));

    return GestureDetector(
      onTap: () => _pickImage(context, ref),
      child: Stack(
        children: [
          // Gradient ring
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: avatarPathAsync.when(
                  data: (path) {
                    if (path != null && path.isNotEmpty) {
                      return Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _fallback(),
                      );
                    }
                    return profile.avatarUrl != null &&
                            profile.avatarUrl!.isNotEmpty
                        ? Image.network(
                            profile.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _fallback(),
                          )
                        : _fallback();
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  error: (_, _) => _fallback(),
                ),
              ),
            ),
          ),

          // Camera badge
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final source = await _showImageSourcePicker(context);
    if (source == null) return;
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (pickedFile == null) return;
    await ref
        .read(localAvatarPathProvider(profile.userId).notifier)
        .setPath(profile.userId, pickedFile.path);
  }

  Future<ImageSource?> _showImageSourcePicker(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: Text('Gallery', style: GoogleFonts.outfit()),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primary,
              ),
              title: Text('Camera', style: GoogleFonts.outfit()),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _fallback() => Container(
    color: AppColors.primary.withValues(alpha: 0.1),
    child: Center(
      child: Text(
        _initials(),
        style: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    ),
  );
}

// ── Stat Column (Instagram-style) ─────────────────────────────────────────────

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        value,
        style: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.accent,
          letterSpacing: -0.5,
          height: 1.1,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 30, width: 1, color: AppColors.borderLight);
}

// ── Seller Badge ───────────────────────────────────────────────────────────────

class _SellerBadge extends StatelessWidget {
  final bool verified;
  const _SellerBadge({required this.verified});

  @override
  Widget build(BuildContext context) {
    final label = verified ? 'Verified Seller' : 'Seller';
    final color = verified ? const Color(0xFF00B894) : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified_rounded : Icons.storefront_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action Button (Instagram Edit/Share style) ────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight, width: 1.2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
          letterSpacing: -0.1,
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// STICKY TAB BAR DELEGATE
// ═══════════════════════════════════════════════════════════════════════════════

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Container(
    color: AppColors.background,
    child: Column(
      children: [
        Divider(height: 1, color: AppColors.borderLight),
        tabBar,
      ],
    ),
  );

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROPERTIES TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _PropertiesTab extends StatelessWidget {
  final List<PropertyEntity> listings;
  final AsyncValue listingsAsync;

  const _PropertiesTab({required this.listings, required this.listingsAsync});

  @override
  Widget build(BuildContext context) {
    return listingsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
      error: (e, _) => _EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load listings',
        subtitle: e.toString(),
      ),
      data: (_) {
        if (listings.isEmpty) {
          return _EmptyState(
            icon: Icons.home_outlined,
            title: 'No properties published yet',
            subtitle: 'Your listings will appear here',
            actionLabel: 'Add Property',
            onAction: () {},
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(1),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1.5,
            mainAxisSpacing: 1.5,
            childAspectRatio: 1.0,
          ),
          itemCount: listings.length,
          itemBuilder: (_, i) => _PropertyGridTile(property: listings[i]),
        );
      },
    );
  }
}

class _PropertyGridTile extends StatelessWidget {
  final PropertyEntity property;
  const _PropertyGridTile({required this.property});

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'ACTIVE':
        return const Color(0xFF00B894);
      case 'SOLD':
        return AppColors.error;
      case 'RENTED':
        return AppColors.primary;
      default:
        return AppColors.warning;
    }
  }

  String _fmt(double p) {
    if (p >= 1000000) return '\$${(p / 1000000).toStringAsFixed(1)}M';
    if (p >= 1000) return '\$${(p / 1000).toStringAsFixed(0)}K';
    return '\$${p.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      // Navigate to property details — connect to existing route
    },
    child: Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail
        property.images.isNotEmpty
            ? Image.network(
                property.images.first,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              )
            : _placeholder(),

        // Gradient overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.65),
                ],
              ),
            ),
          ),
        ),

        // Price
        Positioned(
          bottom: 6,
          left: 6,
          child: Text(
            _fmt(property.price),
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
        ),

        // Status badge
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor(
                property.status.toString(),
              ).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              property.status.label,
              style: GoogleFonts.outfit(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _placeholder() => Container(
    color: AppColors.subtleBackground,
    child: const Icon(
      Icons.home_outlined,
      size: 28,
      color: AppColors.textTertiary,
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// REELS TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _ReelsTab extends StatelessWidget {
  final ProfileEntity profile;
  const _ReelsTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    // Connect to backend video provider when available
    // For now: empty state with professional design
    return _EmptyState(
      icon: Icons.play_circle_outline_rounded,
      title: 'No video content available',
      subtitle: 'Property reels will appear here',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MORE OPTIONS SHEET
// ═══════════════════════════════════════════════════════════════════════════════

class _MoreOptionsSheet extends StatelessWidget {
  final ProfileEntity profile;
  final void Function(Widget route) onNavigate;

  const _MoreOptionsSheet({required this.profile, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SheetItem(
        icon: Icons.person_outline_rounded,
        label: 'Personal Info',
        onTap: () => onNavigate(_PersonalInfoScreen(profile: profile)),
      ),
      _SheetItem(
        icon: Icons.calendar_today_outlined,
        label: 'My Visits',
        onTap: () => onNavigate(const MyVisitRequestsScreen()),
      ),
      _SheetItem(
        icon: Icons.home_outlined,
        label: 'My Listings',
        onTap: () => onNavigate(const _MyListingsScreen()),
      ),
      _SheetItem(
        icon: Icons.rocket_launch_outlined,
        label: 'My Boosts',
        onTap: () => onNavigate(const MyBoostsScreen()),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          const SizedBox(height: 20),
          ...items.map((item) => _SheetTile(item: item)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SheetItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SheetItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _SheetTile extends StatelessWidget {
  final _SheetItem item;
  const _SheetTile({required this.item});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: item.onTap,
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
            child: Icon(item.icon, size: 19, color: AppColors.accentLight),
          ),
          const SizedBox(width: 14),
          Text(
            item.label,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    ),
  );
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// LOGOUT CONFIRMATION SHEET
// ═══════════════════════════════════════════════════════════════════════════════

class _LogoutSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  const _LogoutSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHandle(),
        const SizedBox(height: 20),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.logout_rounded, size: 26, color: AppColors.error),
        ),
        const SizedBox(height: 16),
        Text(
          'Log Out',
          style: GoogleFonts.outfit(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.borderLight, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.outfit(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Log Out',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
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
            child: Icon(icon, size: 32, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 13,
                ),
              ),
              child: Text(
                actionLabel!,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// PERSONAL INFO SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

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
        _InfoData(icon: Icons.notes_rounded, label: 'Bio', value: profile.bio!),
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
                        horizontal: 18,
                        vertical: 15,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    color:
                                        items[i].valueColor ?? AppColors.accent,
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

// ═══════════════════════════════════════════════════════════════════════════════
// MY LISTINGS SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

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
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (listings) {
          if (listings.isEmpty) {
            return _EmptyState(
              icon: Icons.home_outlined,
              title: 'No listings yet',
              subtitle: 'Your properties will appear here',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            itemCount: listings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _ListingCard(property: listings[i]),
          );
        },
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final PropertyEntity property;
  const _ListingCard({required this.property});

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'ACTIVE':
        return const Color(0xFF00B894);
      case 'SOLD':
        return AppColors.error;
      case 'RENTED':
        return AppColors.primary;
      default:
        return AppColors.warning;
    }
  }

  String _fmt(double p) {
    if (p >= 1000000) return '\$${(p / 1000000).toStringAsFixed(1)}M';
    if (p >= 1000) return '\$${(p / 1000).toStringAsFixed(0)}K';
    return '\$${p.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: property.images.isNotEmpty
                ? Image.network(
                    property.images.first,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _fmt(property.price),
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(
                property.status.toString(),
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              property.status.label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: _statusColor(property.status.toString()),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _placeholder() => Container(
    width: 58,
    height: 58,
    decoration: BoxDecoration(
      color: AppColors.subtleBackground,
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(
      Icons.home_outlined,
      size: 22,
      color: AppColors.textTertiary,
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// EDIT PROFILE SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class EditProfileScreen extends ConsumerStatefulWidget {
  final ProfileEntity profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _bio;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _phone = TextEditingController(text: widget.profile.phone ?? '');
    _bio = TextEditingController(text: widget.profile.bio ?? '');
    _address = TextEditingController(text: widget.profile.address ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _bio.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final request = ProfileUpdateRequest(
      name: _name.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
    );
    await ref.read(profileNotifierProvider.notifier).saveProfile(request);
    if (!mounted) return;
    if (ref.read(profileNotifierProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                'Failed to save.',
                style: GoogleFonts.outfit(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Profile updated',
                style: GoogleFonts.outfit(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF00B894),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(profileNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: AppColors.accent),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Avatar
              Center(
                child: GestureDetector(
                  onTap: () =>
                      _selectProfileImage(context, ref, widget.profile.userId),
                  child: Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(2.5),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.background,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: ClipOval(
                            child: ref
                                .watch(
                                  localAvatarPathProvider(
                                    widget.profile.userId,
                                  ),
                                )
                                .when(
                                  data: (path) {
                                    if (path != null && path.isNotEmpty) {
                                      return Image.file(
                                        File(path),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            _avatarFallback(),
                                      );
                                    }
                                    return widget.profile.avatarUrl != null &&
                                            widget.profile.avatarUrl!.isNotEmpty
                                        ? Image.network(
                                            widget.profile.avatarUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                _avatarFallback(),
                                          )
                                        : _avatarFallback();
                                  },
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  error: (_, _) => _avatarFallback(),
                                ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.background,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Center(
                child: Text(
                  widget.profile.name.isNotEmpty ? widget.profile.name : '—',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Center(
                child: Text(
                  widget.profile.email,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              _FormSection(
                title: 'Basic Info',
                children: [
                  _Field(
                    controller: _name,
                    label: 'Full name',
                    icon: Icons.person_outline_rounded,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _phone,
                    label: 'Phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _address,
                    label: 'Address',
                    icon: Icons.location_on_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _FormSection(
                title: 'About',
                children: [
                  _Field(
                    controller: _bio,
                    label: 'Bio',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    disabledBackgroundColor: AppColors.accent.withValues(
                      alpha: 0.4,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: -0.2,
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

  Future<void> _selectProfileImage(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _SheetHandle(),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: Text('Select from gallery', style: GoogleFonts.outfit()),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primary,
              ),
              title: Text('Take a picture', style: GoogleFonts.outfit()),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    if (source == null) return;
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (pickedFile == null) return;
    await ref
        .read(localAvatarPathProvider(userId).notifier)
        .setPath(userId, pickedFile.path);
  }

  Widget _avatarFallback() => Container(
    color: AppColors.primary.withValues(alpha: 0.08),
    child: const Icon(Icons.person, color: AppColors.primary, size: 38),
  );
}

// ── Form Section ──────────────────────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _FormSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 10),
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textTertiary,
            letterSpacing: 1.2,
          ),
        ),
      ),
      ...children,
    ],
  );
}

// ── Field ─────────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    validator: validator,
    style: GoogleFonts.outfit(
      fontSize: 14,
      color: AppColors.accent,
      fontWeight: FontWeight.w500,
    ),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Icon(icon, size: 18, color: AppColors.textTertiary),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0),
      labelStyle: GoogleFonts.outfit(
        color: AppColors.textTertiary,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: AppColors.cardBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.borderLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ERROR VIEW
// ═══════════════════════════════════════════════════════════════════════════════

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.subtleBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 28,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Could not load profile',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
