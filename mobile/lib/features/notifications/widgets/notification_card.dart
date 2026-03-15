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

  // Map type → icon + color (no emojis)
  IconData get _icon {
    switch (notification.type) {
      case 'NEW_CHAT_MESSAGE':
      case 'CONVERSATION_CREATED':
        return Icons.chat_bubble_outline_rounded;
      case 'VISIT_REQUEST_CREATED':
      case 'VISIT_REQUEST_STATUS_CHANGED':
        return Icons.calendar_today_outlined;
      case 'PROPERTY_CREATED':
      case 'PROPERTY_STATUS_CHANGED':
        return Icons.home_outlined;
      case 'BOOST_PURCHASED':
      case 'BOOST_STATUS_CHANGED':
        return Icons.rocket_launch_outlined;
      case 'FEEDBACK_RECEIVED':
        return Icons.star_outline_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'NEW_CHAT_MESSAGE':
      case 'CONVERSATION_CREATED':
        return AppColors.primary;
      case 'VISIT_REQUEST_CREATED':
      case 'VISIT_REQUEST_STATUS_CHANGED':
        return const Color(0xFF5B4E8A);
      case 'PROPERTY_CREATED':
      case 'PROPERTY_STATUS_CHANGED':
        return AppColors.success;
      case 'BOOST_PURCHASED':
      case 'BOOST_STATUS_CHANGED':
        return AppColors.warning;
      case 'FEEDBACK_RECEIVED':
        return const Color(0xFFFFC107);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification.read;
    final color = _iconColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isRead
              ? AppColors.background
              : AppColors.primary.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead
                ? AppColors.borderLight
                : AppColors.primary.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Icon circle ───────────────────────────
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, size: 19, color: color),
              ),

              const SizedBox(width: 12),

              // ── Text ──────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.getTitle(),
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: AppColors.accent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Unread dot
                        if (!isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
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

              // ── Mark read button (only for unread) ───
              if (!isRead && onMarkRead != null) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onMarkRead,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.subtleBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 15,
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
