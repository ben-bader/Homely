import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homely/core/theme/app_colors.dart';
import 'package:homely/domain/entities/feedback/feedback_entity.dart' as fb;
import '../../../ui/providers/feedback_providers.dart';
import 'package:homely/ui/providers/profile_providers.dart';
import '../../../ui/widgets/feedback/submit_feedback_sheet.dart';

class FeedbackList extends ConsumerWidget {
  final String propertyId;
  final String? currentUserId;

  const FeedbackList({super.key, required this.propertyId, this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackAsync = ref.watch(propertyFeedbackProvider(propertyId));
    final avgRating = ref.watch(propertyAverageRatingProvider(propertyId));
    final reviewCount = ref.watch(propertyReviewCountProvider(propertyId));
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reviews', style: tt.titleSmall),
                  if (reviewCount > 0)
                    Row(
                      children: [
                        _StarRow(rating: avgRating, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${avgRating.toStringAsFixed(1)}  •  $reviewCount ${reviewCount == 1 ? 'review' : 'reviews'}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () =>
                  SubmitFeedbackSheet.show(context, propertyId: propertyId),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_outline_rounded,
                      size: 13,
                      color: Color(0xFFFFC107),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Write a Review',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFC107),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        feedbackAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Failed to load reviews',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          data: (feedbacks) {
            if (feedbacks.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.star_border_rounded,
                        size: 40,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No reviews yet — be the first!',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: feedbacks
                  .take(5)
                  .map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FeedbackCard(
                        feedback: f,
                        currentUserId: currentUserId,
                        propertyId: propertyId,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _FeedbackCard extends ConsumerWidget {
  final fb.FeedbackEntity feedback;
  final String? currentUserId;
  final String propertyId;

  const _FeedbackCard({
    required this.feedback,
    required this.currentUserId,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwn = feedback.userId == currentUserId;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Builder(
                builder: (ctx) {
                  final profileAsync = ref.watch(
                    profileByIdProvider(feedback.userId),
                  );
                  final avatar = profileAsync.maybeWhen(
                    data: (p) =>
                        (p != null &&
                            p.avatarUrl != null &&
                            p.avatarUrl!.isNotEmpty)
                        ? NetworkImage(p.avatarUrl!)
                        : null,
                    orElse: () => null,
                  );
                  if (avatar != null) {
                    return CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.15,
                      ),
                      foregroundImage: avatar,
                    );
                  }
                  return CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      isOwn ? 'Me' : '★',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              _StarRow(rating: feedback.rating.toDouble(), size: 14),
              const Spacer(),
              if (isOwn)
                GestureDetector(
                  onTap: () => _confirmDelete(context, ref),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
          if (feedback.comment != null && feedback.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              feedback.comment!,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Review',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete your review?',
          style: GoogleFonts.outfit(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep',
              style: GoogleFonts.outfit(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(propertyFeedbackProvider(propertyId).notifier)
                    .delete(feedback.id);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString(), style: GoogleFonts.outfit()),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.outfit(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRow({required this.rating, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          filled
              ? Icons.star_rounded
              : half
              ? Icons.star_half_rounded
              : Icons.star_border_rounded,
          size: size,
          color: const Color(0xFFFFC107),
        );
      }),
    );
  }
}
