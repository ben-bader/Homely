import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ================= CORE BRAND =================
  static const Color primary = Color(0xFF0F172A);       // Deep navy
  static const Color primaryLight = Color(0xFF1E293B);  // Hover
  static const Color primaryDark = Color(0xFF020617);   // Pressed

  static const Color accent = Color(0xFF111827);        // Neutral dark
  static const Color accentLight = Color(0xFF374151);

  // ================= BACKGROUNDS =================
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color subtleBackground = Color(0xFFF1F5F9);
  static const Color glassOverlay = Color(0x70FFFFFF);

  // ================= TEXT =================
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);

  // ================= SEMANTIC COLORS =================
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFF22C55E);

  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFEF4444);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);

  static const Color info = Color(0xFF0F172A);
  static const Color infoLight = Color(0xFF334155);

  // ================= BORDERS =================
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  static const Color borderDark = Color(0xFF94A3B8);

  // ================= SPECIAL =================
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x800F172A);

  static Color whiteGlass = const Color(0xFFFFFFFF).withOpacity(0.85);

  static const List<Color> primaryGradient = [
    Color(0xFF020617),
    Color(0xFF0F172A),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF0F172A),
    Color(0xFF1E293B),
  ];

  // ================= PROPERTY TYPES =================
  // Neutral palette instead of colorful blues

  static const Color apartment = Color(0xFF334155);
  static const Color house = Color(0xFF475569);
  static const Color villa = Color(0xFF1F2937);
  static const Color studio = Color(0xFF64748B);
  static const Color land = Color(0xFF94A3B8);
  static const Color commercial = Color(0xFFDC2626);

  // ================= STATUS COLORS =================
  static const Color statusActive = Color(0xFF16A34A);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusSold = Color(0xFF0F172A);
  static const Color statusBoosted = Color(0xFF334155);

  // ================= HELPERS =================

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
