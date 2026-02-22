import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import '../providers/chat_providers.dart';
import 'chat_screen.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        
        elevation: 0,
        centerTitle: true,
        title: Text('Messages',
            style: GoogleFonts.outfit(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                fontSize: 24)),
      ),
      body: convsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary)),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style:
                    GoogleFonts.outfit(color: AppColors.textSecondary))),
        data: (convs) {
          if (convs.isEmpty) {
            return Center(
                child: Text('No conversations yet',
                    style: GoogleFonts.outfit(
                        color: AppColors.textSecondary)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: convs.length,
            itemBuilder: (_, i) {
              final conv = convs[i];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      conversationId: conv.id,
                      currentUserId: conv.clientId,
                      sellerName: conv.sellerName ?? 'Seller',
                      propertyTitle: conv.propertyTitle ?? '',
                    ),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.005),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.borderLight,
                        child: const Icon(Icons.person,
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(conv.sellerName ?? 'Seller',
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: AppColors.primary)),
                            
                
                            Text(conv.lastMessage ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Text(
                        conv.lastAt != null
                            ? TimeOfDay.fromDateTime(conv.lastAt!)
                                .format(context)
                            : '',
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppColors.textSecondary),
                      ),
                    ],

                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}