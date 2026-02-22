import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
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
      final nameMatch = (c.sellerName ?? '').toLowerCase().contains(q);
      final msgMatch = (c.lastMessage ?? '').toLowerCase().contains(q);
      final propMatch = (c.propertyTitle ?? '').toLowerCase().contains(q);
      return nameMatch || msgMatch || propMatch;
    }).toList();
  }

  void _openSearch() => setState(() => _searchOpen = true);

  void _closeSearch() => setState(() {
        _searchOpen = false;
        _query = '';
        _searchController.clear();
      });

  @override
  Widget build(BuildContext context) {
    final convsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _searchOpen
                          ? _SearchField(
                              key: const ValueKey('search'),
                              controller: _searchController,
                              onChanged: (v) => setState(() => _query = v),
                              onClose: _closeSearch,
                            )
                          : Align(
                              key: const ValueKey('title'),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Messages',
                                style: GoogleFonts.outfit(
                                  color: AppColors.accent,
                            letterSpacing: -0.5,
                            height: 1.1,
                            fontSize: 30,
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (!_searchOpen) ...[
                    IconButton(
                      icon: const Icon(Icons.search_rounded,
                          color: AppColors.accent, size: 24),
                      onPressed: _openSearch,
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded,
                          color: AppColors.accent, size: 24),
                      onPressed: () {},
                    ),
                  ],
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────
            Expanded(
              child: convsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(
                        'Something went wrong',
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.toString(),
                        style: GoogleFonts.outfit(
                            color: AppColors.textSecondary, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                data: (convs) {
                  if (convs.isEmpty) return const _EmptyState();

                  final filtered = _filter(convs);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded,
                              size: 48, color: AppColors.textTertiary),
                          const SizedBox(height: 12),
                          Text(
                            'No results for "$_query"',
                            style: GoogleFonts.outfit(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) =>
                        _ConversationTile(conv: filtered[i], query: _query),
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

// ─────────────────────────────────────────────────────────────
// Search Field
// ─────────────────────────────────────────────────────────────

class _SearchField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  const _SearchField({
    super.key,
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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => FocusScope.of(context).requestFocus(_focus));
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
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded,
              color: AppColors.textTertiary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              onChanged: widget.onChanged,
              style: GoogleFonts.outfit(
                color: AppColors.accent,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: 'Search messages or sellers...',
                hintStyle: GoogleFonts.outfit(
                  color: AppColors.textTertiary,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          GestureDetector(
            onTap: widget.onClose,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.close_rounded,
                  color: AppColors.textSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Conversation Tile
// ─────────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final Conversation conv;
  final String query;

  const _ConversationTile({required this.conv, required this.query});

  @override
  Widget build(BuildContext context) {
    final hasUnread = conv.unread > 0;
    final initials = (conv.sellerName ?? 'S')
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return InkWell(
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
      splashColor: AppColors.primary.withOpacity(0.06),
      highlightColor: AppColors.primary.withOpacity(0.04),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderLight, width: 0.8),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            _Avatar(initials: initials, hasUnread: hasUnread),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightText(
                    text: conv.sellerName ?? 'Seller',
                    query: query,
                    style: GoogleFonts.outfit(
                      fontWeight:
                          hasUnread ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 16,
                      color: AppColors.accent,
                    ),
                  ),
                  if ((conv.propertyTitle ?? '').isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        const Icon(Icons.home_outlined,
                            size: 12, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: _HighlightText(
                            text: conv.propertyTitle!,
                            query: query,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  _HighlightText(
                    text: conv.lastMessage ?? '',
                    query: query,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: hasUnread
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight:
                          hasUnread ? FontWeight.w500 : FontWeight.w400,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Timestamp + badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  conv.lastAt != null ? _formatTime(conv.lastAt!) : '',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: hasUnread
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight:
                        hasUnread ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                if (hasUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      conv.unread > 99 ? '99+' : '${conv.unread}',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dt.year, dt.month, dt.day);

    if (msgDay == today) {
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $period';
    } else if (msgDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${dt.day}/${dt.month}/${dt.year.toString().substring(2)}';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Highlight matching query text
// ─────────────────────────────────────────────────────────────

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final int? maxLines;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.style,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return Text(text,
          style: style,
          maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null);
    }

    final q = query.trim().toLowerCase();
    final lower = text.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lower.indexOf(q, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + q.length),
        style: style.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          backgroundColor: AppColors.primary.withOpacity(0.10),
        ),
      ));
      start = idx + q.length;
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow:
          maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Avatar
// ─────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initials;
  final bool hasUnread;

  const _Avatar({required this.initials, required this.hasUnread});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: hasUnread
              ? [AppColors.primary, const Color(0xFF5B7FA6)]
              : [AppColors.borderMedium, AppColors.borderLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.outfit(
            color: hasUnread ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.subtleBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 36,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No messages yet',
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Start a conversation by contacting a seller',
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}