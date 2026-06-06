import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homely/core/theme/app_colors.dart';
import 'package:homely/ui/widgets/skeletons.dart';
import 'package:homely/ui/providers/profile_providers.dart';
import 'package:homely/ui/providers/auth_providers.dart' as auth_providers;
import 'package:homely/ui/providers/chat_providers.dart';
import 'package:homely/domain/entities/profile/profile_entity.dart';
import 'package:homely/domain/entities/property/property_entity.dart';
import 'package:homely/ui/screens/chat/chat_screen.dart';
import 'package:homely/ui/widgets/reports/report_sheet.dart';
import 'package:homely/ui/screens/profile/profile_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UserProfileScreen
// Route  : /profile/:userId
// Purpose: Shown when viewing ANY OTHER user's profile.
//          Never used for the authenticated user's own profile.
// ─────────────────────────────────────────────────────────────────────────────

class UserProfileScreen extends ConsumerWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileByIdProvider(userId));

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
            onRetry: () => ref.invalidate(profileByIdProvider(userId)),
          ),
          data: (profile) =>
              _UserProfileContent(profile: profile, userId: userId),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _UserProfileContent
// ─────────────────────────────────────────────────────────────────────────────

class _UserProfileContent extends ConsumerStatefulWidget {
  final ProfileEntity profile;
  final String userId;

  const _UserProfileContent({
    required this.profile,
    required this.userId,
  });

  @override
  ConsumerState<_UserProfileContent> createState() =>
      _UserProfileContentState();
}

class _UserProfileContentState extends ConsumerState<_UserProfileContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  UserRole get _role => normalizeRole(widget.profile.role);

  @override
  void initState() {
    super.initState();
    // Seller: 2 tabs (Posts + Reels). Client: 1 tab (Saved).
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

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) =>
          _UserMoreOptionsSheet(profile: widget.profile, role: _role),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Uses profileStatsByUserIdProvider — NOT profileStatsProvider —
    // so we never leak the authenticated user's own stats.
    final statsAsync =
        ref.watch(profileStatsByUserIdProvider(widget.userId));
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
          child: _UserTopBar(
            username: widget.profile.name.trim().isNotEmpty
                ? widget.profile.name
                : 'Profile',
            onMoreTap: _showMoreOptions,
          ),
        ),
        SliverToBoxAdapter(
          child: _UserProfileHeader(
            profile: widget.profile,
            role: _role,
            statsAsync: statsAsync,
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: ProfileStickyTabBarDelegate(tabBar),
        ),
      ],
      body: Padding(
        padding: EdgeInsets.only(bottom: navBarHeight),
        child: TabBarView(
          controller: _tabController,
          children: _role == UserRole.seller
              ? [
                  _UserSellerPropertiesTab(userId: widget.userId),
                  const _UserReelsTab(),
                ]
              : [const _UserClientFavoritesTab()],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP BAR — other user (back arrow + username + more-options, NO logout)
// ─────────────────────────────────────────────────────────────────────────────

class _UserTopBar extends StatelessWidget {
  final String username;
  final VoidCallback onMoreTap;

  const _UserTopBar({required this.username, required this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            ProfileIconBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              color: AppColors.accent,
              onTap: () => Navigator.maybePop(context),
            ),
            const SizedBox(width: 8),
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
// PROFILE HEADER — other user (display-only avatar + Message button)
// ─────────────────────────────────────────────────────────────────────────────

class _UserProfileHeader extends ConsumerWidget {
  final ProfileEntity profile;
  final UserRole role;
  final AsyncValue<ProfileStats> statsAsync;

  const _UserProfileHeader({
    required this.profile,
    required this.role,
    required this.statsAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── Avatar (display-only) + Stats ──────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _DisplayAvatar(profile: profile),
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

          // ── Name + Verified ────────────────────────────────────────────────
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
          ProfileRoleBadge(role: role, verified: profile.verified),

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

          // ── Action: Message ONLY — no Edit, no logout ──────────────────────
          Row(
            children: [
              Expanded(
                child: ProfileActionButton(
                  label: 'Message',
                  onTap: () => _onMessageTap(context, ref),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _onMessageTap(BuildContext context, WidgetRef ref) async {
    final auth =
        await ref.read(auth_providers.currentSessionProvider.future);
    final currentUserId = auth?.userId ?? '';
    final targetUserId = profile.userId;

    if (currentUserId.isEmpty || targetUserId.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to start conversation')),
        );
      }
      return;
    }

    final convId =
        await findOrCreateConversation(ref, currentUserId, targetUserId);

    if (convId == null || convId.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open chat')),
        );
      }
      return;
    }

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: convId,
          currentUserId: currentUserId,
          chatTitle: profile.name,
          chatSubtitle: profile.email,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DISPLAY AVATAR — read-only, no camera overlay, no tap handler
// ─────────────────────────────────────────────────────────────────────────────

class _DisplayAvatar extends StatelessWidget {
  final ProfileEntity profile;
  const _DisplayAvatar({required this.profile});

  String _initials() {
    final src =
        profile.name.trim().isNotEmpty ? profile.name : profile.email;
    final parts = src.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.background,
        ),
        padding: const EdgeInsets.all(2),
        child: ClipOval(
          child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
              ? Image.network(
                  profile.avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback(),
                )
              : _fallback(),
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

// ─────────────────────────────────────────────────────────────────────────────
// MORE OPTIONS SHEET — other user (Report User only for both roles)
// ─────────────────────────────────────────────────────────────────────────────

class _UserMoreOptionsSheet extends StatelessWidget {
  final ProfileEntity profile;
  final UserRole role;

  const _UserMoreOptionsSheet({required this.profile, required this.role});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ProfileSheetHandle(),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              Navigator.pop(context);
              ReportSheet.show(
                context,
                targetType: ReportTargetType.user,
                targetId: profile.userId,
                targetTitle:
                    profile.name.isNotEmpty ? profile.name : 'User',
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.flag_outlined,
                      size: 19,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Report User',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
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
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SELLER — Properties Tab
// Uses sellerListingsByUserIdProvider — NEVER sellerListingsProvider
// ─────────────────────────────────────────────────────────────────────────────

class _UserSellerPropertiesTab extends ConsumerWidget {
  final String userId;
  const _UserSellerPropertiesTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync =
        ref.watch(sellerListingsByUserIdProvider(userId));
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
            subtitle: 'This seller has no published properties.',
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
          itemBuilder: (_, i) =>
              ProfilePropertyGridTile(property: listings[i]),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT — Favorites Tab (public placeholder — no private data exposed)
// ─────────────────────────────────────────────────────────────────────────────

class _UserClientFavoritesTab extends StatelessWidget {
  const _UserClientFavoritesTab();

  @override
  Widget build(BuildContext context) => const ProfileEmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'No public favorites',
        subtitle: "This user's favorites are not public.",
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SELLER — Reels Tab (placeholder until feature is ready)
// ─────────────────────────────────────────────────────────────────────────────

class _UserReelsTab extends StatelessWidget {
  const _UserReelsTab();

  @override
  Widget build(BuildContext context) => const ProfileEmptyState(
        icon: Icons.play_circle_outline_rounded,
        title: 'No video content available',
        subtitle: 'Property reels will appear here',
      );
}
