import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ==================== CORE BRAND ====================
  static const Color primary = Color(0xFF15203B);       // Midnight Navy
  static const Color primaryLight = Color(0xFF1A2847);  // Lighter shade for hover/states
  static const Color primaryDark = Color(0xFF0A0F1B);   // Deeper for pressed states

  static const Color secondary = Color(0xFF1A2847);     // Navy Light
  static const Color secondaryLight = Color(0xFF2A3858);

  static const Color accent = Color(0xFF000000);        // Light Beige
  static const Color accentLight = Color.fromARGB(255, 46, 49, 56);   // Softer beige

  // ==================== BACKGROUNDS ====================
  static const Color background = Color(0xFFFAFAFA);    // Off White
  static const Color surface = Color(0xFFFCFCFC);       // Surface color for cards/forms
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color subtleBackground = Color.fromARGB(27, 121, 121, 121); // Light Beige subtle bg
  static const Color glassOverlay = Color(0x70FFFFFF);

  // ==================== TEXT ====================
  static const Color textPrimary = Color(0xFF1F2937);   // Charcoal
  static const Color textSecondary = Color(0xFF4B5563); // Muted charcoal
  static const Color textTertiary = Color(0xFF7C8899);  // Light grey
  static const Color textDisabled = Color(0xFFC0C5CC);

  // ==================== SEMANTIC COLORS ====================
  // Kept functional but nudged toward the blue-steel family

  static const Color success = Color(0xFF2E8B6A);       // Teal-green (not pure green)
  static const Color successLight = Color(0xFF3DAF87);

  static const Color error = Color(0xFF1F2937);         // Charcoal neutral
  static const Color errorLight = Color(0xFF4B5563);
  static const Color warning = Color(0xFF2A3858);       // Navy Light
  static const Color warningLight = Color(0xFF3A4A68);

  static const Color info = Color(0xFF0F172A);          // Navy primary for info
  static const Color infoLight = Color(0xFF1A2847);

  // ==================== BORDERS ====================
  static const Color borderLight = Color(0xFFE8E8E8);   // Light grey border
  static const Color borderMedium = Color(0xFFD4D4D4);
  static const Color borderDark = Color(0xFFA8A8A8);

  // ==================== SPECIAL ====================
  static const Color shadow = Color(0x1A0F172A);        // Navy-tinted shadow
  static const Color overlay = Color(0x800F172A);       // Brand-tinted scrim
  static Color whiteGlass = const Color(0xFFFFFFFF).withOpacity(0.85);

  static const List<Color> primaryGradient = [
    Color(0xFF0A0F1B),  // primaryDark
    Color(0xFF0F172A),  // primary
  ];

  static const List<Color> accentGradient = [
    Color(0xFF0F172A),
    Color(0xFF1A2847),  // Navy accent
  ];

  // ==================== PROPERTY TYPE COLORS ====================
  // Luxury palette with deep navy accents
  static const Color apartment = Color(0xFF0F172A);  // primary navy
  static const Color house = Color(0xFF1A2847);      // navy light
  static const Color villa = Color(0xFF1A2847);      // navy light
  static const Color studio = Color(0xFF4B5563);     // muted charcoal
  static const Color land = Color(0xFF7C8899);       // light grey
  static const Color commercial = Color(0xFFF5F5DC); // beige

  // ==================== STATUS COLORS ====================
  static const Color statusActive = Color(0xFF2E8B6A);    // Keep teal for success
  static const Color statusPending = Color(0xFF2A3858);   // Navy Light for pending
  static const Color statusSold = Color(0xFF1F2937);      // Dark for sold
  static const Color statusBoosted = Color(0xFF1A5E7E);   // Deep Navy Blue for boosted

  // ==================== HELPERS ====================
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':   return statusActive;
      case 'PENDING':  return statusPending;
      case 'SOLD':     return statusSold;
      case 'BOOSTED':  return statusBoosted;
      default:         return textSecondary;
    }
  }
}