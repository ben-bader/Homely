import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:homely/ui/providers/profile_providers.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'package:homely/domain/entities/property/property_entity.dart';
import '../../../ui/providers/property_providers.dart'
    hide CreatePropertyScreen;
import '../../../ui/providers/auth_providers.dart';
import '../../../ui/screens/chat/chat_screen.dart';
import '../../../ui/providers/chat_providers.dart';
import '../../../ui/widgets/visit_requests/request_visit_sheet.dart';
import '../../../ui/widgets/feedback/feedback_list.dart';
import '../../../ui/widgets/reports/report_sheet.dart';
import '../../../ui/widgets/boost/boost_sheet.dart';
import 'package:homely/domain/entities/media/property_media_entity.dart';
import '../../../ui/providers/media_providers.dart';
import '../../../ui/screens/tours/video_player_screen.dart';

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

// ═══════════════════════════════════════════════════════════════════════════════
// BODY
// ═══════════════════════════════════════════════════════════════════════════════

class _Body extends ConsumerStatefulWidget {
  final PropertyEntity property;
  const _Body({required this.property});

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  int _imgIdx = 0;
  final _pageCtrl = PageController();

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

    final mediaAsync = ref.watch(propertyMediaProvider(p.id));
    final currentUserIdAsync = ref.watch(currentUserIdProvider);
    final userRoleAsync = ref.watch(userRoleProvider);

    final isOwner = currentUserIdAsync.maybeWhen(
      data: (id) => id == p.sellerId,
      orElse: () => false,
    );

