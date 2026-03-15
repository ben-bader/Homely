// lib/features/seller/screens/create_property_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/endpoints.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/media/providers/media_providers.dart';
import 'package:mobile/features/seller/providers/seller_providers.dart';

class CreatePropertyScreen extends ConsumerStatefulWidget {
  const CreatePropertyScreen({super.key});

  @override
  ConsumerState<CreatePropertyScreen> createState() =>
      _CreatePropertyScreenState();
}

class _CreatePropertyScreenState extends ConsumerState<CreatePropertyScreen>
    with SingleTickerProviderStateMixin {
  // ── Step state ─────────────────────────────────────────────────────────────
  int _currentStep = 0;
  late final PageController _pageController;
  late final AnimationController _progressController;

  // ── Data ───────────────────────────────────────────────────────────────────
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];

  String _title = '';
  String _description = '';
  String _location = '';
  double _price = 0;

  String _listingType = 'SELL';
  String _propertyType = 'HOUSE';
  final String _status = 'DRAFT';

  // Specs
  int bedrooms = 0;
  int bathrooms = 0;
  int floor = 0;
  bool hasElevator = false;
  bool hasGarage = false;
  bool hasPool = false;
  bool furnished = false;
  String businessType = '';
  double area = 0;
  bool constructible = false;

  bool _loading = false;

  static const _steps = ['Basic Info', 'Details', 'Photos'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 0.33,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _goTo(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    _progressController.animateTo(
      (step + 1) / _steps.length,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_currentStep < _steps.length - 1) {
      _goTo(_currentStep + 1);
    } else {
      _submitProperty();
    }
  }

  void _back() {
    if (_currentStep > 0) _goTo(_currentStep - 1);
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submitProperty() async {
  setState(() => _loading = true);

  try {
    final payload = {
      'title': _title,
      'description': _description,
      'location': _location,
      'price': _price,
      'listingType': _listingType,
      'propertyType': _propertyType,
      'status': _status,
      // Add the nested property type data
      ..._buildPropertyTypeData(),
    };

    final property = await ApiClient.post(
      Endpoints.createProperty,
      body: payload,
    );

    final propertyId = property['id'].toString();

    // ✅ await each upload and use uploadImage, not uploadVideo
    for (int i = 0; i < _images.length; i++) {
      await ref
          .read(propertyMediaProvider(propertyId).notifier)
          .uploadImage(file: _images[i], displayOrder: i);
    }

    // ✅ invalidate after uploads complete
    ref.invalidate(sellerListingsProvider);

    if (!mounted) return;
    _showSuccessAndPop();
  } catch (e) {
    debugPrint(e.toString());
    if (mounted) _showError(e.toString());
  } finally {
    // ✅ use finally so loading always resets, even if uploadImage throws
    if (mounted) setState(() => _loading = false);
  }
}

  Map<String, dynamic> _buildPropertyTypeData() {
    switch (_propertyType) {
      case 'APARTMENT':
        return {
          'apartment': {
            'bedrooms': bedrooms,
            'bathrooms': bathrooms,
            'floor': floor,
            'hasElevator': hasElevator,
          }
        };
      case 'HOUSE':
        return {
          'house': {
            'bedrooms': bedrooms,
            'bathrooms': bathrooms,
            'hasGarage': hasGarage,
          }
        };
      case 'VILLA':
        return {
          'villa': {
            'bedrooms': bedrooms,
            'bathrooms': bathrooms,
            'hasPool': hasPool,
          }
        };
      case 'STUDIO':
        return {
          'studio': {
            'furnished': furnished,
          }
        };
      case 'COMMERCIAL':
        return {
          'commercial': {
            'businessType': businessType,
            'areaSqm': area,
          }
        };
      case 'LAND':
        return {
          'land': {
            'areaSqm': area,
            'constructible': constructible,
          }
        };
      default:
        return {};
    }
  }

  void _showSuccessAndPop() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              'Property created!',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
    Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  // ── Pick images ────────────────────────────────────────────────────────────

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage();
    if (files.isNotEmpty) {
      setState(() => _images.addAll(files.map((e) => File(e.path))));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(tt),
      body: Column(
        children: [
          // ── Progress header ─────────────────────────────
          _buildProgressHeader(tt),

          // ── Page content ────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoPage(tt),
                _buildDetailsPage(tt),
                _buildPhotosPage(tt),
              ],
            ),
          ),

          // ── Bottom navigation bar ────────────────────────
          _buildBottomBar(tt),
        ],
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(TextTheme tt) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.subtleBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.accent,
            size: 16,
          ),
        ),
      ),
      title: Text(
        'New Listing',
        style: tt.titleLarge?.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          fontSize: 22,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Progress header ────────────────────────────────────────────────────────
  Widget _buildProgressHeader(TextTheme tt) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        children: [
          // Step indicators
          Row(
            children: List.generate(_steps.length, (i) {
              final isActive = i == _currentStep;
              final isDone = i < _currentStep;
              return Expanded(
                child: GestureDetector(
                  onTap: () => i < _currentStep ? _goTo(i) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.only(
                      right: i < _steps.length - 1 ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : isDone
                          ? AppColors.primary.withOpacity(0.12)
                          : AppColors.subtleBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white.withOpacity(0.25)
                                : isDone
                                ? AppColors.primary
                                : AppColors.borderMedium,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  )
                                : Text(
                                    '${i + 1}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isActive
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          // ← add this
                          child: Text(
                            _steps[i],
                            overflow: TextOverflow.ellipsis, // ← and this
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: isActive || isDone
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isActive
                                  ? Colors.white
                                  : isDone
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          // Animated progress bar
          AnimatedBuilder(
            animation: _progressController,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progressController.value,
                backgroundColor: AppColors.subtleBackground,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar(TextTheme tt) {
    final isLast = _currentStep == _steps.length - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _back,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.borderMedium,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.outfit(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _loading ? null : _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLast ? 'Create Listing' : 'Continue',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        if (!isLast) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ] else ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 1 — Basic Info
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBasicInfoPage(TextTheme tt) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Property Title'),
          _field(
            hint: 'e.g. Modern 3BR Apartment in Casablanca',
            icon: Icons.title_rounded,
            onChanged: (v) => _title = v,
          ),

          _sectionLabel('Location / Address'),
          _field(
            hint: 'e.g. 45 Palm Street, Casablanca',
            icon: Icons.location_on_outlined,
            onChanged: (v) => _location = v,
          ),

          _sectionLabel('Price'),
          _field(
            hint: '0.00',
            icon: Icons.attach_money_rounded,
            numeric: true,
            prefix: Text(
              'USD ',
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            onChanged: (v) => _price = double.tryParse(v) ?? 0,
          ),

          _sectionLabel('Listing Type'),
          _chipSelector(
            options: ['SELL', 'RENT'],
            selected: _listingType,
            onSelect: (v) => setState(() => _listingType = v),
            labels: {'SELL': 'For Sale', 'RENT': 'For Rent'},
          ),

          _sectionLabel('Property Type'),
          _chipGrid(
            options: [
              'HOUSE',
              'APARTMENT',
              'VILLA',
              'STUDIO',
              'COMMERCIAL',
              'LAND',
            ],
            selected: _propertyType,
            onSelect: (v) => setState(() => _propertyType = v),
            icons: {
              'HOUSE': Icons.house_outlined,
              'APARTMENT': Icons.apartment_outlined,
              'VILLA': Icons.villa_outlined,
              'STUDIO': Icons.chair_outlined,
              'COMMERCIAL': Icons.business_outlined,
              'LAND': Icons.landscape_outlined,
            },
          ),

          _sectionLabel('Description'),
          _field(
            hint: 'Describe the property, its features and surroundings...',
            icon: Icons.description_outlined,
            maxLines: 4,
            onChanged: (v) => _description = v,
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 2 — Details
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDetailsPage(TextTheme tt) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type header badge
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _propertyIconData(_propertyType),
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _propertyType[0] + _propertyType.substring(1).toLowerCase(),
                  style: GoogleFonts.outfit(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Details',
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          _buildSpecFields(tt),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  IconData _propertyIconData(String type) {
    switch (type) {
      case 'HOUSE':
        return Icons.house_outlined;
      case 'APARTMENT':
        return Icons.apartment_outlined;
      case 'VILLA':
        return Icons.villa_outlined;
      case 'STUDIO':
        return Icons.chair_outlined;
      case 'COMMERCIAL':
        return Icons.business_outlined;
      case 'LAND':
        return Icons.landscape_outlined;
      default:
        return Icons.home_outlined;
    }
  }

  Widget _buildSpecFields(TextTheme tt) {
    switch (_propertyType) {
      case 'APARTMENT':
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _counterField(
                    'Bedrooms',
                    Icons.bed_outlined,
                    bedrooms,
                    (v) => setState(() => bedrooms = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _counterField(
                    'Bathrooms',
                    Icons.bathtub_outlined,
                    bathrooms,
                    (v) => setState(() => bathrooms = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _field(
              hint: '0',
              icon: Icons.layers_outlined,
              label: 'Floor Number',
              numeric: true,
              onChanged: (v) => floor = int.tryParse(v) ?? 0,
            ),
            _toggleRow(
              'Has Elevator',
              Icons.elevator_outlined,
              hasElevator,
              (v) => setState(() => hasElevator = v),
            ),
          ],
        );

      case 'HOUSE':
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _counterField(
                    'Bedrooms',
                    Icons.bed_outlined,
                    bedrooms,
                    (v) => setState(() => bedrooms = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _counterField(
                    'Bathrooms',
                    Icons.bathtub_outlined,
                    bathrooms,
                    (v) => setState(() => bathrooms = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _toggleRow(
              'Has Garage',
              Icons.garage_outlined,
              hasGarage,
              (v) => setState(() => hasGarage = v),
            ),
          ],
        );

      case 'VILLA':
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _counterField(
                    'Bedrooms',
                    Icons.bed_outlined,
                    bedrooms,
                    (v) => setState(() => bedrooms = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _counterField(
                    'Bathrooms',
                    Icons.bathtub_outlined,
                    bathrooms,
                    (v) => setState(() => bathrooms = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _toggleRow(
              'Has Pool',
              Icons.pool_outlined,
              hasPool,
              (v) => setState(() => hasPool = v),
            ),
          ],
        );

      case 'STUDIO':
        return _toggleRow(
          'Furnished',
          Icons.chair_outlined,
          furnished,
          (v) => setState(() => furnished = v),
        );

      case 'COMMERCIAL':
        return Column(
          children: [
            _field(
              hint: 'e.g. Restaurant, Office, Retail...',
              icon: Icons.business_center_outlined,
              label: 'Business Type',
              onChanged: (v) => businessType = v,
            ),
            _field(
              hint: '0',
              icon: Icons.square_foot_outlined,
              label: 'Area (m²)',
              numeric: true,
              onChanged: (v) => area = double.tryParse(v) ?? 0,
            ),
          ],
        );

      case 'LAND':
        return Column(
          children: [
            _field(
              hint: '0',
              icon: Icons.square_foot_outlined,
              label: 'Area (m²)',
              numeric: true,
              onChanged: (v) => area = double.tryParse(v) ?? 0,
            ),
            _toggleRow(
              'Constructible',
              Icons.construction_outlined,
              constructible,
              (v) => setState(() => constructible = v),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 3 — Photos
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPhotosPage(TextTheme tt) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload button
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.25),
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 28,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Tap to add photos',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG • Multiple selection supported',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_images.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_images.length} photo${_images.length > 1 ? 's' : ''}',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _images.clear()),
                  child: Text(
                    'Remove all',
                    style: GoogleFonts.outfit(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _images.length,
              itemBuilder: (_, i) => _imageThumb(i),
            ),
          ] else ...[
            const SizedBox(height: 24),
            // Tip card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.subtleBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pro tip',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Listings with 5+ photos get 3× more views',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _imageThumb(int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(_images[index], fit: BoxFit.cover),
        ),
        if (index == 0)
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Cover',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _field({
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
    String? label,
    int maxLines = 1,
    bool numeric = false,
    Widget? prefix,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: label != null ? 0 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) _sectionLabel(label),
          Container(
            decoration: BoxDecoration(
              color: AppColors.subtleBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              onChanged: onChanged,
              maxLines: maxLines,
              keyboardType: numeric
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              inputFormatters: numeric
                  ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
                  : null,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.accent,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.outfit(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 8),
                  child: Icon(icon, size: 18, color: AppColors.textSecondary),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0),
                prefix: prefix,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipSelector({
    required List<String> options,
    required String selected,
    required Function(String) onSelect,
    Map<String, String>? labels,
  }) {
    return Row(
      children: options.map((o) {
        final isSelected = selected == o;
        final label = labels?[o] ?? o;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(o),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: o != options.last ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.subtleBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.accent,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _chipGrid({
    required List<String> options,
    required String selected,
    required Function(String) onSelect,
    Map<String, IconData>? icons,
  }) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.0,
      children: options.map((o) {
        final isSelected = selected == o;
        final label = o[0] + o.substring(1).toLowerCase();
        return GestureDetector(
          onTap: () => onSelect(o),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.subtleBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icons?[o] != null) ...[
                  Icon(
                    icons![o],
                    size: 14,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _counterField(
    String label,
    IconData icon,
    int value,
    Function(int) onChange,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.subtleBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: value > 0 ? () => onChange(value - 1) : null,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: value > 0
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.remove_rounded,
                    size: 16,
                    color: value > 0
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
              Text(
                '$value',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
              GestureDetector(
                onTap: () => onChange(value + 1),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toggleRow(
    String label,
    IconData icon,
    bool value,
    Function(bool) onChange,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: value
            ? AppColors.primary.withOpacity(0.06)
            : AppColors.subtleBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: value ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: value ? AppColors.primary : AppColors.accent,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChange,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
