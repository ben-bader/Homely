import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homely/core/theme/app_colors.dart';
import '../../../ui/screens/chat/chat_screen.dart';
import '../../../ui/providers/chat_providers.dart';
import 'package:homely/domain/entities/media/property_media_entity.dart';
import '../../../ui/providers/media_providers.dart';
import 'package:homely/domain/entities/property/property_entity.dart';
import '../../../ui/providers/favorite_providers.dart';
import '../../../ui/providers/property_providers.dart';
import '../../../ui/screens/property/property_detail_screen.dart';
import '../../../ui/widgets/tours/tours_widgets.dart';
import 'package:video_player/video_player.dart';

// ── Provider ───────────────────────────────────────────────────────────────────

final allVideosProvider = FutureProvider<List<PropertyMediaEntity>>((ref) async {
  final properties = await ref.watch(propertiesProvider.future);
  final mediaRepo = ref.watch(mediaRepositoryProvider);
  final allVideos = <PropertyMediaEntity>[];

  for (final property in properties) {
    try {
      final media = await mediaRepo.getByPropertyId(property.id);
      allVideos.addAll(media.where((m) => m.isVideo));
    } catch (e) {
      debugPrint('[Tours] Media load error for ${property.id}: $e');
    }
  }

  allVideos.sort((a, b) => b.displayOrder.compareTo(a.displayOrder));
  return allVideos;
});

