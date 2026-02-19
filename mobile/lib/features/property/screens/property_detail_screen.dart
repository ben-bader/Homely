import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/property/models/property.dart';
import 'package:mobile/features/property/providers/property_providers.dart';
import 'package:mobile/features/chat/repositories/chat_repository.dart';
import 'package:mobile/features/chat/providers/chat_providers.dart';
import 'package:mobile/features/chat/screens/chat_screen.dart';
import 'package:mobile/features/chat/models/conversation.dart';

const _kBg = Color(0xFFF7F7F7);
const _kAccent = Color(0xFF1A1A1A);

class PropertyDetailScreen extends ConsumerWidget {
  final String propertyId;
  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(propertyDetailProvider(propertyId));
    return async.when(
      loading: () => const Scaffold(
        backgroundColor: _kBg,
        body: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: _kAccent),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(backgroundColor: _kBg, elevation: 0),
        body: Center(child: Text('$e')),
      ),
      data: (p) => _Body(property: p),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  final Property property;
  const _Body({required this.property});
  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  int _imgIdx = 0;
  final _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    

    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Property image ────────────────────────────────────
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: SizedBox(
                    height: h * 0.42,
                    width: double.infinity,
                    child: p.images.isNotEmpty
                        ? Stack(
                            children: [
                              PageView.builder(
                                controller: _pageCtrl,
                                itemCount: p.images.length,
                                onPageChanged: (i) =>
                                    setState(() => _imgIdx = i),
                                itemBuilder: (_, i) => Image.network(
                                  p.images[i],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) =>
                                      _imgPlaceholder(h),
                                ),
                              ),
                              if (p.images.length > 1)
                                Positioned(
                                  bottom: 16,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      p.images.length,
                                      (i) => AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        width: _imgIdx == i ? 20 : 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: _imgIdx == i
                                              ? Colors.white
                                              : Colors.white54,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : _imgPlaceholder(h),
                  ),
                ),

                // ── Property info card ───────────────────────────────────────────
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                p.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: _kAccent,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'A\$${_fmt(p.price)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _kAccent,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: Color(0xFF888888),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                p.location,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF888888),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // ── Specs grid ────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: _SpecBox(
                                icon: Icons.bed_outlined,
                                label: '${p.beds}\nBeds',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SpecBox(
                                icon: Icons.bathtub_outlined,
                                label: '${p.baths}\nBaths',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SpecBox(
                                icon: Icons.garage_outlined,
                                label: '${p.garages}\nGarage',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SpecBox(
                                icon: Icons.square_foot_outlined,
                                label: '${p.sqm.toInt()}\nsqm',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Rest of content ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),

                      // ── Listing Agent ──────────────────────────────────────
                      const Text(
                        'Listing Agent',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _kAccent,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFEEEEEE),
                              backgroundImage: p.sellerAvatar != null
                                  ? NetworkImage(p.sellerAvatar!)
                                  : null,
                              child: p.sellerAvatar == null
                                  ? const Icon(
                                      Icons.person,
                                      color: Color(0xFF888888),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.sellerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: _kAccent,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    p.sellerAgency,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF888888),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _ContactBtn(property: p),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Location Address ───────────────────────────────
                      const Text(
                        'Location Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _kAccent,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 160,
                          color: const Color(0xFFDFDFDF),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 32,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  p.location,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _kAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Top bar overlay ──────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Property Detail',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _kAccent,
                    ),
                  ),
                 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder(double h) => Container(
    height: h * 0.42,
    color: const Color(0xFFEEEEEE),
    child: const Icon(Icons.home_outlined, size: 64, color: Color(0xFFCCCCCC)),
  );

  String _fmt(double p) {
    if (p >= 1000000) return '${(p / 1000000).toStringAsFixed(3)}';
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(0)}K';
    return p.toStringAsFixed(0);
  }
}

// ── "Chat with Seller" → creates conversation and opens chat screen ──────────────────────────────────
class _ContactBtn extends ConsumerWidget {
  final Property property;
  const _ContactBtn({required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        try {
          final repo = ref.read(chatRepositoryProvider);

          // Create conversation
          final conv = await repo.createConversation(property.id);

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                conversationId: conv.id,
                currentUserId: conv.clientId,

                // ✅ FIX: pass required data
                sellerName: property.sellerName,
                propertyTitle: property.title,
              ),
            ),
          );
        } catch (e) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: _kAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Chat with Seller',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SpecBox extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SpecBox({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE8E8E8)),
    ),
    child: Column(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF555555)),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.iconColor = _kAccent,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: iconColor),
    ),
  );
}
