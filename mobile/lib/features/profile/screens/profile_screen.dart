import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/profile/models/profile.dart';
import 'package:mobile/features/profile/repositories/profile_repository.dart';
import 'package:mobile/features/property/models/property.dart';
import 'package:mobile/features/seller/providers/seller_providers.dart';
import 'package:mobile/features/visit_requests/screens/my_visit_requests_screen.dart';
import 'package:mobile/features/boost/screens/my_boosts_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary),
        ),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(profileNotifierProvider),
        ),
        data: (profile) => _ProfileContent(profile: profile),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROFILE CONTENT
// ═══════════════════════════════════════════════════════════════════════════════

class _ProfileContent extends ConsumerWidget {
  final Profile profile;
  const _ProfileContent({required this.profile});

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService().logout();
    } catch (_) {}
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(sellerListingsProvider);
    final isSeller = listingsAsync.maybeWhen(
      data: (l) => l.isNotEmpty,
      orElse: () => false,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar — title only ───────────────────────
            Text(
              'Profile',
              style: GoogleFonts.outfit(
                color: AppColors.accent,
                letterSpacing: -0.5,
                height: 1.1,
                fontSize: 30,
              ),
            ),

            const SizedBox(height: 32),

            // ── Avatar + identity ──────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.subtleBackground,
                      border: Border.all(
                          color: AppColors.borderLight, width: 2),
                    ),
                    child: profile.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              profile.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _defaultAvatar(),
                            ),
                          )
                        : _defaultAvatar(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        profile.name.isNotEmpty ? profile.name : '—',
                        style: GoogleFonts.outfit(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (profile.verified) ...[
                        const SizedBox(width: 5),
                        const Icon(Icons.verified_rounded,
                            size: 16, color: AppColors.primary),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    profile.email.isNotEmpty ? profile.email : '—',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Edit Profile button ────────────────────────
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(profile: profile),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Edit Profile',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
            Divider(color: AppColors.borderLight, height: 1),
            const SizedBox(height: 28),

            // ── Main menu group ────────────────────────────
            _MenuGroup(
              children: [
                _MenuItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Personal Info',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          _PersonalInfoScreen(profile: profile),
                    ),
                  ),
                ),
                _MenuItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'My Visits',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MyVisitRequestsScreen()),
                  ),
                ),
                if (isSeller)
                  _MenuItem(
                    icon: Icons.rocket_launch_outlined,
                    label: 'My Boosts',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyBoostsScreen()),
                    ),
                  ),
                _MenuItem(
                  icon: Icons.home_outlined,
                  label: 'My Listings',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const _MyListingsScreen()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            Divider(color: AppColors.borderLight, height: 1),
            const SizedBox(height: 28),

            // ── Logout group ───────────────────────────────
            _MenuGroup(
              children: [
                _MenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Log out',
                  onTap: () => _confirmLogout(context),
                  isDestructive: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() => const Icon(Icons.person,
      color: AppColors.textTertiary, size: 36);

  void _confirmLogout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Log Out',
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to log out?',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppColors.borderLight, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.outfit(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _logout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text('Log Out',
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _MenuGroup extends StatelessWidget {
  final List<Widget> children;
  const _MenuGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.accent;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PERSONAL INFO SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class _PersonalInfoScreen extends StatelessWidget {
  final Profile profile;
  const _PersonalInfoScreen({required this.profile});

  @override
  Widget build(BuildContext context) {
    final items = <_InfoData>[
      _InfoData(label: 'Full Name',
          value: profile.name.isNotEmpty ? profile.name : '—'),
      _InfoData(label: 'Email',
          value: profile.email.isNotEmpty ? profile.email : '—'),
      _InfoData(label: 'Phone', value: profile.phone ?? '—'),
      _InfoData(label: 'Address', value: profile.address ?? '—'),
      _InfoData(
        label: 'Verification',
        value: profile.verified ? 'Verified' : 'Not verified',
        valueColor:
            profile.verified ? Colors.green : AppColors.textSecondary,
      ),
      if (profile.bio != null && profile.bio!.isNotEmpty)
        _InfoData(label: 'Bio', value: profile.bio!),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: AppColors.accent),
        title: Text('Personal Info',
            style: GoogleFonts.outfit(
                fontSize: 30, color: AppColors.accent)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(items.length, (i) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            items[i].label,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            items[i].value,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              color: items[i].valueColor ??
                                  AppColors.accent,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < items.length - 1)
                      Divider(
                        height: 1,
                        indent: 18,
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

// Plain data class — not a Widget
class _InfoData {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoData({
    required this.label,
    required this.value,
    this.valueColor,
  });
}// ═══════════════════════════════════════════════════════════════════════════════
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
        title: Text('My Listings',
            style: GoogleFonts.outfit(
                fontSize: 17, color: AppColors.accent)),
      ),
      body: listingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (listings) {
          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.home_outlined,
                      size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  Text('No listings yet',
                      style: GoogleFonts.outfit(
                          color: AppColors.textSecondary,
                          fontSize: 14)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: listings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) =>
                _ListingCard(property: listings[i]),
          );
        },
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Property property;
  const _ListingCard({required this.property});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: property.images.isNotEmpty
                  ? Image.network(
                      property.images.first,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '\$${_fmt(property.price)}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor(property.status.toString())
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                property.status.label,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: _statusColor(property.status.toString()),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _placeholder() => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.subtleBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.home_outlined,
            size: 20, color: AppColors.textTertiary),
      );

  String _fmt(double p) {
    if (p >= 1000000) return '${(p / 1000000).toStringAsFixed(1)}M';
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(0)}K';
    return p.toStringAsFixed(0);
  }

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'ACTIVE': return Colors.green;
      case 'SOLD': return Colors.red;
      case 'RENTED': return Colors.blue;
      default: return Colors.orange;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EDIT PROFILE SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class EditProfileScreen extends ConsumerStatefulWidget {
  final Profile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
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
    _address =
        TextEditingController(text: widget.profile.address ?? '');
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
      address: _address.text.trim().isEmpty
          ? null
          : _address.text.trim(),
    );
    await ref
        .read(profileNotifierProvider.notifier)
        .saveProfile(request);
    if (!mounted) return;
    if (ref.read(profileNotifierProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save.',
            style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile updated',
            style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ));
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
        titleSpacing: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.accent),
        title: Text('Edit Profile',
            style: GoogleFonts.outfit(
                fontSize: 17, color: AppColors.accent)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Avatar
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.subtleBackground,
                      border: Border.all(
                          color: AppColors.borderLight, width: 2),
                    ),
                    child: widget.profile.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              widget.profile.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.person,
                                      color: AppColors.textTertiary,
                                      size: 36),
                            ),
                          )
                        : const Icon(Icons.person,
                            color: AppColors.textTertiary, size: 36),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.background, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_outlined,
                          size: 13, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                widget.profile.name.isNotEmpty
                    ? widget.profile.name
                    : '—',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.profile.email,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 28),
              Divider(color: AppColors.borderLight, height: 1),
              const SizedBox(height: 20),

              _Field(
                controller: _name,
                label: 'Full name',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _phone,
                label: 'Phone number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _Field(controller: _address, label: 'Address'),
              const SizedBox(height: 12),
              _Field(
                  controller: _bio, label: 'Bio', maxLines: 3),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    disabledBackgroundColor:
                        AppColors.accent.withOpacity(0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Save',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
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
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
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
            fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: AppColors.cardBackground,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColors.accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.error),
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
              const Icon(Icons.wifi_off_rounded,
                  size: 40, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: Text('Retry',
                    style: GoogleFonts.outfit(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      );
}