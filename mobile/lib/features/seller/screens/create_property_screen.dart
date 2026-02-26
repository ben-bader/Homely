// create_property_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class _CreatePropertyScreenState extends ConsumerState<CreatePropertyScreen> {
  int _currentStep = 0;
  final ImagePicker _picker = ImagePicker();

  List<File> _images = [];

  // Form data
  String _title = '';
  String _description = '';
  String _location = '';
  double _price = 0;

  String _listingType = "BUY";
  String _propertyType = "HOUSE";
  String _status = "ACTIVE";

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

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          "Create Property",
          style: tt.titleLarge?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.accent),
      ),

      body: Theme(
        // ⭐ Custom Stepper Theme
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.accent,
          ),
        ),

        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,

          onStepContinue: _nextStep,
          onStepCancel: _prevStep,

          controlsBuilder: (context, _) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(child: _primaryButton(_currentStep == 2 ? "Create Property" : "Continue")),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    Expanded(child: _secondaryButton("Back", _prevStep)),
                ],
              ),
            );
          },

          steps: [
            Step(
              title: _stepTitle("Basic Info"),
              isActive: _currentStep >= 0,
              content: _basicInfoStep(),
            ),

            Step(
              title: _stepTitle("Details"),
              isActive: _currentStep >= 1,
              content: _detailsStep(),
            ),

            Step(
              title: _stepTitle("Media"),
              isActive: _currentStep >= 2,
              content: _mediaStep(),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // STEPPER UI
  // =========================================================

  Widget _stepTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.accent,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }

  // =========================================================
  // BASIC STEP
  // =========================================================

  Widget _basicInfoStep() {
    return Column(
      children: [
        _input("Title", (v) => _title = v),
        _input("Location", (v) => _location = v),
        _input("Price", (v) => _price = double.tryParse(v) ?? 0,
            keyboard: TextInputType.number),

        const SizedBox(height: 10),

        _dropdown("Listing Type", _listingType, ["BUY", "RENT"],
            (v) => setState(() => _listingType = v!)),

        _dropdown(
            "Property Type",
            _propertyType,
            ["HOUSE", "APARTMENT", "VILLA", "STUDIO", "COMMERCIAL", "LAND"],
            (v) => setState(() => _propertyType = v!)),

        _input("Description", (v) => _description = v, maxLines: 4),
      ],
    );
  }

  // =========================================================
  // DETAILS STEP
  // =========================================================

  Widget _detailsStep() {
    switch (_propertyType) {
      case "APARTMENT":
        return _apartmentSpecs();

      case "HOUSE":
        return _houseSpecs();

      case "VILLA":
        return _villaSpecs();

      case "STUDIO":
        return _studioSpecs();

      case "COMMERCIAL":
        return _commercialSpecs();

      case "LAND":
        return _landSpecs();

      default:
        return const SizedBox();
    }
  }

  Widget _apartmentSpecs() => Column(
        children: [
          _input("Bedrooms", (v) => bedrooms = int.tryParse(v) ?? 0,
              keyboard: TextInputType.number),
          _input("Bathrooms", (v) => bathrooms = int.tryParse(v) ?? 0,
              keyboard: TextInputType.number),
          _input("Floor", (v) => floor = int.tryParse(v) ?? 0,
              keyboard: TextInputType.number),
          _checkbox("Has Elevator", hasElevator,
              (v) => setState(() => hasElevator = v!)),
        ],
      );

  Widget _houseSpecs() => Column(
        children: [
          _input("Bedrooms", (v) => bedrooms = int.tryParse(v) ?? 0,
              keyboard: TextInputType.number),
          _input("Bathrooms", (v) => bathrooms = int.tryParse(v) ?? 0,
              keyboard: TextInputType.number),
          _checkbox("Has Garage", hasGarage,
              (v) => setState(() => hasGarage = v!)),
        ],
      );

  Widget _villaSpecs() => Column(
        children: [
          _input("Bedrooms", (v) => bedrooms = int.tryParse(v) ?? 0,
              keyboard: TextInputType.number),
          _input("Bathrooms", (v) => bathrooms = int.tryParse(v) ?? 0,
              keyboard: TextInputType.number),
          _checkbox("Has Pool", hasPool,
              (v) => setState(() => hasPool = v!)),
        ],
      );

  Widget _studioSpecs() =>
      _checkbox("Furnished", furnished, (v) => setState(() => furnished = v!));

  Widget _commercialSpecs() => Column(
        children: [
          _input("Business Type", (v) => businessType = v),
          _input("Area (sqm)", (v) => area = double.tryParse(v) ?? 0,
              keyboard: TextInputType.number),
        ],
      );

  Widget _landSpecs() => Column(
        children: [
          _input("Area (sqm)", (v) => area = double.tryParse(v) ?? 0,
              keyboard: TextInputType.number),
          _checkbox("Constructible", constructible,
              (v) => setState(() => constructible = v!)),
        ],
      );

  // =========================================================
  // MEDIA STEP
  // =========================================================

  Widget _mediaStep() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.subtleBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderMedium),
            ),
            child: Column(
              children: const [
                Icon(Icons.image_outlined,
                    size: 60, color: AppColors.textSecondary),
                SizedBox(height: 12),
                Text("Tap to upload images"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // INPUT WIDGETS
  // =========================================================

  Widget _input(String label, Function(String) onChanged,
      {TextInputType keyboard = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        keyboardType: keyboard,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.subtleBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.subtleBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        items:
            items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _checkbox(String label, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      value: value,
      title: Text(label),
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }

  // =========================================================
  // BUTTONS
  // =========================================================

  Widget _primaryButton(String text) {
    return ElevatedButton(
      onPressed: _loading
          ? null
          : _currentStep == 2
              ? _submitProperty
              : _nextStep,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
      child: _loading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(text,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _secondaryButton(String text, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w600)),
    );
  }

  // =========================================================
  // LOGIC
  // =========================================================

  void _nextStep() {
    if (_currentStep < 2) setState(() => _currentStep++);
    else _submitProperty();
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage();
    setState(() => _images.addAll(files.map((e) => File(e.path))));
  }

  Future<void> _submitProperty() async {
    try {
      setState(() => _loading = true);

      final payload = {
        "title": _title,
        "description": _description,
        "location": _location,
        "price": _price,
        "listingType": _listingType,
        "propertyType": _propertyType,
        "status": _status,
        "bedrooms": bedrooms,
        "bathrooms": bathrooms,
        "floor": floor,
        "hasElevator": hasElevator,
        "hasGarage": hasGarage,
        "hasPool": hasPool,
        "furnished": furnished,
        "businessType": businessType,
        "areaSqm": area,
        "constructible": constructible,
      };

      final property = await ApiClient.post(
        Endpoints.createProperty,
        body: payload,
      );

      final propertyId = property['id'];

      for (int i = 0; i < _images.length; i++) {
        ref
            .read(propertyMediaProvider(propertyId.toString()).notifier)
            .uploadVideo(file: _images[i], displayOrder: i);
      }

      ref.invalidate(sellerListingsProvider);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() => _loading = false);
  }
}