import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import '../providers/chat_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String currentUserId;
  final String chatTitle;
  final String? otherUserName;
  final String chatSubtitle;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.currentUserId,
    required this.chatTitle,
    this.otherUserName,
    required this.chatSubtitle,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String? _otherUserName;

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    ref.read(chatProvider(widget.conversationId).notifier).send(text);

    _controller.clear();
  }

  String _formatTime(dynamic sentAt) {
    DateTime date = sentAt is DateTime
        ? sentAt
        : DateTime.parse(sentAt.toString());

    final t = TimeOfDay.fromDateTime(date);
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }

  void _showMessageOptions(
    BuildContext context,
    String messageId,
    String body,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit"),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(messageId, body);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(chatProvider(widget.conversationId).notifier)
                    .deleteMessage(messageId, widget.currentUserId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(String messageId, String oldText) {
    final editController = TextEditingController(text: oldText);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Edit message",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: editController,
                autofocus: true,
                maxLines: null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  hintText: "Edit your message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final newText = editController.text.trim();

                        if (newText.isNotEmpty) {
                          ref
                              .read(
                                chatProvider(widget.conversationId).notifier,
                              )
                              .editMessage(
                                messageId,
                                newText,
                                widget.currentUserId,
                              );
                        }

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Save"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncMessages = ref.watch(chatProvider(widget.conversationId));

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),

        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _otherUserName ?? widget.chatTitle,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.accent,
              ),
            ),

            Text(
              widget.chatSubtitle,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          /// Messages list
          Expanded(
            child: asyncMessages.when(
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),

              error: (e, _) => Center(
                child: Text(
                  "Error: $e",
                  style: GoogleFonts.outfit(color: AppColors.textSecondary),
                ),
              ),

              data: (messages) {
                // only attempt to derive name from messages if we don't already
                // have one; do NOT fall back to our own message which would
                // overwrite the passed-in chatTitle with the sender's name.
                if (_otherUserName == null && messages.isNotEmpty) {
                  final others = messages
                      .where((m) => m.senderId != widget.currentUserId);
                  if (others.isNotEmpty) {
                    _otherUserName = others.first.senderName;
                  }
                }
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      "No messages yet",
                      style: GoogleFonts.outfit(color: AppColors.textSecondary),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    final isMe = msg.senderId == widget.currentUserId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            /// Sender name (important fix ⭐)
                            GestureDetector(
                              onLongPress: isMe
                                  ? () => _showMessageOptions(
                                      context,
                                      msg.id,
                                      msg.body,
                                    )
                                  : null,
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 280,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? AppColors.primary
                                      : AppColors.accent,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft: isMe
                                        ? const Radius.circular(18)
                                        : const Radius.circular(4),
                                    bottomRight: isMe
                                        ? const Radius.circular(4)
                                        : const Radius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  msg.body,
                                  style: GoogleFonts.outfit(
                                    color: AppColors.background,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              _formatTime(msg.sentAt),
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppColors.textTertiary,
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
          ),

          /// Input bar
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.borderMedium),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
