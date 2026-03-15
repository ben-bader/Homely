import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/features/media/providers/media_providers.dart';
import 'package:mobile/features/media/widgets/property_media_gallery.dart';
import 'package:mobile/features/property/models/property.dart';
import 'package:mobile/features/property/providers/property_providers.dart';
import 'package:mobile/features/seller/providers/seller_providers.dart'
    hide sellerListingsProvider;
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/endpoints.dart';
import 'package:mobile/features/tours/screens/video_player_screen.dart';

class EditPropertyScreen extends ConsumerStatefulWidget {
  final Property property;
  const EditPropertyScreen({super.key, required this.property});

  @override
  ConsumerState<EditPropertyScreen> createState() =>
      _EditPropertyScreenState();
}

class _EditPropertyScreenState extends ConsumerState<EditPropertyScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _priceCtrl;
  late ListingType _listingType;
  late PropertyStatus _status;

  final ImagePicker _picker = ImagePicker();
  bool _loading = false;

  // ✅ Track whether controllers have been seeded from property data
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _titleCtrl = TextEditingController(text: p.title);
    _descriptionCtrl = TextEditingController(text: p.description);
    _locationCtrl = TextEditingController(text: p.location);
    _priceCtrl = TextEditingController(text: p.price.toString());
    _listingType = p.listingType;
    _status = p.status;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _saveChanges() async {
    if (_titleCtrl.text.isEmpty || _locationCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final payload = {
        'title': _titleCtrl.text,
        'description': _descriptionCtrl.text,
        'address': _locationCtrl.text,
        'price': double.tryParse(_priceCtrl.text) ?? 0,
        'currency': 'USD',
        'listingType': _listingType.toJson(),
        'status': _status.toJson(),
      };

      await ApiClient.put(
        Endpoints.updateProperty(widget.property.id),
        body: payload,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property updated successfully'),
          backgroundColor: AppColors.primary,
        ),
      );

      ref.invalidate(propertyDetailProvider(widget.property.id));
      ref.invalidate(sellerListingsProvider);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Media ─────────────────────────────────────────────────────────────────

  Future<void> _pickImages() async {
    try {
      final files = await _picker.pickMultiImage();
      if (files == null || files.isEmpty) return;

      final propertyId = widget.property.id;
      final startIndex = ref.read(propertyMediaCountProvider(propertyId));

      for (int i = 0; i < files.length; i++) {
        await ref
            .read(propertyMediaProvider(propertyId).notifier)
            .uploadImage(
              file: File(files[i].path),
              displayOrder: startIndex + i,
            );
      }

      ref.invalidate(propertyMediaProvider(propertyId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Images uploaded')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final picked = await _picker.pickVideo(source: ImageSource.gallery);
      if (picked == null) return;

      final propertyId = widget.property.id;
      final displayOrder = ref.read(propertyMediaCountProvider(propertyId));

      await ref
          .read(propertyMediaProvider(propertyId).notifier)
          .uploadVideo(
            file: File(picked.path),
            displayOrder: displayOrder,
          );

      ref.invalidate(propertyMediaProvider(propertyId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final p = widget.property;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Edit Property',
          style: tt.titleLarge?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.accent),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero image ─────────────────────────────
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  child: SizedBox(
                    height: h * 0.25,
                    width: double.infinity,
                    child: p.images.isNotEmpty
                        ? Image.network(
                            p.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _heroPlaceholder(),
                          )
                        : _heroPlaceholder(),
                  ),
                ),

                // ── Form ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(tt, 'Title'),
                      _textField(
                        controller: _titleCtrl,
                        hint: 'Property title',
                      ),
                      const SizedBox(height: 20),

                      _label(tt, 'Price (\$)'),
                      _textField(
                        controller: _priceCtrl,
                        hint: 'Enter price',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),

                      _label(tt, 'Location'),
                      _textField(
                        controller: _locationCtrl,
                        hint: 'Enter location',
                      ),
                      const SizedBox(height: 20),

                      _label(tt, 'Description'),
                      _textField(
                        controller: _descriptionCtrl,
                        hint: 'Enter property description',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),

                      // ── Media ────────────────────────────
                      _label(tt, 'Media'),
                      const SizedBox(height: 12),
                      PropertyMediaGallery(
                        propertyId: p.id,
                        editable: true,
                        onVideoTap: (video) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerScreen(
                              video: video,
                              propertyId: p.id,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickImages,
                              icon: const Icon(
                                  Icons.photo_library_outlined),
                              label: const Text('Add Photos'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickVideo,
                              icon:
                                  const Icon(Icons.videocam_outlined),
                              label: const Text('Add Video'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Listing type ─────────────────────
                      _label(tt, 'Listing Type'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _choiceBtn(
                            tt,
                            label: 'Sell',
                            selected: _listingType == ListingType.sell,
                            onTap: () => setState(
                                () => _listingType = ListingType.sell),
                          ),
                          const SizedBox(width: 12),
                          _choiceBtn(
                            tt,
                            label: 'Rent',
                            selected: _listingType == ListingType.rent,
                            onTap: () => setState(
                                () => _listingType = ListingType.rent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Status ───────────────────────────
                      _label(tt, 'Status'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _choiceBtn(
                            tt,
                            label: 'Draft',
                            selected: _status == PropertyStatus.draft,
                            onTap: () => setState(
                                () => _status = PropertyStatus.draft),
                          ),
                          const SizedBox(width: 12),
                          _choiceBtn(
                            tt,
                            label: 'Available',
                            selected:
                                _status == PropertyStatus.available,
                            onTap: () => setState(
                                () => _status = PropertyStatus.available),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom save button ─────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(
                    color: Colors.black.withOpacity(0.08),
                    width: 1,
                  ),
                ),
              ),
              child: ElevatedButton(
                onPressed: _loading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _heroPlaceholder() => Container(
        color: const Color(0xFFF0E9E3),
        child: const Icon(
          Icons.home_outlined,
          size: 48,
          color: AppColors.textTertiary,
        ),
      );

  Widget _label(TextTheme tt, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: tt.labelLarge?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
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
          filled: true,
          fillColor: AppColors.subtleBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      );

  Widget _choiceBtn(
    TextTheme tt, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary
                  : AppColors.subtleBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                label,
                style: tt.labelLarge?.copyWith(
                  color: selected ? Colors.white : AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
}