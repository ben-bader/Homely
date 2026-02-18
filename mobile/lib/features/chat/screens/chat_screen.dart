import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_providers.dart';

const _kBg = Color(0xFFF5F5F5);
const _kMyBubble = Color(0xFF1A1A1A);
const _kOtherBubble = Colors.white;

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.currentUserId,
  });

  @override
  ConsumerState<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller =
      TextEditingController();
  final ScrollController _scrollController =
      ScrollController();

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
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute =
        dt.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    final messages =
        ref.watch(chatProvider(widget.conversationId));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Chat",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme:
            const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [

          /// ================= MESSAGES =================
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                final isMine =
                    message.senderId ==
                        widget.currentUserId;

                return Align(
                  alignment: isMine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          MediaQuery.of(context)
                                  .size
                                  .width *
                              0.75,
                    ),
                    child: Container(
                      margin:
                          const EdgeInsets.only(
                              bottom: 10),
                      padding:
                          const EdgeInsets
                              .symmetric(
                                  horizontal:
                                      14,
                                  vertical:
                                      10),
                      decoration:
                          BoxDecoration(
                        color: isMine
                            ? _kMyBubble
                            : _kOtherBubble,
                        borderRadius:
                            BorderRadius
                                .circular(
                                    18),
                        boxShadow: isMine
                            ? []
                            : const [
                                BoxShadow(
                                  color:
                                      Color.fromRGBO(
                                          0,
                                          0,
                                          0,
                                          0.06),
                                  blurRadius:
                                      6,
                                  offset:
                                      Offset(
                                          0,
                                          2),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .end,
                        children: [

                          /// MESSAGE TEXT
                          Align(
                            alignment:
                                Alignment
                                    .centerLeft,
                            child: Text(
                              message.body,
                              style:
                                  TextStyle(
                                fontSize:
                                    14,
                                height:
                                    1.4,
                                color: isMine
                                    ? Colors
                                        .white
                                    : Colors
                                        .black87,
                              ),
                            ),
                          ),

                          const SizedBox(
                              height: 4),

                          /// TIME
                          Text(
                            _formatTime(
                                message
                                    .sentAt),
                            style:
                                TextStyle(
                              fontSize:
                                  10,
                              color: isMine
                                  ? Colors
                                      .white70
                                  : Colors
                                      .grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// ================= INPUT FIELD =================
          Container(
            padding:
                const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10),
            decoration:
                const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color:
                      Color.fromRGBO(
                          0, 0, 0, 0.05),
                  blurRadius: 8,
                  offset:
                      Offset(0, -2),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                                horizontal:
                                    16),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                              0xFFF0F0F0),
                      borderRadius:
                          BorderRadius
                              .circular(
                                  30),
                    ),
                    child: TextField(
                      controller:
                          _controller,
                      decoration:
                          const InputDecoration(
                        hintText:
                            "Type a message...",
                        border:
                            InputBorder
                                .none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                    width: 8),
                GestureDetector(
                  onTap: () {
                    final text =
                        _controller.text
                            .trim();
                    if (text.isEmpty)
                      return;

                    ref
                        .read(chatProvider(
                                widget
                                    .conversationId)
                            .notifier)
                        .send(text);

                    _controller.clear();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets
                            .all(12),
                    decoration:
                        const BoxDecoration(
                      color:
                          _kMyBubble,
                      shape:
                          BoxShape.circle,
                    ),
                    child:
                        const Icon(
                      Icons.send,
                      size: 18,
                      color:
                          Colors.white,
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
