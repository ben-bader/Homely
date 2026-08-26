import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homely/core/theme/app_colors.dart';
import '../../../ui/providers/property_view_providers.dart';

class PropertyViewCountBadge extends ConsumerWidget {
  final String propertyId;

  final bool expanded;

  const PropertyViewCountBadge({
    super.key,
    required this.propertyId,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(propertyViewCountProvider(propertyId));

    return countAsync.when(
      loading: () => expanded ? _ExpandedSkeleton() : _CompactSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: (count) =>
          expanded ? _ExpandedBadge(count: count) : _CompactBadge(count: count),
    );
  }
}

class _CompactBadge extends StatelessWidget {
  final int count;
  const _CompactBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_outlined, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            _format(count),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedBadge extends StatelessWidget {
  final int count;
  const _ExpandedBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _format(count),
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'views',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 22,
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _ExpandedSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

String _format(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
  return '$count';
}
