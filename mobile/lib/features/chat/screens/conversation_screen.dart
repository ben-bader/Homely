import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/profile/repositories/profile_repository.dart';
import '../models/conversation.dart';
import '../providers/chat_providers.dart';
import 'chat_screen.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _searchOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Conversation> _filter(List<Conversation> convs) {
    final q = _query.trim().toLowerCase();

    if (q.isEmpty) return convs;

    return convs.where((c) {
      final nameMatch =
          (c.sellerName ?? '').toLowerCase().contains(q);
      final msgMatch =
          (c.lastMessage ?? '').toLowerCase().contains(q);
      final propMatch =
          (c.propertyTitle ?? '').toLowerCase().contains(q);

      return nameMatch || msgMatch || propMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final convsAsync = ref.watch(conversationsProvider);
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _searchOpen
                        ? _SearchField(
                            controller: _searchController,
                            onChanged: (v) =>
                                setState(() => _query = v),
                            onClose: () {
                              setState(() {
                                _searchOpen = false;
                                _query = '';
                                _searchController.clear();
                              });
                            },
                          )
                        : Text(
                            "Messages",
                            style: GoogleFonts.outfit(
                              color: AppColors.accent,
                            letterSpacing: -0.5,
                            height: 1.1,
                            fontSize: 30,
                            ),
                          ),
                  ),
                  if (!_searchOpen) ...[
                    IconButton(
                      icon: const Icon(Icons.search,
                          color: AppColors.accent),
                      onPressed: () =>
                          setState(() => _searchOpen = true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert,
                          color: AppColors.accent),
                      onPressed: () {},
                    ),
                  ]
                ],
              ),
            ),

            /// BODY
            Expanded(
              child: convsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary),
                ),
                error: (e, _) => Center(
                  child: Text("Error: $e"),
                ),
                data: (convs) {
                  if (convs.isEmpty) {
                    return const _EmptyState();
                  }

                  final filtered = _filter(convs);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No results for "$_query"',
                        style: GoogleFonts.outfit(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.only(top: 8),
                    itemBuilder: (_, i) => _ConversationTile(
                      conv: filtered[i],
                      query: _query,
                      profileAsync: profileAsync,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// SEARCH FIELD
/// ============================================================

class _SearchField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => FocusScope.of(context).requestFocus(_focus),
    );
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.subtleBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search,
              color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              onChanged: widget.onChanged,
              decoration: const InputDecoration(
                hintText: "Search messages...",
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
          )
        ],
      ),
    );
  }
}

/// ============================================================
/// CONVERSATION TILE
/// ============================================================

class _ConversationTile extends ConsumerWidget {
  final Conversation conv;
  final String query;
  final AsyncValue profileAsync;

  const _ConversationTile({
    required this.conv,
    required this.query,
    required this.profileAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnread = conv.unread > 0;

    final initials = (conv.sellerName ?? "S")
        .split(" ")
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    return InkWell(
      onTap: () {
        profileAsync.when(
          data: (profile) {
            if (profile == null) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(

                  conversationId: conv.id,
                  currentUserId: profile.userId,
                  chatTitle: conv.sellerName ?? "Seller",
                  chatSubtitle: conv.propertyTitle ?? "",
                ),
              ),
            );
          },
          loading: () {},
          error: (_, __) {},
        );
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.borderLight,
              width: 0.8,
            ),
          ),
        ),
        child: Row(
          children: [
            _Avatar(initials: initials, hasUnread: hasUnread),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conv.sellerName ?? "Seller",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight:
                          hasUnread ? FontWeight.w700 : FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                  Text(
                    conv.lastMessage ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// AVATAR
/// ============================================================

class _Avatar extends StatelessWidget {
  final String initials;
  final bool hasUnread;

  const _Avatar({
    required this.initials,
    required this.hasUnread,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: hasUnread
          ? AppColors.primary
          : AppColors.borderLight,
      child: Text(
        initials,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// ============================================================
/// EMPTY STATE
/// ============================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("No messages yet"),
    );
  }
}