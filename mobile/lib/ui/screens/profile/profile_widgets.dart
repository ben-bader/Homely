// ─────────────────────────────────────────────────────────────────────────────
// profile_widgets.dart
// Shared UI primitives used by MyProfileScreen and UserProfileScreen.
// All classes here are intentionally public (no underscore prefix).
// profile_screen.dart keeps its own private copies unchanged.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:homely/core/theme/app_colors.dart';
import 'package:homely/ui/providers/profile_providers.dart';
import 'package:homely/domain/entities/profile/profile_entity.dart';
import 'package:homely/domain/entities/property/property_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProfileStatColumn
// ─────────────────────────────────────────────────────────────────────────────

class ProfileStatColumn extends StatelessWidget {
  final String value;
  final String label;
  const ProfileStatColumn({
    super.key,
    required this.value,
    required this.label,
  });

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

// ─────────────────────────────────────────────────────────────────────────────
// ProfileStatDivider
// ─────────────────────────────────────────────────────────────────────────────

class ProfileStatDivider extends StatelessWidget {
  const ProfileStatDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(height: 30, width: 1, color: AppColors.borderLight);
}

// ─────────────────────────────────────────────────────────────────────────────
// ProfileRoleBadge
// ─────────────────────────────────────────────────────────────────────────────

class ProfileRoleBadge extends StatelessWidget {
  final UserRole role;
  final bool verified;
  const ProfileRoleBadge({
    super.key,
    required this.role,
    required this.verified,
  });

