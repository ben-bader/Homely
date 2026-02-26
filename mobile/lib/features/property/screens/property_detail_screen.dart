import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/property/models/property.dart';
import 'package:mobile/features/property/providers/property_providers.dart';
import 'package:mobile/features/chat/repositories/chat_repository.dart';
import 'package:mobile/features/chat/screens/chat_screen.dart';
import 'package:mobile/features/chat/providers/chat_providers.dart';
import 'package:mobile/features/property/repositories/property_repository.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
class PropertyDetailScreen extends ConsumerWidget {
  final String propertyId;
  const PropertyDetailScreen({super.key, required this.propertyId});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(propertyDetailProvider(propertyId));
    return async.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
        body: Center(child: Text('$e')),
      ),
      data: (p) => _Body(property: p),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  final Property property;
  const _Body({required this.property});
  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  int _imgIdx = 0;
  final _pageCtrl = PageController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final authService = AuthService();
    final userId = await authService.getCurrentUserId();
    if (mounted) setState(() => _currentUserId = userId);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final p = widget.property;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero image ─────────────────────────────
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  child: SizedBox(
                    height: h * 0.42,
                    width: double.infinity,
                    child: p.images.isNotEmpty
                        ? Stack(
                            children: [
                              PageView.builder(
                                controller: _pageCtrl,
                                itemCount: p.images.length,
                                onPageChanged: (i) =>
                                    setState(() => _imgIdx = i),
                                itemBuilder: (_, i) => Image.network(
                                  p.images[i],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) =>
                                      _imgPlaceholder(h),
                                ),
                              ),
                              if (p.images.length > 1)
                                Positioned(
                                  bottom: 16,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: List.generate(
                                      p.images.length,
                                      (i) => AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 250),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 3),
                                        width: _imgIdx == i ? 20 : 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: _imgIdx == i
                                              ? Colors.white
                                              : Colors.white54,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : _imgPlaceholder(h),
                  ),
                ),

                // ── Content ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title + badge + price ─────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // headlineSmall: w700, 24px — property name
                                Text(p.title,
                                    style: tt.headlineSmall?.copyWith(
                                        letterSpacing: -0.5)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: p.listingType.toUpperCase() ==
                                            'RENT'
                                        ? const Color(0xFFE8F4FD)
                                        : const Color(0xFFE8F8EE),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    p.listingType.toUpperCase(),
                                    // labelSmall: w400 — but override to w700 for badge
                                    style: tt.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      color: p.listingType
                                                  .toUpperCase() ==
                                              'RENT'
                                          ? const Color(0xFF1976D2)
                                          : const Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Price — titleMedium: w700 with accent color
                          Text('${p.currency} ${_fmt(p.price)}',
                              style: tt.titleMedium?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accent,
                                  letterSpacing: -0.5)),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ── Location ──────────────────────────
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 15,
                              color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            // bodySmall: w400, 12px — location text
                            child: Text(p.location,
                                style: tt.bodySmall?.copyWith(
                                    fontSize: 13)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Specs grid ────────────────────────
                      Row(
                        children: List.generate(
                          p.chips.length,
                          (i) => [
                            Expanded(
                                child: _SpecBox(
                                    icon: p.chips[i].icon,
                                    label: p.chips[i].label)),
                            if (i < p.chips.length - 1)
                              const SizedBox(width: 10),
                          ],
                        ).expand((e) => e).toList(),
                      ),

                      // ── Description ───────────────────────
                      if (p.description.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        // titleSmall: w600, 16px — section label
                        Text('Description', style: tt.titleSmall),
                        const SizedBox(height: 10),
                        // bodyMedium: w400, 14px — description body
                        Text(p.description,
                            style: tt.bodyMedium?.copyWith(height: 1.6)),
                      ],

                      const SizedBox(height: 32),

                      // ── Listing Agent ─────────────────────
                      // titleSmall: w600, 16px — section label
                      Text('Listing Agent', style: tt.titleSmall),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                         
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.borderLight,
                              backgroundImage: p.sellerAvatar != null
                                  ? NetworkImage(p.sellerAvatar!)
                                  : null,
                              child: p.sellerAvatar == null
                                  ? const Icon(Icons.person,
                                      color: AppColors.textSecondary)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // labelLarge: w500 — agent name, override to w700
                                  Text(
                                   p.sellerName,
                                    style: tt.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary),
                                  ),
                                  if (p.sellerAgency.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    // bodySmall: w400, 12px — agency name
                                    Text(p.sellerAgency,
                                        style: tt.bodySmall),
                                  ],
                                ],
                              ),
                            ),
                            if (_currentUserId != p.sellerId)
                              _ContactBtn(property: p)
                            else
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.subtleBackground,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('Your Property',
                                    style: tt.labelSmall?.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Location Address ──────────────────
                      // titleSmall: w600, 16px — section label
                      Text('Location Address', style: tt.titleSmall),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 160,
                          color: AppColors.borderLight,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.red, size: 32),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  // labelLarge: w500 — map location label
                                  child: Text(p.location,
                                      textAlign: TextAlign.center,
                                      style: tt.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Top bar overlay ────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  // titleLarge: w600, 22px — "Property Detail"
                  Text('Property Detail',
                      style: tt.titleLarge?.copyWith(color: AppColors.accent,
                            letterSpacing: -0.5,
                            height: 1.1,
                            fontSize: 25,)),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder(double h) => Container(
        height: h * 0.42,
        color: AppColors.borderMedium,
        child: const Icon(Icons.home_outlined,
            size: 64, color: AppColors.textTertiary),
      );

  String _fmt(double p) {
    if (p >= 1000000) return '${(p / 1000000).toStringAsFixed(2)}M';
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(0)}K';
    return p.toStringAsFixed(0);
  }
}

// ── Chat with Seller ──────────────────────────────────────────────────────────
class _ContactBtn extends ConsumerWidget {
  final Property property;
  const _ContactBtn({required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () async {
        try {
          final repo = ref.read(chatRepositoryProvider);
          final conv = await repo.createConversation(property.id);
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                conversationId: conv.id,
                currentUserId: conv.clientId,
                chatTitle: property.sellerName,
                chatSubtitle: property.title,
              ),
            ),
          );
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
        }
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        // labelSmall: w400 — override to w700 for button text
        child: Text('Chat with Seller',
            style: tt.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12)),
      ),
    );
  }
}

// ── Spec box ──────────────────────────────────────────────────────────────────
class _SpecBox extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SpecBox({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.accent),
          const SizedBox(height: 8),
          // labelSmall: w400, 11px — spec label (e.g. "3 Beds")
          Text(label,
              textAlign: TextAlign.center,
              style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Circle back button ────────────────────────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  const _CircleBtn(
      {required this.icon,
      required this.onTap,
      this.iconColor = AppColors.accent});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
          
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 22, color: iconColor),
        ),
      );
}