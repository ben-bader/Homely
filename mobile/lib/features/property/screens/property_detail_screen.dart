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
import 'package:mobile/features/visit_requests/screens/request_visit_sheet.dart';
import 'package:mobile/features/feedback/widgets/feedback_list.dart';
import 'package:mobile/features/feedback/widgets/submit_feedback_sheet.dart';
import 'package:mobile/features/reports/widgets/report_sheet.dart';
import 'package:mobile/features/boost/widgets/boost_sheet.dart';

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
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
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
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final authService = AuthService();
    final userId = await authService.getCurrentUserId();
    final role = await authService.getUserRoleFromStorage();
    if (mounted)
      setState(() {
        _currentUserId = userId;
        _userRole = role;
      });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  bool get _isOwner => _currentUserId == widget.property.sellerId;
  bool get _isClient => _userRole == 'CLIENT';

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final p = widget.property;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar sits ON TOP of the image, scrolls away with it ──
          SliverAppBar(
            pinned: false,
            floating: false,
            snap: false,
            // expandedHeight = image height so the flexible space IS the image
            expandedHeight: h * 0.42,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            // Back + title + flag float over the image
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _CircleBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Property Detail',
                      textAlign: TextAlign.center,
                      style: tt.titleLarge?.copyWith(
                        color: AppColors.accent,
                        letterSpacing: -0.5,
                        height: 1.1,
                        fontSize: 25,
                  
                      ),
                    ),
                  ),
                  if (!_isOwner)
                    _CircleBtn(
                      icon: Icons.flag_outlined,
                      iconColor: AppColors.error,
                      onTap: () => ReportSheet.show(
                        context,
                        targetType: ReportTargetType.property,
                        targetId: p.id,
                        targetTitle: p.title,
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),
            ),
            // The image fills the flexible space
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
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
                              height: double.infinity,
                              errorBuilder: (_, __, ___) =>
                                  _imgPlaceholder(),
                            ),
                          ),
                          if (p.images.length > 1)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                    : _imgPlaceholder(),
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Property title + price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.title,
                            style: tt.headlineSmall?.copyWith(
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: p.listingType.toJson() == 'RENT'
                                  ? const Color(0xFFE8F4FD)
                                  : const Color(0xFFE8F8EE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              p.listingType.toJson(),
                              style: tt.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: p.listingType.toJson() == 'RENT'
                                    ? const Color(0xFF1976D2)
                                    : const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${p.currency} ${_fmt(p.price)}',
                      style: tt.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        p.location,
                        style: tt.bodySmall?.copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Spec chips
                Row(
                  children: List.generate(
                    p.chips.length,
                    (i) => [
                      Expanded(
                        child: _SpecBox(
                          icon: p.chips[i].icon,
                          label: p.chips[i].label,
                        ),
                      ),
                      if (i < p.chips.length - 1)
                        const SizedBox(width: 10),
                    ],
                  ).expand((e) => e).toList(),
                ),

                // Description
                if (p.description.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text('Description', style: tt.titleSmall),
                  const SizedBox(height: 10),
                  Text(
                    p.description,
                    style: tt.bodyMedium?.copyWith(height: 1.6),
                  ),
                ],

                const SizedBox(height: 32),

                // Listing agent — NO padding/margin on the card
                Text('Listing Agent', style: tt.titleSmall),
                const SizedBox(height: 12),
                Container(
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
                            ? const Icon(
                                Icons.person,
                                color: AppColors.textSecondary,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.sellerName,
                              style: tt.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            if (p.sellerAgency != null &&
                                p.sellerAgency!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                p.sellerAgency!,
                                style: tt.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (_currentUserId != p.sellerId)
                        _ContactBtn(property: p)
                      else
                        Text(
                          'Your Property',
                          style: tt.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),

                // Boost (owner only)
                if (_isOwner) ...[
                  const SizedBox(height: 20),
                  _OutlineActionBtn(
                    icon: Icons.rocket_launch_rounded,
                    label: 'Boost this Property',
                    color: const Color(0xFFFF9800),
                    onTap: () => BoostSheet.show(
                      context,
                      propertyId: p.id,
                      propertyTitle: p.title,
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                FeedbackList(
                  propertyId: p.id,
                  currentUserId: _currentUserId,
                ),

                const SizedBox(height: 32),

                // Location map placeholder
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
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 32,
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24),
                            child: Text(
                              p.location,
                              textAlign: TextAlign.center,
                              style: tt.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),

      bottomNavigationBar: _isClient
          ? Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => RequestVisitSheet.show(
                  context,
                  propertyId: p.id,
                  propertyTitle: p.title,
                ),
                icon: const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  'Request a Visit',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _imgPlaceholder() => Container(
    color: AppColors.borderMedium,
    child: const Center(
      child: Icon(
        Icons.home_outlined,
        size: 64,
        color: AppColors.textTertiary,
      ),
    ),
  );

  String _fmt(double p) {
    if (p >= 1000000) return '${(p / 1000000).toStringAsFixed(2)}M';
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(0)}K';
    return p.toStringAsFixed(0);
  }
}

class _OutlineActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OutlineActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Chat with Seller',
          style: tt.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

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
          Text(
            label,
            textAlign: TextAlign.center,
            style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
    
      child: Icon(icon, size: 24, color: iconColor),
    ),
  );
}