import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/chat/providers/chat_providers.dart';
import 'package:mobile/features/chat/repositories/chat_repository.dart';
import 'package:mobile/features/chat/screens/chat_screen.dart';
import 'package:mobile/features/media/models/property_media.dart';
import 'package:mobile/features/property/models/property.dart';
import 'package:mobile/features/property/providers/property_providers.dart';
import 'package:mobile/features/tours/widgets/tours_widgets.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final PropertyMedia video;
  final String propertyId;

  const VideoPlayerScreen({
    super.key,
    required this.video,
    required this.propertyId,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _ctrl;
  bool _initialized = false;
  bool _hasError = false;
  bool _showControls = false;
  bool _isMuted = false;
  bool _liked = false;
  bool _saved = false;

  Timer? _hideTimer;
  late AnimationController _heartAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _heartAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final url = widget.video.url;
      if (url.isEmpty) throw Exception('Empty URL');

      _ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
      await _ctrl!.initialize();
      _ctrl!.setLooping(true);
      _ctrl!.addListener(_onTick);
      _ctrl!.play();

      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      debugPrint('[VideoPlayer] Error: $e');
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
      _hideTimer = Timer(const Duration(seconds: 3),
          () => setState(() => _showControls = false));
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

  void _doubleTap() {
    if (!_liked) {
      setState(() => _liked = true);
      _heartAnim.forward(from: 0);
    }
  }

  Future<void> _openChat(Property property) async {
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _heartAnim.dispose();
    _ctrl?.removeListener(_onTick);
    _ctrl?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync =
        ref.watch(propertyDetailProvider(widget.propertyId));

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: GestureDetector(
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

            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      ReelCircleBtn(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      ReelCircleBtn(
                        icon: _isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        onTap: _toggleMute,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Side actions
            Positioned(
              right: 12,
              bottom: 150,
              child: _buildSideActions(propertyAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoLayer() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_outlined,
                color: Colors.white38, size: 56),
            const SizedBox(height: 12),
            Text('Video unavailable',
                style: GoogleFonts.outfit(
                    color: Colors.white38, fontSize: 15)),
          ],
        ),
      );
    }
    if (!_initialized) {
      return const Center(
        child:
            CircularProgressIndicator(strokeWidth: 2, color: Colors.white30),
      );
    }
    return Center(
      child: AspectRatio(
        aspectRatio: _ctrl!.value.aspectRatio,
        child: VideoPlayer(_ctrl!),
      ),
    );
  }

  Widget _buildSideActions(AsyncValue<Property> propertyAsync) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReelSideBtn(
            icon: Icons.favorite_border_rounded,
            activeIcon: Icons.favorite_rounded,
            label: 'Like',
            active: _liked,
            activeColor: Colors.red,
            onTap: () => setState(() => _liked = !_liked),
          ),
          const SizedBox(height: 20),
          // ✅ Chat — opens conversation with seller
          ReelSideBtn(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            onTap: () => propertyAsync.whenData(_openChat),
          ),
          const SizedBox(height: 20),
          ReelSideBtn(
            icon: Icons.bookmark_border_rounded,
            activeIcon: Icons.bookmark_rounded,
            label: 'Save',
            active: _saved,
            activeColor: AppColors.primary,
            onTap: () => setState(() => _saved = !_saved),
          ),
          const SizedBox(height: 20),
          ReelSideBtn(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: () {},
          ),
        ],
      );

  Widget _buildBottomOverlay(AsyncValue<Property> propertyAsync) => Padding(
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
                  Text(
                    property.title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      shadows: [
                        Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 8)
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: Colors.white70, size: 13),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          property.location,
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${property.currency} ${_fmtPrice(property.price)}',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_initialized) ReelProgressBar(controller: _ctrl!),
          ],
        ),
      );

  String _fmtPrice(double p) {
    if (p >= 1000000) return '${(p / 1000000).toStringAsFixed(1)}M';
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(0)}K';
    return p.toStringAsFixed(0);
  }
}