  @override
  Widget build(BuildContext context) {
    final isSeller = role == UserRole.seller;
    final label =
        isSeller ? (verified ? 'Verified Seller' : 'Seller') : 'Client';
    final color = isSeller
        ? (verified ? const Color(0xFF00B894) : AppColors.primary)
        : AppColors.primary;
    final icon = isSeller
        ? (verified ? Icons.verified_rounded : Icons.storefront_rounded)
        : Icons.person_rounded;

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
          Icon(icon, size: 12, color: color),
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

// ─────────────────────────────────────────────────────────────────────────────
// ProfileActionButton
// ─────────────────────────────────────────────────────────────────────────────

class ProfileActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const ProfileActionButton({
    super.key,
    required this.label,
    required this.onTap,
  });

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

// ─────────────────────────────────────────────────────────────────────────────
// ProfileIconBtn
// ─────────────────────────────────────────────────────────────────────────────

class ProfileIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const ProfileIconBtn({
    super.key,
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

// ─────────────────────────────────────────────────────────────────────────────
// ProfileStickyTabBarDelegate
// ─────────────────────────────────────────────────────────────────────────────

class ProfileStickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const ProfileStickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      Container(
        color: AppColors.background,
        child: Column(
          children: [
            Divider(height: 1, color: AppColors.borderLight),
            tabBar,
          ],
        ),
      );

  @override
  bool shouldRebuild(ProfileStickyTabBarDelegate oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// ProfilePropertyGridTile
// ─────────────────────────────────────────────────────────────────────────────

class ProfilePropertyGridTile extends StatelessWidget {
  final PropertyEntity property;
  const ProfilePropertyGridTile({super.key, required this.property});

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
        onTap: () {},
        child: Stack(
          fit: StackFit.expand,
          children: [
            property.images.isNotEmpty
                ? Image.network(
                    property.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
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
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(property.status.toString())
                      .withValues(alpha: 0.9),
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

// ─────────────────────────────────────────────────────────────────────────────
// ProfileListingCard
// ─────────────────────────────────────────────────────────────────────────────

class ProfileListingCard extends StatelessWidget {
  final PropertyEntity property;
  const ProfileListingCard({super.key, required this.property});

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
                        errorBuilder: (_, __, ___) => _placeholder(),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(property.status.toString())
                      .withValues(alpha: 0.1),
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

// ─────────────────────────────────────────────────────────────────────────────
// ProfileEmptyState
// ─────────────────────────────────────────────────────────────────────────────

class ProfileEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ProfileEmptyState({
    super.key,
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
                child:
                    Icon(icon, size: 32, color: AppColors.textTertiary),
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
                        horizontal: 28, vertical: 13),
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

// ─────────────────────────────────────────────────────────────────────────────
// ProfileErrorView
// ─────────────────────────────────────────────────────────────────────────────

class ProfileErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ProfileErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 12),
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

// ─────────────────────────────────────────────────────────────────────────────
// ProfileSheetHandle
// ─────────────────────────────────────────────────────────────────────────────

class ProfileSheetHandle extends StatelessWidget {
  const ProfileSheetHandle({super.key});

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

// ─────────────────────────────────────────────────────────────────────────────
// ProfileLogoutSheet
// ─────────────────────────────────────────────────────────────────────────────

class ProfileLogoutSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  const ProfileLogoutSheet({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ProfileSheetHandle(),
            const SizedBox(height: 20),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                size: 26,
                color: AppColors.error,
              ),
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
                      side: const BorderSide(
                          color: AppColors.borderLight, width: 1.5),
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

// ─────────────────────────────────────────────────────────────────────────────
// ProfileLargeAvatar  (own profile — with camera overlay and ImagePicker)
// ─────────────────────────────────────────────────────────────────────────────

class ProfileLargeAvatar extends ConsumerWidget {
  final ProfileEntity profile;
  const ProfileLargeAvatar({super.key, required this.profile});

  String _initials() {
    final src =
        profile.name.trim().isNotEmpty ? profile.name : profile.email;
    final parts = src.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarPathAsync =
        ref.watch(localAvatarPathProvider(profile.userId));

    return GestureDetector(
      onTap: () => _pickImage(context, ref),
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
                child: avatarPathAsync.when(
                  data: (path) {
                    if (path != null && path.isNotEmpty) {
                      return Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallback(),
                      );
                    }
                    return profile.avatarUrl != null &&
                            profile.avatarUrl!.isNotEmpty
                        ? Image.network(
                            profile.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _fallback(),
                          )
                        : _fallback();
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  error: (_, __) => _fallback(),
                ),
              ),
            ),
          ),
          // Camera overlay badge
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border:
                    Border.all(color: AppColors.background, width: 2),
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
            const ProfileSheetHandle(),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: Text('Gallery', style: GoogleFonts.outfit()),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(
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

// ─────────────────────────────────────────────────────────────────────────────
// ProfileStatsRow  (shared stats row used in both screens)
// ─────────────────────────────────────────────────────────────────────────────

class ProfileStatsRow extends StatelessWidget {
  final ProfileStats stats;
  final UserRole role;
  const ProfileStatsRow({
    super.key,
    required this.stats,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    // Seller  → Listings | Visits | Tours
    // Client  → Favorites | Visits | Tours
    final columns = role == UserRole.seller
        ? <Widget>[
            ProfileStatColumn(
                value: '${stats.listingCount ?? 0}', label: 'Listings'),
            const ProfileStatDivider(),
            ProfileStatColumn(
                value: '${stats.totalVisitRequests ?? 0}', label: 'Visits'),
            const ProfileStatDivider(),
            ProfileStatColumn(
                value: '${stats.toursCount ?? 0}', label: 'Tours'),
          ]
        : <Widget>[
            ProfileStatColumn(
                value: '${stats.favoritesCount ?? 0}', label: 'Favorites'),
            const ProfileStatDivider(),
            ProfileStatColumn(
                value: '${stats.propertyVisitsCount ?? 0}', label: 'Visits'),
            const ProfileStatDivider(),
            ProfileStatColumn(
                value: '${stats.scheduledToursCount ?? 0}', label: 'Tours'),
          ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: columns,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ProfileStatsRowSkeleton
// ─────────────────────────────────────────────────────────────────────────────

class ProfileStatsRowSkeleton extends StatelessWidget {
  const ProfileStatsRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (i) {
        if (i.isOdd) return const ProfileStatDivider();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 44,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );
      }),
    );
  }
}
