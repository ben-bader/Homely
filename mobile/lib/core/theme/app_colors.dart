import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ==================== CORE BRAND ====================
  static const Color primary = Color(0xFF3D5A80);       // Steel blue — unchanged
  static const Color primaryLight = Color(0xFF5B7FA6);  // Lighter tint for hover/states
  static const Color primaryDark = Color(0xFF2C4260);   // Deeper for pressed states

  static const Color accent = Color(0xFF1C2B3A);        // Near-black with blue undertone
  static const Color accentLight = Color(0xFF2E4057);   // Softer dark blue-grey

  // ==================== BACKGROUNDS ====================
  static const Color background = Color(0xFFFFFFFF);    // Slightly blue-tinted off-white
  static const Color surface = Color(0xFFF8FAFC);       // Surface color for cards/forms
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color subtleBackground = Color(0xFFEEF2F7); // Blue-tinted subtle bg
  static const Color glassOverlay = Color(0x70FFFFFF);

  // ==================== TEXT ====================
  static const Color textPrimary = Color(0xFF1C2B3A);   // Deep blue-black
  static const Color textSecondary = Color(0xFF6B7E92); // Blue-grey mid
  static const Color textTertiary = Color(0xFFAAB8C6);  // Light blue-grey
  static const Color textDisabled = Color(0xFFCDD5DE);

  // ==================== SEMANTIC COLORS ====================
  static const Color success = Color(0xFF2E8B6A);
  static const Color successLight = Color(0xFF3DAF87);

  static const Color error = Color(0xFFCF4A3C);         // Muted red, less aggressive
  static const Color errorLight = Color(0xFFE07060);

  static const Color warning = Color(0xFFD4872A);       // Warm amber
  static const Color warningLight = Color(0xFFE8A84A);

  static const Color info = Color(0xFF3D5A80);          // Reuse primary for info
  static const Color infoLight = Color(0xFF5B7FA6);

  // ==================== BORDERS ====================
  static const Color borderLight = Color(0xFFE2E8EF);   // Blue-tinted light border
  static const Color borderMedium = Color(0xFFC5D0DC);
  static const Color borderDark = Color(0xFFA8B8C8);

  // ==================== SPECIAL ====================
  static const Color shadow = Color(0x1A2C4260);        // Blue-tinted shadow
  static const Color overlay = Color(0x803D5A80);       // Brand-tinted scrim
  static Color whiteGlass = const Color(0xFFFFFFFF).withOpacity(0.85);

  static const List<Color> primaryGradient = [
    Color(0xFF2C4260),  // primaryDark
    Color(0xFF3D5A80),  // primary
  ];

  static const List<Color> accentGradient = [
    Color(0xFF3D5A80),
    Color(0xFF5B7FA6),
  ];

  // ==================== PROPERTY TYPE COLORS ====================
  // All pulled from the same analogous blue/teal/slate family
  static const Color apartment = Color(0xFF3D5A80);  // primary blue
  static const Color house = Color(0xFF2E8B6A);      // teal green
  static const Color villa = Color(0xFF5B4E8A);      // muted blue-purple
  static const Color studio = Color(0xFF7A9EB5);     // pale steel blue
  static const Color land = Color(0xFF8A9BAD);       // warm blue-grey
  static const Color commercial = Color(0xFFCF4A3C); // muted red

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