    final isClient = userRoleAsync.maybeWhen(
      data: (role) => role == 'CLIENT',
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero app bar ─────────────────────────────────────────────────
          SliverAppBar(
            pinned: false,
            floating: false,
            snap: false,
            expandedHeight: h * 0.42,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
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
                        color: AppColors.background,
                        letterSpacing: -0.5,
                        height: 1.1,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  if (!isOwner)
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
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                child: mediaAsync.when(
                  loading: () => _buildHeroCarousel(p.images),
                  error: (_, _) => _buildHeroCarousel(p.images),
                  data: (media) {
                    final imageUrls =
                        media
                            .where((m) => m.mediaType == MediaType.IMAGE)
                            .toList()
                          ..sort(
                            (a, b) => a.displayOrder.compareTo(b.displayOrder),
                          );
                    final urls = imageUrls.isNotEmpty
                        ? imageUrls.map((m) => m.url).toList()
                        : p.images;
                    return _buildHeroCarousel(urls);
                  },
                ),
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Title + price
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
                      '${_fmt(p.price)} ${p.currency}',
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
                if (p.chips.isNotEmpty) ...[
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
                        if (i < p.chips.length - 1) const SizedBox(width: 10),
                      ],
                    ).expand((e) => e).toList(),
                  ),
                  const SizedBox(height: 32),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _propertyIcon(p.propertyType.toJson()),
                          size: 15,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          p.propertyType.toJson()[0] +
                              p.propertyType
                                  .toJson()
                                  .substring(1)
                                  .toLowerCase(),
                          style: GoogleFonts.outfit(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Description
                if (p.description.isNotEmpty) ...[
                  Text('Description', style: tt.titleSmall),
                  const SizedBox(height: 10),
                  Text(
                    p.description,
                    style: tt.bodyMedium?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 32),
                ],

                // Listing agent
                Text('Listing Agent', style: tt.titleSmall),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
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
                              Text(p.sellerAgency!, style: tt.bodySmall),
                            ],
                          ],
                        ),
                      ),
                      if (!isOwner)
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
                if (isOwner) ...[
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
                  currentUserId: currentUserIdAsync.maybeWhen(
                    data: (id) => id,
                    orElse: () => null,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Location map ─────────────────────────────────────────
                Text('Location', style: tt.titleSmall),
                const SizedBox(height: 12),
                _PropertyMap(
                  latitude: p.latitude,
                  longitude: p.longitude,
                  address: p.location,
                ),

                // Media section
                mediaAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (media) {
                    if (media.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        Text('Media', style: tt.titleSmall),
                        const SizedBox(height: 12),
                        _MediaSection(media: media, propertyId: p.id),
                      ],
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),

      bottomNavigationBar: isClient
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

  // ── Hero carousel ─────────────────────────────────────────────────────────

  Widget _buildHeroCarousel(List<String> images) {
    if (images.isEmpty) return _imgPlaceholder();
    return Stack(
      children: [
        PageView.builder(
          controller: _pageCtrl,
          itemCount: images.length,
          onPageChanged: (i) => setState(() => _imgIdx = i),
          itemBuilder: (_, i) => Image.network(
            images[i],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                color: AppColors.borderMedium,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
            errorBuilder: (_, _, _) => _imgPlaceholder(),
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _imgIdx == i ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _imgIdx == i ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  IconData _propertyIcon(String type) {
    switch (type) {
      case 'HOUSE':
        return Icons.house_outlined;
      case 'APARTMENT':
        return Icons.apartment_outlined;
      case 'VILLA':
        return Icons.villa_outlined;
      case 'STUDIO':
        return Icons.chair_outlined;
      case 'COMMERCIAL':
        return Icons.business_outlined;
      case 'LAND':
        return Icons.landscape_outlined;
      default:
        return Icons.home_outlined;
    }
  }

  Widget _imgPlaceholder() => Container(
    color: AppColors.borderMedium,
    child: const Center(
      child: Icon(Icons.home_outlined, size: 64, color: AppColors.textTertiary),
    ),
  );

  String _fmt(double p) {
    if (p >= 1000000) return '${(p / 1000000).toStringAsFixed(2)}M';
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(0)}K';
    return p.toStringAsFixed(0);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROPERTY MAP WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

class _PropertyMap extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String address;

  const _PropertyMap({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  bool get _hasCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude != 0.0 &&
      longitude != 0.0;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    // ── No coordinates fallback ──────────────────────────────────────────
    if (!_hasCoordinates) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.subtleBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 28,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  address,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final point = LatLng(latitude!, longitude!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Interactive map ──────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 220,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags:
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.drag |
                      InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                // OpenStreetMap tiles — no API key required
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.homely.mobile',
                  maxZoom: 19,
                ),
                // PropertyEntity pin
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 48,
                      height: 56,
                      child: Column(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.home_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          // Pin tail
                          CustomPaint(
                            size: const Size(12, 8),
                            painter: _PinTailPainter(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // OSM attribution (required by OSM license)
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Address pill below map ───────────────────────────────────────
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Pin tail painter ──────────────────────────────────────────────────────────

class _PinTailPainter extends CustomPainter {
  final Color color;
  const _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = ui.Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// MEDIA SECTION — tabbed images / videos
// ═══════════════════════════════════════════════════════════════════════════════

class _MediaSection extends StatefulWidget {
  final List<PropertyMediaEntity> media;
  final String propertyId;
  const _MediaSection({required this.media, required this.propertyId});

  @override
  State<_MediaSection> createState() => _MediaSectionState();
}

class _MediaSectionState extends State<_MediaSection>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.media
        .where((m) => m.mediaType == MediaType.IMAGE)
        .toList();
    final videos = widget.media
        .where((m) => m.mediaType == MediaType.VIDEO)
        .toList();

    return Column(
      children: [
        TabBar(
          controller: _tab,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.image_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text('Photos (${images.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.video_library_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text('Reels (${videos.length})'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tab,
            children: [
              _MediaGrid(
                media: images,
                propertyId: widget.propertyId,
                isVideo: false,
              ),
              _MediaGrid(
                media: videos,
                propertyId: widget.propertyId,
                isVideo: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Media grid ────────────────────────────────────────────────────────────────

class _MediaGrid extends StatelessWidget {
  final List<PropertyMediaEntity> media;
  final String propertyId;
  final bool isVideo;
  const _MediaGrid({
    required this.media,
    required this.propertyId,
    required this.isVideo,
  });

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isVideo ? Icons.video_library_outlined : Icons.image_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              isVideo ? 'No videos yet' : 'No photos yet',
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: media.length,
      itemBuilder: (_, i) => isVideo
          ? _VideoGridItem(media: media[i], propertyId: propertyId)
          : _ImageGridItem(media: media[i], isCover: i == 0),
    );
  }
}

// ── Image grid item ───────────────────────────────────────────────────────────

class _ImageGridItem extends StatelessWidget {
  final PropertyMediaEntity media;
  final bool isCover;
  const _ImageGridItem({required this.media, this.isCover = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _FullscreenImage(url: media.url)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              media.url,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: AppColors.subtleBackground,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
              errorBuilder: (_, _, _) => Container(
                color: AppColors.subtleBackground,
                child: const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textTertiary,
                    size: 32,
                  ),
                ),
              ),
            ),
            if (isCover)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 11,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Cover',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Video grid item ───────────────────────────────────────────────────────────

class _VideoGridItem extends StatelessWidget {
  final PropertyMediaEntity media;
  final String propertyId;
  const _VideoGridItem({required this.media, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(videoUrl: media.url),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.black87,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (media.thumbnailUrl != null && media.thumbnailUrl!.isNotEmpty)
                Image.network(
                  media.thumbnailUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white54, width: 1.5),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Fullscreen image ──────────────────────────────────────────────────────────

class _FullscreenImage extends StatelessWidget {
  final String url;
  const _FullscreenImage({required this.url});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Icon(
            Icons.broken_image_outlined,
            color: Colors.white54,
            size: 64,
          ),
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

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
  final PropertyEntity property;
  const _ContactBtn({required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () async {
        try {
          final repo = ref.read(chatRepositoryProvider);
          final conv = await repo.createConversation(property.id);
          final currentUserId =
              ref.read(profileNotifierProvider).valueOrNull?.userId ??
                  conv.participantOneId;
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                conversationId: conv.id,
                currentUserId: currentUserId,
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
    this.iconColor = AppColors.background,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: 40,
      height: 40,
      child: Icon(icon, size: 24, color: iconColor),
    ),
  );
}
