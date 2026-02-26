import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/media/models/property_media.dart';
import 'package:mobile/features/media/providers/media_providers.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PropertyMediaGallery extends ConsumerWidget {
  final String propertyId;
  final bool editable;
  final void Function(PropertyMedia video)? onVideoTap;

  const PropertyMediaGallery({
    super.key,
    required this.propertyId,
    this.editable = false,
    this.onVideoTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(propertyMediaProvider(propertyId));

    return mediaAsync.when(
      loading: () => const _GalleryShimmer(),
      error: (e, _) => _GalleryError(
        message: e.toString(),
        onRetry: () => ref.invalidate(propertyMediaProvider(propertyId)),
      ),
      data: (media) {
        if (media.isEmpty) return const _GalleryEmpty();

        final images = media.where((m) => m.isImage).toList();
        final videos = media.where((m) => m.isVideo).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty) ...[
              _SectionHeader(title: 'Photos', count: images.length),
              const SizedBox(height: 12),
              _ImageGrid(
                images: images,
                editable: editable,
                onDelete: editable
                    ? (id) => ref
                          .read(propertyMediaProvider(propertyId).notifier)
                          .removeMedia(id)
                    : null,
              ),
            ],
            if (videos.isNotEmpty) ...[
              SizedBox(height: images.isNotEmpty ? 24 : 0),
              _SectionHeader(title: 'Videos', count: videos.length),
              const SizedBox(height: 12),
              _VideoList(
                videos: videos,
                editable: editable,
                onDelete: editable
                    ? (id) => ref
                          .read(propertyMediaProvider(propertyId).notifier)
                          .removeMedia(id)
                    : null,
                // use caller's handler OR default to inline player
                onVideoTap:
                    onVideoTap ?? (video) => _openVideoPlayer(context, video),
              ),
            ],
          ],
        );
      },
    );
  }

  static void _openVideoPlayer(BuildContext context, PropertyMedia video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _VideoPlayerScreen(media: video),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INLINE VIDEO PLAYER SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class _VideoPlayerScreen extends StatefulWidget {
  final PropertyMedia media;
  const _VideoPlayerScreen({required this.media});

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.media.url),
      );
      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: widget.media.thumbnailUrl != null
            ? Image.network(widget.media.thumbnailUrl!, fit: BoxFit.cover)
            : null,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          backgroundColor: AppColors.borderLight,
          bufferedColor: AppColors.primary.withValues(alpha: 0.3),
        ),
      );

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Video ${widget.media.displayOrder + 1}',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: _hasError
            ? _PlayerError(
                message: _errorMessage ?? 'Failed to load video',
                onRetry: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = null;
                  });
                  _initPlayer();
                },
              )
            : _chewieController != null
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
      ),
    );
  }
}

class _PlayerError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _PlayerError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 56),
        const SizedBox(height: 16),
        Text(
          'Could not play video',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text('Retry', style: GoogleFonts.outfit()),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO BANNER
// ─────────────────────────────────────────────────────────────────────────────

class PropertyHeroBanner extends ConsumerWidget {
  final String propertyId;
  final double height;

  const PropertyHeroBanner({
    super.key,
    required this.propertyId,
    this.height = 260,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(propertyImagesProvider(propertyId));
    final totalCount = ref.watch(propertyMediaCountProvider(propertyId));

    if (images.isEmpty) return _HeroPlaceholder(height: height);

    return GestureDetector(
      onTap: () => _openGallerySheet(context, propertyId),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: Image.network(
                images.first.url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _HeroPlaceholder(height: height),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          if (totalCount > 1)
            Positioned(
              bottom: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library_outlined,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$totalCount',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openGallerySheet(BuildContext context, String propertyId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) =>
            _GallerySheet(propertyId: propertyId, scrollController: controller),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GALLERY SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _GallerySheet extends StatelessWidget {
  final String propertyId;
  final ScrollController scrollController;

  const _GallerySheet({
    required this.propertyId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'All Media',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            children: [
              // no onVideoTap needed → falls back to _openVideoPlayer automatically
              PropertyMediaGallery(propertyId: propertyId),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IMAGE GRID
// ─────────────────────────────────────────────────────────────────────────────

class _ImageGrid extends StatelessWidget {
  final List<PropertyMedia> images;
  final bool editable;
  final Future<void> Function(String id)? onDelete;

  const _ImageGrid({
    required this.images,
    required this.editable,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (_, i) => _ImageTile(
        media: images[i],
        editable: editable,
        onDelete: onDelete,
        onTap: () => _openFullscreen(context, images, i),
      ),
    );
  }

  void _openFullscreen(
    BuildContext context,
    List<PropertyMedia> images,
    int initial,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _FullscreenGallery(images: images, initialIndex: initial),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final PropertyMedia media;
  final bool editable;
  final Future<void> Function(String id)? onDelete;
  final VoidCallback onTap;

  const _ImageTile({
    required this.media,
    required this.editable,
    this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              media.url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.borderLight,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (editable)
              Positioned(
                top: 4,
                right: 4,
                child: _DeleteButton(onTap: () => onDelete?.call(media.id)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIDEO LIST
// ─────────────────────────────────────────────────────────────────────────────

class _VideoList extends StatelessWidget {
  final List<PropertyMedia> videos;
  final bool editable;
  final Future<void> Function(String id)? onDelete;
  final void Function(PropertyMedia video)? onVideoTap;

  const _VideoList({
    required this.videos,
    required this.editable,
    this.onDelete,
    this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: videos
          .map(
            (v) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _VideoTile(
                media: v,
                editable: editable,
                onDelete: onDelete,
                onTap: onVideoTap,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final PropertyMedia media;
  final bool editable;
  final Future<void> Function(String id)? onDelete;
  final void Function(PropertyMedia video)? onTap;

  const _VideoTile({
    required this.media,
    required this.editable,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(media),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    media.thumbnailUrl != null
                        ? Image.network(
                            media.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _videoPlaceholder(),
                          )
                        : _videoPlaceholder(),
                    Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'VIDEO',
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (media.durationSeconds > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              _formatDuration(media.durationSeconds),
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Order #${media.displayOrder + 1}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (editable)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _DeleteButton(onTap: () => onDelete?.call(media.id)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _videoPlaceholder() => Container(
    color: const Color(0xFF1A1A2E),
    child: const Icon(Icons.videocam_outlined, color: Colors.white54, size: 32),
  );

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FULLSCREEN IMAGE GALLERY
// ─────────────────────────────────────────────────────────────────────────────

class _FullscreenGallery extends StatefulWidget {
  final List<PropertyMedia> images;
  final int initialIndex;
  const _FullscreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _pageController;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_current + 1} / ${widget.images.length}',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: Image.network(
              widget.images[i].url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _DeleteButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
      ),
    );
  }
}

class _GalleryShimmer extends StatelessWidget {
  const _GalleryShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _GalleryEmpty extends StatelessWidget {
  const _GalleryEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'No media yet',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _GalleryError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 40,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            'Failed to load media',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: GoogleFonts.outfit(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  final double height;
  const _HeroPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF0E9E3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(
          Icons.home_outlined,
          size: 56,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
