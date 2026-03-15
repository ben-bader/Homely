import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/notifications/models/notifications.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onMarkRead;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onMarkRead,
    this.onTap,
  });

  // Clean title — no emoji, no icon prefix
  String get _title {
    switch (notification.type) {
      case 'NEW_CHAT_MESSAGE':
        return 'New Message';
      case 'CONVERSATION_CREATED':
        return 'New Conversation';
      case 'VISIT_REQUEST_CREATED':
        return 'Visit Request';
      case 'VISIT_REQUEST_STATUS_CHANGED':
        return 'Visit Request Updated';
      case 'PROPERTY_CREATED':
        return 'Property Created';
      case 'PROPERTY_STATUS_CHANGED':
        return 'Property Updated';
      case 'BOOST_PURCHASED':
        return 'Boost Activated';
      case 'BOOST_STATUS_CHANGED':
        return 'Boost Updated';
      case 'FEEDBACK_RECEIVED':
        return 'New Review';
      default:
        return 'Notification';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification.read;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isRead
              ? AppColors.background
              : AppColors.primary.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRead
                ? AppColors.borderLight
                : AppColors.primary.withOpacity(0.12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Unread indicator line ─────────────────────
              if (!isRead)
                Container(
                  width: 3,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
              else
                const SizedBox(width: 15),

              // ── Text content ──────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                        color: AppColors.accent,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.getDetailedMessage(),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // ── Mark read ─────────────────────────────────
              if (!isRead && onMarkRead != null) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onMarkRead,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.subtleBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
