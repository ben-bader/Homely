import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/chat/screens/conversation_screen.dart';
import 'package:mobile/features/property/models/property.dart';
import 'package:mobile/features/property/providers/property_providers.dart';
import 'package:mobile/features/profile/screens/profile_screen.dart';
import 'property_detail_screen.dart';

const _kBg = Color(0xFFF7F7F7);
const _kAccent = Color(0xFF1A1A1A);

final navIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(navIndexProvider);

    final tabs = [
      const _ExploreTab(),
      const _PlaceholderTab(label: 'Reels'),
      const ConversationsScreen(),
      const _PlaceholderTab(label: 'Favorites'),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: _kBg,
      body: IndexedStack(index: idx, children: tabs),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});
  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _kAccent,
      ),
    ),
  );
}

class _ExploreTab extends ConsumerStatefulWidget {
  const _ExploreTab();
  @override
  ConsumerState<_ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends ConsumerState<_ExploreTab> {
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

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                _IconBtn(
                  icon: Icons.notifications_outlined,
                  badge: true,
                  onTap: () {},
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFEEEEEE),
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.04),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF999999),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
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
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 22,
                    color: const Color(0xFFE0E0E0),
                  ),
                  GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Icon(
                        Icons.tune_rounded,
                        color: _kAccent,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

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
                    padding: const EdgeInsets.symmetric(horizontal: 18),
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
                        'Try Again',
                        style: TextStyle(
                          color: _kAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              data: (props) => props.isEmpty
                  ? const Center(
                      child: Text(
                        'No properties found',
                        style: TextStyle(color: Color(0xFF888888)),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: props.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, i) => PropertyCard(
                        property: props[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PropertyDetailScreen(propertyId: props[i].id),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
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

class PropertyCard extends ConsumerWidget {
  final Property property;
  final VoidCallback onTap;
  const PropertyCard({super.key, required this.property, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;
  const _IconBtn({required this.icon, required this.onTap, this.badge = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Icon(icon, color: _kAccent, size: 20),
        ),
        if (badge)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    ),
  );
}

class _BottomNav extends ConsumerWidget {
  const _BottomNav();

  static const _items = [
<<<<<<< HEAD
    (icon: Icons.home_rounded, label: 'Maison'),
    (icon: Icons.play_arrow_rounded, label: 'Media'),
=======
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.slow_motion_video_rounded, label: 'Reels'),
>>>>>>> 47238fa41b8a086273227b11cb582b9f1b394c98
    (icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
    (icon: Icons.favorite_border_rounded, label: 'Favorites'),
    (icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(navIndexProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_items.length, (i) {
              final active = i == idx;
              final item = _items[i];
              return GestureDetector(
                onTap: () => ref.read(navIndexProvider.notifier).state = i,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 64,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: active ? _kAccent : Colors.white,
                        shape: BoxShape.circle,
                        border: active
                            ? null
                            : Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: _kAccent.withOpacity(0.30),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        item.icon,
                        size: 24,
                        color: active ? Colors.white : const Color(0xFF999999),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
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
                elevation: 0,
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
