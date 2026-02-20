import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_providers.dart';

const _kBg = Color(0xFFF7F7F7);
const _kAccent = Color(0xFF1A1A1A);

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String currentUserId;
  final String sellerName;
  final String propertyTitle;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.currentUserId,
    required this.sellerName,
    required this.propertyTitle,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    ref
        .read(chatProvider(widget.conversationId).notifier)
        .send(text);

    _controller.clear();
  }

  String _formatTime(dynamic sentAt) {
    DateTime date;

    if (sentAt is DateTime) {
      date = sentAt;
    } else {
      date = DateTime.parse(sentAt.toString());
    }

    final time = TimeOfDay.fromDateTime(date);
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final asyncMessages =
        ref.watch(chatProvider(widget.conversationId));

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              widget.sellerName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              widget.propertyTitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          /// ================= MESSAGES =================
          Expanded(
            child: asyncMessages.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text("Error: $e")),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text("No messages yet"),
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
                    final isMe =
                        msg.senderId == widget.currentUserId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints:
                                  const BoxConstraints(
                                      maxWidth: 280),
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? _kAccent
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.only(
                                  topLeft:
                                      const Radius.circular(
                                          18),
                                  topRight:
                                      const Radius.circular(
                                          18),
                                  bottomLeft: isMe
                                      ? const Radius
                                          .circular(18)
                                      : const Radius
                                          .circular(4),
                                  bottomRight: isMe
                                      ? const Radius
                                          .circular(4)
                                      : const Radius
                                          .circular(18),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.05),
                                    blurRadius: 6,
                                    offset:
                                        const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                msg.body,
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(msg.sentAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
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

          /// ================= INPUT BAR =================
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                    decoration: BoxDecoration(
                      color: _kBg,
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration:
                          const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: _kAccent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _send,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
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
