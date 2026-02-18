import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/chat/providers/chat_providers.dart';
import 'package:mobile/features/chat/models/conversation.dart';
import 'chat_screen.dart';

const _kBg = Color(0xFFF7F7F7);
const _kAccent = Color(0xFF1A1A1A);

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _kAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: _kAccent,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: convsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (convs) {
          if (convs.isEmpty) {
            return const Center(
              child: Text(
                'No conversations yet',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: convs.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final conv = convs[i];

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      conversationId: conv.id,
                      currentUserId: conv.clientId,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFEEEEEE)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor:
                            const Color(0xFFEEEEEE),
                        backgroundImage:
                            conv.sellerAvatar != null
                                ? NetworkImage(
                                    conv.sellerAvatar!)
                                : null,
                        child: conv.sellerAvatar ==
                                null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            /// Seller + Time
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Text(
                                  conv.sellerName ??
                                      'Seller',
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _formatTime(
                                      conv.lastAt),
                                  style:
                                      const TextStyle(
                                    fontSize: 11,
                                    color:
                                        Color(0xFF999999),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 3),

                            /// Property title
                            Text(
                              conv.propertyTitle ??
                                  '',
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                fontSize: 12,
                                color:
                                    Color(0xFFAAAAAA),
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 6),

                            /// Last message
                            Text(
                              conv.lastMessage ??
                                  '',
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                fontSize: 13,
                                color:
                                    Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
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

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '';

    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60)
      return '${diff.inMinutes}m';
    if (diff.inHours < 24)
      return '${diff.inHours}h';
    if (diff.inDays < 7)
      return '${diff.inDays}d';

    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
