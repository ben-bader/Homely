import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:video_player/video_player.dart';

// ── Progress bar (no timestamps) ──────────────────────────────────────────────

class ReelProgressBar extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback? onSeekStart;

  const ReelProgressBar({
    super.key,
    required this.controller,
    this.onSeekStart,
  });

  @override
  Widget build(BuildContext context) {
    final position = controller.value.position;
    final duration = controller.value.duration;
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final buffered =
        controller.value.buffered.isNotEmpty && duration.inMilliseconds > 0
            ? (controller.value.buffered.last.end.inMilliseconds /
                    duration.inMilliseconds)
                .clamp(0.0, 1.0)
            : 0.0;

    return GestureDetector(
      onHorizontalDragUpdate: (d) {
        onSeekStart?.call();
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final ratio =
            (d.localPosition.dx / box.size.width).clamp(0.0, 1.0);
        controller.seekTo(duration * ratio);
      },
      child: SizedBox(
        height: 6,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Track
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Buffered
            FractionallySizedBox(
              widthFactor: buffered,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Played
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gradient overlays ──────────────────────────────────────────────────────────

class ReelGradients extends StatelessWidget {
  const ReelGradients({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 140,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.65),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 340,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.92),
                  Colors.black.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Side action button ─────────────────────────────────────────────────────────

class ReelSideBtn extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool active;
  final Color? activeColor;
  final VoidCallback onTap;

  const ReelSideBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.activeIcon,
    this.active = false,
    this.activeColor,
  });

  @override
  State<ReelSideBtn> createState() => _ReelSideBtnState();
}

class _ReelSideBtnState extends State<ReelSideBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _scale = Tween(begin: 1.0, end: 1.3)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _anim.forward(from: 0).then((_) => _anim.reverse());
        widget.onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Icon(
              widget.active
                  ? (widget.activeIcon ?? widget.icon)
                  : widget.icon,
              color: widget.active
                  ? (widget.activeColor ?? Colors.white)
                  : Colors.white,
              size: 28,
              shadows: const [
                Shadow(color: Colors.black87, blurRadius: 8)
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.label,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Circle icon button ─────────────────────────────────────────────────────────

class ReelCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const ReelCircleBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white12),
          ),
          child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
        ),
      );
}

// ── Property badge ─────────────────────────────────────────────────────────────

class ReelBadge extends StatelessWidget {
  final String text;
  final Color color;
  const ReelBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      );
}

// ── Play/pause center overlay ──────────────────────────────────────────────────

class ReelPlayPauseOverlay extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const ReelPlayPauseOverlay({
    super.key,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      );
}

// ── Double-tap heart ───────────────────────────────────────────────────────────

class ReelHeartAnimation extends StatelessWidget {
  final Animation<double> animation;
  const ReelHeartAnimation({super.key, required this.animation});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Center(
          child: ScaleTransition(
            scale: Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.elasticOut),
            ),
            child: FadeTransition(
              opacity: Tween(begin: 1.0, end: 0.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.6, 1.0),
                ),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 96,
                shadows: [Shadow(color: Colors.black54, blurRadius: 20)],
              ),
            ),
          ),
        ),
      );
}

// ── State screens ──────────────────────────────────────────────────────────────

class ReelLoadingScreen extends StatelessWidget {
  const ReelLoadingScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white24),
        ),
      );
}

class ReelErrorScreen extends StatelessWidget {
  final String message;
  const ReelErrorScreen({super.key, this.message = 'Failed to load tours'});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: Colors.white24),
              const SizedBox(height: 16),
              Text(message,
                  style: GoogleFonts.outfit(
                      fontSize: 15, color: Colors.white38)),
            ],
          ),
        ),
      );
}

class ReelEmptyScreen extends StatelessWidget {
  final String message;
  const ReelEmptyScreen(
      {super.key, this.message = 'No property tours yet'});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.slow_motion_video_rounded,
                  size: 64, color: Colors.white.withOpacity(0.12)),
              const SizedBox(height: 16),
              Text(message,
                  style: GoogleFonts.outfit(
                      fontSize: 15, color: Colors.white38)),
            ],
          ),
        ),
      );
}