// ═══════════════════════════════════════════════════════════════════════════════
// TOURS SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class ToursScreen extends ConsumerStatefulWidget {
  const ToursScreen({super.key});

  @override
  ConsumerState<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends ConsumerState<ToursScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allVideosAsync = ref.watch(allVideosProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: allVideosAsync.when(
        loading: () => const ReelLoadingScreen(),
        error: (e, _) => const ReelErrorScreen(),
        data: (videos) {
          if (videos.isEmpty) return const ReelEmptyScreen();

          return Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: videos.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) =>
                    _ReelItem(video: videos[i], isActive: i == _currentPage),
              ),
              // Top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Tours',
                          style: GoogleFonts.outfit(
                            color: AppColors.background,
                            letterSpacing: -0.5,
                            height: 1.1,
                            fontSize: 30,

                            shadows: const [
                              Shadow(color: Colors.black54, blurRadius: 8),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_currentPage + 1} / ${videos.length}',
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// REEL ITEM
// ═══════════════════════════════════════════════════════════════════════════════

class _ReelItem extends ConsumerStatefulWidget {
  final PropertyMediaEntity video;
  final bool isActive;
  const _ReelItem({required this.video, required this.isActive});

  @override
  ConsumerState<_ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends ConsumerState<_ReelItem>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  VideoPlayerController? _ctrl;
  bool _initialized = false;
  bool _hasError = false;
  bool _showControls = false;
  bool _isMuted = false;
  bool _saved = false;

  Timer? _hideTimer;
  late AnimationController _heartAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _heartAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.isActive) _initVideo();
  }

  @override
  void didUpdateWidget(_ReelItem old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _initialized ? _ctrl?.play() : _initVideo();
    } else if (!widget.isActive && old.isActive) {
      _ctrl?.pause();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isActive) return;
    if (state == AppLifecycleState.paused) _ctrl?.pause();
    if (state == AppLifecycleState.resumed && _initialized) _ctrl?.play();
  }

  Future<void> _initVideo() async {
    if (_hasError || _initialized) return;
    try {
      final url = widget.video.url;
      if (url.isEmpty) throw Exception('Empty URL');

      _ctrl = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await _ctrl!.initialize().timeout(const Duration(seconds: 30));
      _ctrl!.setLooping(true);
      _ctrl!.addListener(_onTick);
      _ctrl!.play();

      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      debugPrint('[Tours] Error: $e');
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _onTick() {
    if (!mounted) return;
    setState(() {});
  }

  void _tapScreen() {
    _hideTimer?.cancel();
    if (_showControls) {
      setState(() => _showControls = false);
    } else {
      _togglePlayPause();
      setState(() => _showControls = true);
      _hideTimer = Timer(
        const Duration(seconds: 3),
        () => setState(() => _showControls = false),
      );
    }
  }

  void _togglePlayPause() {
    if (!_initialized) return;
    setState(() {
      _ctrl!.value.isPlaying ? _ctrl!.pause() : _ctrl!.play();
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _ctrl?.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _doubleTap() async {
    try {
      final isFavorited = await ref.read(
        isPropertyFavoritedProvider(widget.video.propertyId).future,
      );
      if (!isFavorited) {
        await ref
            .read(favoritesProvider.notifier)
            .addFavorite(widget.video.propertyId);
        _heartAnim.forward(from: 0);
      }
    } catch (error) {
      debugPrint('Error toggling favorite: $error');
    }
  }

  Future<void> _openChat(PropertyEntity property) async {
    try {
      final repo = ref.read(chatRepositoryProvider);
      final conv = await repo.createConversation(property.id);
      if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open chat: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _heartAnim.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _ctrl?.removeListener(_onTick);
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync = ref.watch(
      propertyDetailProvider(widget.video.propertyId),
    );

    return GestureDetector(
      onTap: _tapScreen,
      onDoubleTap: _doubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildVideoLayer(),
          const ReelGradients(),

          // Play/pause overlay
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: ReelPlayPauseOverlay(
              isPlaying: _initialized && _ctrl!.value.isPlaying,
              onTap: _togglePlayPause,
            ),
          ),

          // Double-tap heart
          ReelHeartAnimation(animation: _heartAnim),

          // Bottom overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomOverlay(propertyAsync),
          ),

          // Side actions
          Positioned(
            right: 10,
            bottom: 150,
            child: _buildSideActions(propertyAsync),
          ),

          // Progress bar at bottom (Instagram Reels style)
          if (_initialized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ReelProgressBar(controller: _ctrl!),
            ),

          // Mute button (when controls visible)
          if (_showControls)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 16,
              child: ReelCircleBtn(
                icon: _isMuted
                    ? Icons.volume_off_rounded
                    : Icons.volume_up_rounded,
                onTap: _toggleMute,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoLayer() {
    if (_hasError) {
      return Container(
        color: const Color(0xFF0A0A0A),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam_off_outlined,
                color: Colors.white24,
                size: 52,
              ),
              const SizedBox(height: 12),
              Text(
                'Video unavailable',
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _hasError = false;
                    _initialized = false;
                  });
                  _initVideo();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (!_initialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white24,
          ),
        ),
      );
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _ctrl!.value.size.width,
        height: _ctrl!.value.size.height,
        child: VideoPlayer(_ctrl!),
      ),
    );
  }

  Widget _buildSideActions(AsyncValue<PropertyEntity> propertyAsync) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      propertyAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (property) => Consumer(
          builder: (context, ref, child) {
            final isFavoritedAsync = ref.watch(
              isPropertyFavoritedProvider(property.id),
            );
            return ReelSideBtn(
              icon: Icons.favorite_border_rounded,
              activeIcon: Icons.favorite_rounded,
              label: 'Like',
              active: isFavoritedAsync.maybeWhen(
                data: (isFavorited) => isFavorited,
                orElse: () => false,
              ),
              activeColor: Colors.red,
              onTap: () async {
                try {
                  final isFavorited = await ref.read(
                    isPropertyFavoritedProvider(property.id).future,
                  );
                  if (isFavorited) {
                    await ref
                        .read(favoritesProvider.notifier)
                        .removeFavorite(property.id);
                  } else {
                    await ref
                        .read(favoritesProvider.notifier)
                        .addFavorite(property.id);
                  }
                } catch (error) {
                  debugPrint('Error toggling favorite: $error');
                }
              },
            );
          },
        ),
      ),
      const SizedBox(height: 22),
      // ✅ Chat — opens conversation with seller
      ReelSideBtn(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Chat',
        onTap: () => propertyAsync.whenData(_openChat),
      ),
      const SizedBox(height: 22),
      ReelSideBtn(
        icon: Icons.bookmark_border_rounded,
        activeIcon: Icons.bookmark_rounded,
        label: 'Save',
        active: _saved,
        activeColor: AppColors.primary,
        onTap: () => setState(() => _saved = !_saved),
      ),
      const SizedBox(height: 22),
      ReelSideBtn(icon: Icons.share_rounded, label: 'Share', onTap: () {}),
    ],
  );

  Widget _buildBottomOverlay(AsyncValue<PropertyEntity> propertyAsync) => Padding(
    padding: EdgeInsets.fromLTRB(
      16,
      0,
      80,
      MediaQuery.of(context).padding.bottom + 16,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        propertyAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (property) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ReelBadge(
                    text: property.propertyType.toJson(),
                    color: AppColors.primary.withOpacity(0.85),
                  ),
                  const SizedBox(width: 6),
                  ReelBadge(
                    text: property.listingType.toJson(),
                    color: Colors.white.withOpacity(0.15),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PropertyDetailScreen(propertyId: property.id),
                  ),
                ),
                child: Text(
                  property.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_fmtPrice(property.price)} ${property.currency}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white60,
                    size: 13,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      property.location,
                      style: GoogleFonts.outfit(
                        color: Colors.white60,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  String _fmtPrice(double p) {
    if (p >= 1000000) return '${(p / 1000000).toStringAsFixed(1)}M';
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(0)}K';
    return p.toStringAsFixed(0);
  }
}
