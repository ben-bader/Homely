// lib/features/property/screens/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/chat/screens/conversation_screen.dart';
import 'package:mobile/features/property/models/property.dart';
import 'package:mobile/features/property/providers/property_providers.dart';
import 'package:mobile/features/profile/screens/profile_screen.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'property_detail_screen.dart';

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
      backgroundColor: AppColors.background,
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
        child: Text(label, style: Theme.of(context).textTheme.titleLarge),
      );
}

// ── Explore Tab ───────────────────────────────────────────────────────────────
class _ExploreTab extends ConsumerStatefulWidget {
  const _ExploreTab();
  @override
  ConsumerState<_ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends ConsumerState<_ExploreTab> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  static const _types = ['Any type', 'Rent', 'Sell', 'House', 'Apartment', 'Villa'];
  static const _listingTypes = {'Rent', 'Sell'};

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(propertyFilterProvider.notifier).update(
            (s) => s.copyWith(search: value.trim()),
          );
    });
  }

  void _onSearchSubmitted(String value) {
    _debounce?.cancel();
    ref.read(propertyFilterProvider.notifier).update(
          (s) => s.copyWith(search: value.trim()),
        );
  }

  void _onChipTap(String tapped) {
    final notifier = ref.read(propertyFilterProvider.notifier);
    if (tapped == 'Any type') {
      notifier.update((s) => s.resetFilters());
      return;
    }
    final filter = ref.read(propertyFilterProvider);
    if (_listingTypes.contains(tapped)) {
      final newStatus = filter.status == tapped ? null : tapped;
      notifier.update((s) => s.copyWith(status: newStatus ?? 'All'));
    } else {
      final newType = filter.type == tapped ? null : tapped;
      notifier.update((s) => s.copyWith(type: newType ?? 'Any type'));
    }
  }

  bool _isChipSelected(String chip, PropertyFilter filter) {
    if (chip == 'Any type') return !filter.isFiltering;
    if (_listingTypes.contains(chip)) return filter.status == chip;
    return filter.type == chip;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final filter = ref.watch(propertyFilterProvider);
    final badgeCount = filter.activeFilterCount;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text('Explore',
                      style: tt.headlineMedium?.copyWith(color: AppColors.primary)),
                  const Spacer(),
                  _IconBtn(icon: Icons.notifications_outlined, badge: true, onTap: () {}),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 22.5,
                    backgroundColor: AppColors.accentLight,
                    child: const Icon(Icons.person, color: AppColors.background, size: 25),
                  ),
                ],
              ),
            ),
          ),

          // ── Search bar ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        onSubmitted: _onSearchSubmitted,
                        style: tt.bodyLarge?.copyWith(color: AppColors.primary),
                        decoration: InputDecoration(
                          hintText: 'Search your home...',
                          hintStyle: tt.bodySmall?.copyWith(color: AppColors.textTertiary),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (_, value, __) => value.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                ref
                                    .read(propertyFilterProvider.notifier)
                                    .update((s) => s.copyWith(clearSearch: true));
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.close_rounded,
                                    color: AppColors.textTertiary, size: 18),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    Container(width: 1, height: 22, color: AppColors.borderLight),
                    // ── Filter button with active-count badge ──
                    GestureDetector(
                      onTap: () => _showFilterSheet(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                            if (badgeCount > 0)
                              Positioned(
                                top: -6,
                                right: -8,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$badgeCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Filter chips ─────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                itemCount: _types.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final t = _types[i];
                  final selected = _isChipSelected(t, filter);
                  return GestureDetector(
                    onTap: () => _onChipTap(t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : const Color(0x00FFFFFF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(width: 1, color: AppColors.borderDark),
                      ),
                      child: Center(
                        child: Text(
                          t,
                          style: tt.labelLarge?.copyWith(
                            fontSize: 13,
                            color: selected ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Section header ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    filter.search != null && filter.search!.isNotEmpty
                        ? 'Results for "${filter.search}"'
                        : filter.isFiltering
                            ? 'Filtered Results'
                            : 'Best Offers',
                    style: tt.titleMedium?.copyWith(color: AppColors.primary),
                  ),
                  // Clear all filters button
                  if (filter.isFiltering)
                    GestureDetector(
                      onTap: () => ref
                          .read(propertyFilterProvider.notifier)
                          .update((s) => s.resetFilters()),
                      child: Text(
                        'Clear filters',
                        style: tt.labelMedium?.copyWith(color: AppColors.error),
                      ),
                    )
                  else
                    Text('See all',
                        style: tt.labelMedium?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),

          // ── Property list (isolated — only this rebuilds on data changes) ──
          const _PropertyList(),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => const _FilterSheet(),
    );
  }
}

// ── Property List ─────────────────────────────────────────────────────────────
class _PropertyList extends ConsumerWidget {
  const _PropertyList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final propertiesAsync = ref.watch(propertiesProvider);

    return propertiesAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              Text('$e', style: tt.bodySmall),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(propertiesProvider),
                child: Text('Try Again',
                    style: tt.labelLarge?.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
      data: (props) => props.isEmpty
          ? SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off_rounded,
                        size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text('No properties found', style: tt.bodyMedium),
                  ],
                ),
              ),
            )
          : SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.separated(
                itemCount: props.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => PropertyCard(
                  property: props[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PropertyDetailScreen(propertyId: props[i].id),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

// ── Filter Sheet ──────────────────────────────────────────────────────────────
class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();
  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  // Local state — only committed to provider when Apply is tapped
  late String? _status;
  late String? _propertyType;
  late TextEditingController _cityController;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  static const _statuses = ['All', 'Rent', 'Buy'];
  static const _propertyTypes = ['Any type', 'House', 'Apartment', 'Villa', 'Studio', 'Commercial', 'Land'];

  @override
  void initState() {
    super.initState();
    // Pre-populate from current filter
    final f = ref.read(propertyFilterProvider);
    _status = f.status ?? 'All';
    _propertyType = f.type ?? 'Any type';
    _cityController = TextEditingController(text: f.city ?? '');
    _minPriceController = TextEditingController(
        text: f.minPrice != null ? f.minPrice!.toStringAsFixed(0) : '');
    _maxPriceController = TextEditingController(
        text: f.maxPrice != null ? f.maxPrice!.toStringAsFixed(0) : '');
  }

  @override
  void dispose() {
    _cityController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _apply() {
    final minText = _minPriceController.text.trim();
    final maxText = _maxPriceController.text.trim();

    ref.read(propertyFilterProvider.notifier).update((f) => PropertyFilter(
          search: f.search, // preserve active search
          status: _status == 'All' ? null : _status,
          type: _propertyType == 'Any type' ? null : _propertyType,
          city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
          minPrice: minText.isEmpty ? null : double.tryParse(minText),
          maxPrice: maxText.isEmpty ? null : double.tryParse(maxText),
        ));

    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _status = 'All';
      _propertyType = 'Any type';
      _cityController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      // Shift up when keyboard appears
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 36),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle + title row ───────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter',
                    style: tt.headlineSmall?.copyWith(color: AppColors.primary)),
                TextButton(
                  onPressed: _reset,
                  child: Text('Reset all',
                      style: tt.labelMedium?.copyWith(color: AppColors.error)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Status ───────────────────────────────────
            Text('Listing type', style: tt.titleSmall?.copyWith(color: AppColors.primary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _statuses.map((s) {
                final sel = _status == s;
                return GestureDetector(
                  onTap: () => setState(() => _status = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.subtleBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(s,
                        style: tt.labelLarge?.copyWith(
                            color: sel ? Colors.white : AppColors.primary,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w500)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Property type ────────────────────────────
            Text('Property type', style: tt.titleSmall?.copyWith(color: AppColors.primary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _propertyTypes.map((t) {
                final sel = _propertyType == t;
                return GestureDetector(
                  onTap: () => setState(() => _propertyType = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.subtleBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(t,
                        style: tt.labelLarge?.copyWith(
                            color: sel ? Colors.white : AppColors.primary,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w500)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── City ─────────────────────────────────────
            Text('City', style: tt.titleSmall?.copyWith(color: AppColors.primary)),
            const SizedBox(height: 10),
            _FilterTextField(
              controller: _cityController,
              hint: 'e.g. Casablanca, Rabat...',
              icon: Icons.location_city_outlined,
            ),
            const SizedBox(height: 24),

            // ── Price range ──────────────────────────────
            Text('Price range (\$)',
                style: tt.titleSmall?.copyWith(color: AppColors.primary)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _FilterTextField(
                    controller: _minPriceController,
                    hint: 'Min',
                    icon: Icons.arrow_downward_rounded,
                    numeric: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('–',
                      style: tt.titleMedium?.copyWith(color: AppColors.textSecondary)),
                ),
                Expanded(
                  child: _FilterTextField(
                    controller: _maxPriceController,
                    hint: 'Max',
                    icon: Icons.arrow_upward_rounded,
                    numeric: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Apply button ─────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Apply filters',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable filter text field ─────────────────────────────────────────────────
class _FilterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool numeric;

  const _FilterTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.numeric = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.subtleBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: numeric ? TextInputType.number : TextInputType.text,
              inputFormatters: numeric
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              style: tt.bodyMedium?.copyWith(color: AppColors.primary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: tt.bodySmall?.copyWith(color: AppColors.textTertiary),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
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
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)
                      ],
                    ),
                    child: Text(property.type,
                        style: tt.labelLarge?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
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
                            Text(property.title,
                                style: tt.titleSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 13, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(property.location,
                                      overflow: TextOverflow.ellipsis,
                                      style: tt.bodySmall),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text('\$${_fmt(property.price)}',
                          style: tt.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                              letterSpacing: -0.5)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ...property.chips.take(3).map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _Chip(icon: c.icon, label: c.label),
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

  String _fmt(double p) {
    if (p >= 1000000) return '${(p / 1000000).toStringAsFixed(1)}M';
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(0)}K';
    return p.toStringAsFixed(0);
  }

  Widget _placeholder() => Container(
        height: 200,
        width: double.infinity,
        color: AppColors.subtleBackground,
        child: const Icon(Icons.home_outlined, size: 48, color: AppColors.textTertiary),
      );
}

// ── Chip ──────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.subtleBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(label, style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Icon Btn ──────────────────────────────────────────────────────────────────
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
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(555),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            if (badge)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                      color: AppColors.error, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      );
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────
class _BottomNav extends ConsumerWidget {
  const _BottomNav();

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.slow_motion_video_rounded, label: 'Reels'),
    (icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
    (icon: Icons.favorite_border_rounded, label: 'Favorites'),
    (icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(navIndexProvider);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4))
        ],
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
                        color: active ? AppColors.primary : Colors.transparent,
                        shape: BoxShape.circle,
                        boxShadow: active
                            ? [
                                BoxShadow(
                                    color: AppColors.primary.withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4))
                              ]
                            : [],
                      ),
                      child: Icon(item.icon,
                          size: 24,
                          color: active ? Colors.white : AppColors.textTertiary),
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