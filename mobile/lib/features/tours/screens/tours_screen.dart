import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/media/models/property_media.dart';
import 'package:mobile/features/media/repositories/media_repository.dart';
import 'package:mobile/features/property/providers/property_providers.dart';
import 'package:mobile/features/property/repositories/property_repository.dart';
import 'package:video_player/video_player.dart';

// Provider to get all videos from all properties
final allVideosProvider = FutureProvider<List<PropertyMedia>>((ref) async {
  final properties = await ref.watch(propertiesProvider.future);
  final mediaRepo = ref.watch(mediaRepositoryProvider);

  final allVideos = <PropertyMedia>[];

  for (var property in properties) {
    try {
      final media = await mediaRepo.getByPropertyId(property.id);
      allVideos.addAll(media.where((m) => m.isVideo));
    } catch (e) {
      debugPrint('Error loading media for property ${property.id}: $e');
    }
  }

  // Sort by display order (newest first)
  allVideos.sort((a, b) => b.displayOrder.compareTo(a.displayOrder));

  return allVideos;
});

class ToursScreen extends ConsumerWidget {
  const ToursScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allVideosAsync = ref.watch(allVideosProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: allVideosAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(
                'Failed to load tours',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        data: (allVideos) {
          if (allVideos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.slow_motion_video_rounded,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No property tours yet',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          // Shorts-style page view
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: allVideos.length,
            itemBuilder: (context, index) => ShortsVideoPlayer(
              video: allVideos[index],
              propertyId: allVideos[index].propertyId,
            ),
          );
        },
      ),
    );
  }
}

class ShortsVideoPlayer extends ConsumerStatefulWidget {
  final PropertyMedia video;
  final String propertyId;

  const ShortsVideoPlayer({
    super.key,
    required this.video,
    required this.propertyId,
  });

  @override
  ConsumerState<ShortsVideoPlayer> createState() => _ShortsVideoPlayerState();
}

class _ShortsVideoPlayerState extends ConsumerState<ShortsVideoPlayer>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }

  void _initializeVideo() {
    _error = false;
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.url),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      _controller.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('Video initialization timeout');
          if (mounted) {
            setState(() {
              _error = true;
            });
          }
          throw 'Video load timeout';
        },
      ).then((_) {
        if (mounted && !_error) {
          setState(() {});
          _controller.play();
          _isPlaying = true;
        }
      }).catchError((error) {
        debugPrint('Error initializing video: $error');
        if (mounted) {
          setState(() {
            _error = true;
          });
        }
      });

      _controller.addListener(_videoListener);
    } catch (e) {
      debugPrint('Error creating video controller: $e');
      if (mounted) {
        setState(() {
          _error = true;
        });
      }
    }
  }

  void _videoListener() {
    if (!mounted || _error) return;
    if (_controller.value.isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted && _isPlaying && !_error) {
        _controller.play();
      }
    } else if (state == AppLifecycleState.paused) {
      if (mounted) {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_error) return;
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync =
        ref.watch(propertyDetailProvider(widget.propertyId));

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video background
        if (!_error && _controller.value.isInitialized)
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: VideoPlayer(_controller),
              ),
            ),
          )
        else
          Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _error ? Icons.error_outline : Icons.videocam_outlined,
                    color: Colors.white54,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error ? 'Unable to load video' : 'Loading video...',
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                  if (_error)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          try {
                            _controller.removeListener(_videoListener);
                            _controller.dispose();
                          } catch (e) {
                            debugPrint('Error disposing controller: $e');
                          }
                          _initializeVideo();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

        // Dark gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.transparent,
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
        ),

        // Top app bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tours',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom property info
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 32, 80, 24),
              child: propertyAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (property) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      property.title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.location ?? 'Location not available',
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '\$${property.price.toStringAsFixed(0)}${property.listingType == 'RENT' ? '/month' : ''}',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Right side actions
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: Icons.favorite_border_rounded,
                label: '0',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _ActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: '0',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _ActionButton(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              // Play/pause button
              if (!_error)
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
