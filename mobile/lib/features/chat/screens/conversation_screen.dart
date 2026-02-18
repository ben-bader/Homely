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
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: _kAccent),
          ),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: _kAccent,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: true,
      ),
      body: convsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: _kAccent)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 48, color: Color(0xFFCCCCCC)),
              const SizedBox(height: 12),
              Text('$e',
                  style: const TextStyle(
                      color: Color(0xFF888888), fontSize: 13)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(conversationsProvider),
                child: const Text('Réessayer',
                    style: TextStyle(color: _kAccent)),
              ),
            ],
          ),
        ),
        data: (convs) => convs.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 56, color: Color(0xFFDDDDDD)),
                    SizedBox(height: 16),
                    Text('Aucune conversation',
                        style: TextStyle(
                            color: Color(0xFF888888), fontSize: 15)),
                    SizedBox(height: 6),
                    Text('Contactez un vendeur pour commencer',
                        style: TextStyle(
                            color: Color(0xFFAAAAAA), fontSize: 13)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: convs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _ConvTile(conv: convs[i]),
              ),
      ),
    );
  }
}

class _ConvTile extends StatelessWidget {
  final Conversation conv;
  const _ConvTile({required this.conv});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFEEEEEE),
              backgroundImage: conv.sellerAvatar != null
                  ? NetworkImage(conv.sellerAvatar!)
                  : null,
              child: conv.sellerAvatar == null
                  ? const Icon(Icons.person, color: Color(0xFF888888))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(conv.sellerName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: _kAccent)),
                      Text(_fmtTime(conv.lastAt),
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF999999))),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(conv.propertyTitle,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFAAAAAA),
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conv.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: conv.unread > 0
                                ? _kAccent
                                : const Color(0xFF999999),
                            fontWeight: conv.unread > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (conv.unread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: _kAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${conv.unread}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
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

  String _fmtTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'maintenant';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}j';
  }
}