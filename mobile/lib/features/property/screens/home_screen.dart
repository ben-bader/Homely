import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/chat/screens/conversation_screen.dart';
import 'package:mobile/features/property/models/property.dart';
import 'package:mobile/features/property/providers/property_providers.dart';
import 'package:mobile/core/navigation/bottom_nav_provider.dart';
import 'property_detail_screen.dart';

const _kBg = Color(0xFFF7F7F7);
const _kAccent = Color(0xFF1A1A1A);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final List<String> _types = [
    'Any type',
    'Rent',
    'Buy',
    'House',
    'Apartment',
    'Villa',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(propertyFilterProvider);
    final propertiesAsync = ref.watch(propertiesProvider);

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _kAccent,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const Spacer(),
                  // Notification bell icon
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: _kAccent,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Profile picture
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFEEEEEE),
                    backgroundImage: null, // Can be set from user profile
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF888888),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Search bar ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF999999),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (v) => ref
                            .read(propertyFilterProvider.notifier)
                            .update((s) => s.copyWith(search: v)),
                        style: const TextStyle(fontSize: 15, color: _kAccent),
                        decoration: const InputDecoration(
                          hintText: 'Search your home...',
                          hintStyle: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showFilterSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Color(0xFF999999),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Filter chips ───────────────────────────────────────────
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _types.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final t = _types[i];
                  final selected = filter.type == t;
                  return GestureDetector(
                    onTap: () => ref
                        .read(propertyFilterProvider.notifier)
                        .update((s) => s.copyWith(type: t)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? _kAccent : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? _kAccent : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          t,
                          style: TextStyle(
                            color: selected ? Colors.white : _kAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ── Best Offers header ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Best Offers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _kAccent,
                      letterSpacing: -0.4,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF888888),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Liste des propriétés ──────────────────────────────────────
            Expanded(
              child: propertiesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _kAccent,
                  ),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 48,
                        color: Color(0xFFCCCCCC),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$e',
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => ref.invalidate(propertiesProvider),
                        child: const Text(
                          'Réessayer',
                          style: TextStyle(color: _kAccent),
                        ),
                      ),
                    ],
                  ),
                ),
                data: (properties) => properties.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune propriété trouvée',
                          style: TextStyle(color: Color(0xFF888888)),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: properties.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (_, i) => PropertyCard(
                          property: properties[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PropertyDetailScreen(
                                propertyId: properties[i].id,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }
}

// ── Property Card ─────────────────────────────────────────────────────────────
class PropertyCard extends ConsumerWidget {
  final Property property;
  final VoidCallback onTap;

  const PropertyCard({super.key, required this.property, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favs = ref.watch(favoritesProvider).valueOrNull ?? [];
    final isFav = favs.any((p) => p.id == property.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: property.images.isNotEmpty
                      ? Image.network(
                          property.images.first,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      property.type,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(favoritesProvider.notifier).toggle(property),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18,
                        color: isFav ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: Color(0xFF888888),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  property.location,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF888888),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${_fmt(property.price)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Chip(
                        icon: Icons.bed_outlined,
                        label: '${property.beds} Beds',
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        icon: Icons.bathtub_outlined,
                        label: '${property.baths} Baths',
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        icon: Icons.garage_outlined,
                        label: '${property.garages} Garage',
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

  String _fmt(double p) {
    if (p >= 1000000) return '${(p / 1000000).toStringAsFixed(1)}M';
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(0)}K';
    return p.toStringAsFixed(0);
  }

  Widget _placeholder() => Container(
    height: 200,
    width: double.infinity,
    color: const Color(0xFFF0F0F0),
    child: const Icon(Icons.home_outlined, size: 48, color: Color(0xFFCCCCCC)),
  );
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: _kBg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE8E8E8)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF666666)),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF444444),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}


class _BottomNav extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(bottomNavTabProvider);
    
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            active: currentTab == BottomNavTab.home,
            onTap: () => ref.read(bottomNavTabProvider.notifier).state = BottomNavTab.home,
          ),
          _NavItem(
            icon: Icons.location_on_outlined,
            active: currentTab == BottomNavTab.explore,
            onTap: () => ref.read(bottomNavTabProvider.notifier).state = BottomNavTab.explore,
          ),
          _NavItem(
            icon: Icons.favorite_border_rounded,
            active: currentTab == BottomNavTab.favorites,
            onTap: () => ref.read(bottomNavTabProvider.notifier).state = BottomNavTab.favorites,
          ),
          _NavItem(
            icon: Icons.chat_bubble_outline_rounded,
            active: currentTab == BottomNavTab.chat,
            onTap: () {
              ref.read(bottomNavTabProvider.notifier).state = BottomNavTab.chat;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConversationsScreen()),
              );
            },
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            active: currentTab == BottomNavTab.profile,
            onTap: () => ref.read(bottomNavTabProvider.notifier).state = BottomNavTab.profile,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.active,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: active ? _kAccent : Colors.white,
        shape: BoxShape.circle,
        boxShadow: active ? [
          BoxShadow(
            color: _kAccent.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Icon(
        icon,
        color: active ? Colors.white : const Color(0xFF999999),
        size: 24,
      ),
    ),
  );
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(propertyFilterProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Filter',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Status',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: ['All', 'Rent', 'Buy'].map((s) {
              final sel = filter.status == s;
              return GestureDetector(
                onTap: () => ref
                    .read(propertyFilterProvider.notifier)
                    .update((f) => f.copyWith(status: s)),
                child: Chip(
                  label: Text(s),
                  backgroundColor: sel
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFFEFEFEF),
                  labelStyle: TextStyle(
                    color: sel ? Colors.white : const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
