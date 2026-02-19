import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_providers.dart';

const _kBg     = Color(0xFFF7F7F7);
const _kAccent = Color(0xFF1A1A1A);

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.currentUserId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller    = TextEditingController();
  final ScrollController      _scrollController = ScrollController();

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(chatProvider(widget.conversationId).notifier).send(text);
    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider(widget.conversationId));

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _kAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Chat',
            style: TextStyle(color: _kAccent, fontWeight: FontWeight.w700, fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF0F0F0), height: 1),
        ),
      ),

      body: Column(
        children: [
          // ── Messages ─────────────────────────────────────────────────
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text('No messages yet',
                        style: TextStyle(color: Color(0xFF999999), fontSize: 14)))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final msg  = messages[i];
                      final isMe = msg.senderId == widget.currentUserId;

                      // Show avatar only at the start of an "other" group
                      final showAvatar = !isMe &&
                          (i == 0 || messages[i - 1].senderId == widget.currentUserId);

                      return _MessageRow(
                        body: msg.body,
                        time: _formatTime(msg.sentAt),
                        isMe: isMe,
                        showAvatar: showAvatar,
                      );
                    },
                  ),
          ),

          // ── Input bar ────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(fontSize: 15, color: _kAccent),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 13),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 46, height: 46,
                    decoration: const BoxDecoration(color: _kAccent, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white),
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

// ── Instagram-style message row ───────────────────────────────────────────────
class _MessageRow extends StatelessWidget {
  final String body;
  final String time;
  final bool isMe;
  final bool showAvatar;

  const _MessageRow({
    required this.body,
    required this.time,
    required this.isMe,
    required this.showAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Indent so bubbles never take the full width
      padding: EdgeInsets.only(
        top: 3, bottom: 3,
        left:  isMe ? 64 : 0,
        right: isMe ? 0 : 64,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // ── Other user avatar ─────────────────────────────────────
          if (!isMe) ...[
            SizedBox(
              width: 30,
              child: showAvatar
                  ? const CircleAvatar(
                      radius: 13,
                      backgroundColor: Color(0xFFDDDDDD),
                      child: Icon(Icons.person, size: 14, color: Color(0xFF888888)),
                    )
                  : null,
            ),
            const SizedBox(width: 6),
          ],

          // ── Bubble + timestamp ────────────────────────────────────
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? _kAccent : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(20),
                      topRight:    const Radius.circular(20),
                      bottomLeft:  Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                    boxShadow: isMe
                        ? []
                        : [const BoxShadow(color: Color.fromRGBO(0,0,0,0.07),
                              blurRadius: 6, offset: Offset(0, 2))],
                  ),
                  child: Text(
                    body,
                    style: TextStyle(
                      fontSize: 14, height: 1.4,
                      color: isMe ? Colors.white : _kAccent,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                  child: Text(time,
                      style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}