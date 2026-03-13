import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ==================== CORE BRAND ====================
  static const Color primary = Color(
    0xFF1C2B3A,
  ); // ← Main app color (Listings icon color)
  static const Color primaryLight = Color(0xFF2E4057); // Lighter tint
  static const Color primaryDark = Color(
    0xFF111D27,
  ); // Deeper for pressed states

  static const Color accent = Color(0xFF1C2B3A); // Same as primary
  static const Color accentLight = Color(0xFF2E4057); // Softer shade

  // ==================== BACKGROUNDS ====================
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color subtleBackground = Color(0xFFEEF2F7);
  static const Color glassOverlay = Color(0x70FFFFFF);

  // ==================== TEXT ====================
  static const Color textPrimary = Color(0xFF1C2B3A);
  static const Color textSecondary = Color(0xFF6B7E92);
  static const Color textTertiary = Color(0xFFAAB8C6);
  static const Color textDisabled = Color(0xFFCDD5DE);

  // ==================== SEMANTIC COLORS ====================
  static const Color success = Color(0xFF2E8B6A);
  static const Color successLight = Color(0xFF3DAF87);

  static const Color error = Color(0xFFCF4A3C);
  static const Color errorLight = Color(0xFFE07060);

  static const Color warning = Color(0xFFD4872A);
  static const Color warningLight = Color(0xFFE8A84A);

  static const Color info = Color(0xFF1C2B3A);
  static const Color infoLight = Color(0xFF2E4057);

  // ==================== BORDERS ====================
  static const Color borderLight = Color(0xFFE2E8EF);
  static const Color borderMedium = Color(0xFFC5D0DC);
  static const Color borderDark = Color(0xFFA8B8C8);

  // ==================== SPECIAL ====================
  static const Color shadow = Color(0x1A1C2B3A);
  static const Color overlay = Color(0x801C2B3A);
  static Color whiteGlass = const Color(0xFFFFFFFF).withOpacity(0.85);

  static const List<Color> primaryGradient = [
    Color(0xFF111D27), // primaryDark
    Color(0xFF1C2B3A), // primary
  ];

  static const List<Color> accentGradient = [
    Color(0xFF1C2B3A),
    Color(0xFF2E4057),
  ];

  // ==================== PROPERTY TYPE COLORS ====================
  static const Color apartment = Color(0xFF1C2B3A);
  static const Color house = Color(0xFF2E8B6A);
  static const Color villa = Color(0xFF5B4E8A);
  static const Color studio = Color(0xFF7A9EB5);
  static const Color land = Color(0xFF8A9BAD);
  static const Color commercial = Color(0xFFCF4A3C);

  // ==================== STATUS COLORS ====================
  static const Color statusActive = Color(0xFF2E8B6A);
  static const Color statusPending = Color(0xFFD4872A);
  static const Color statusSold = Color(0xFFCF4A3C);
  static const Color statusBoosted = Color(0xFF5B4E8A);

  // ==================== HELPERS ====================
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return statusActive;
      case 'PENDING':
        return statusPending;
      case 'SOLD':
        return statusSold;
      case 'BOOSTED':
        return statusBoosted;
      default:
        return textSecondary;
    }
  }
}
