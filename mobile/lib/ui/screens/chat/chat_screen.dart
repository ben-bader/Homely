import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homely/core/theme/app_colors.dart';
import '../../../domain/entities/chat/message_entity.dart';
import '../../providers/chat_providers.dart';
import 'package:homely/ui/providers/profile_providers.dart';
import '../property/property_detail_screen.dart';
import '../../helpers/profile_ownership_helper.dart';
import '../profile/user_profile_screen.dart';

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

  // ── WhatsApp-style time format ─────────────────────────────────────────────
  String _formatTime(dynamic sentAt) {
    final DateTime date = sentAt is DateTime
        ? sentAt
        : DateTime.parse(sentAt.toString());
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(messageId, body);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
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
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Edit message',
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
                  hintText: 'Edit your message...',
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
                      child: const Text('Cancel'),
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
                      child: const Text('Save'),
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

    // Attempt to set other user avatar/name from messages if available.

    final convsAsync = ref.watch(conversationsProvider);
    String? otherAvatarUrl;
    String? otherUserId;
    convsAsync.whenData((convs) {
      try {
        final conv = convs.firstWhere((c) => c.id == widget.conversationId);
        otherUserId = widget.currentUserId == conv.participantOneId
            ? conv.participantTwoId
            : conv.participantOneId;
        if (_otherUserName == null) {
          _otherUserName = conv.otherPersonName(widget.currentUserId);
        }
      } catch (_) {
        otherUserId = null;
      }
    });

    // Prefer canonical profile avatar
    final otherProfileAsync = (otherUserId?.isNotEmpty == true)
        ? ref.watch(profileByIdProvider(otherUserId!))
        : null;
    otherAvatarUrl =
        otherProfileAsync?.maybeWhen(
          data: (p) =>
              (p != null && p.avatarUrl != null && p.avatarUrl!.isNotEmpty)
              ? p.avatarUrl
              : null,
          orElse: () => null,
        ) ??
        otherAvatarUrl;

    // Fallback: use conversation participant avatar if profile avatar missing
    if (otherAvatarUrl == null && convsAsync.asData?.value != null) {
      try {
        final conv = convsAsync.asData!.value.firstWhere(
          (c) => c.id == widget.conversationId,
        );
        otherAvatarUrl = widget.currentUserId == conv.participantOneId
            ? conv.participantTwoAvatar
            : conv.participantOneAvatar;
      } catch (_) {}
    }

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
        title: GestureDetector(
          onTap: (otherUserId != null && otherUserId!.isNotEmpty)
              ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          UserProfileScreen(userId: otherUserId!),
                    ),
                  )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (otherAvatarUrl != null && otherAvatarUrl!.isNotEmpty)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(otherAvatarUrl!),
                  backgroundColor: AppColors.subtleBackground,
                )
              else
                const SizedBox.shrink(),
              const SizedBox(width: 8),
              Column(
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
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          if (asyncMessages.asData?.value.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(chatProvider(widget.conversationId).notifier)
                      .loadMoreMessages();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  'Load more messages',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          // ── Messages list ───────────────────────────────────────────────
          Expanded(
            child: asyncMessages.when(
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: GoogleFonts.outfit(color: AppColors.textSecondary),
                ),
              ),
              data: (messages) {
                if (_otherUserName == null && messages.isNotEmpty) {
                  final others = messages.where(
                    (m) => m.senderId != widget.currentUserId,
                  );
                  if (others.isNotEmpty) {
                    _otherUserName = others.first.senderName;
                  }
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet',
                      style: GoogleFonts.outfit(color: AppColors.textSecondary),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    final isMe = msg.senderId == widget.currentUserId;

                    final isPropertyShare = msg.isPropertyShare;
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: isPropertyShare
                            ? _buildPropertyShareCard(msg, isMe)
                            : GestureDetector(
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
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    8,
                                    12,
                                    6,
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
                                  // ── WhatsApp layout: time floats bottom-right ──
                                  child: Wrap(
                                    alignment: WrapAlignment.end,
                                    crossAxisAlignment: WrapCrossAlignment.end,
                                    spacing: 6,
                                    children: [
                                      Text(
                                        msg.body,
                                        style: GoogleFonts.outfit(
                                          color: AppColors.background,
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                      // Timestamp + checkmark — sits at end of
                                      // last line, slightly lower
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 1,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              _formatTime(msg.sentAt),
                                              style: GoogleFonts.outfit(
                                                fontSize: 10,
                                                color: AppColors.background
                                                    .withValues(alpha: 0.6),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            if (isMe) ...[
                                              const SizedBox(width: 3),
                                              Icon(
                                                Icons.done_all_rounded,
                                                size: 13,
                                                color: AppColors.background
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ── Input bar ───────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              12,
              8,
              12,
              MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.borderLight, width: 0.8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.subtleBackground,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      style: GoogleFonts.outfit(
                        color: AppColors.accent,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: GoogleFonts.outfit(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
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

  Widget _buildPropertyShareCard(MessageEntity msg, bool isMe) {
    final title = msg.propertyTitle?.isNotEmpty == true
        ? msg.propertyTitle!
        : msg.body;
    return GestureDetector(
      onTap: msg.propertyId != null
          ? () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PropertyDetailScreen(propertyId: msg.propertyId!),
              ),
            )
          : null,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.accent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (msg.propertyImageUrl != null &&
                msg.propertyImageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Image.network(
                  msg.propertyImageUrl!,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 140,
                    color: AppColors.subtleBackground,
                    child: const Icon(
                      Icons.home_outlined,
                      size: 48,
                      color: Colors.white70,
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.subtleBackground,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.home_outlined,
                    size: 48,
                    color: Colors.white70,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: AppColors.background,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (msg.propertyLocation != null &&
                      msg.propertyLocation!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        msg.propertyLocation!,
                        style: GoogleFonts.outfit(
                          color: AppColors.background.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (msg.propertyPrice != null &&
                      msg.propertyPrice!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        msg.propertyPrice!,
                        style: GoogleFonts.outfit(
                          color: AppColors.background.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.open_in_new,
                        size: 14,
                        color: AppColors.background.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'View property',
                        style: GoogleFonts.outfit(
                          color: AppColors.background.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
