import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color primary = Color(0xFF151515);

  static const Color accent = Color(0xFF1C1C1C);
  static const Color accentLight = Color(0xBF1F1F1F);

  static const Color background = Color(0xFFEBEBEB);

  static const Color cardBackground = Color(0xFFFFFFFF);

  static const Color subtleBackground = Color(0xFFF5F5F5);

  static const Color glassOverlay = Color(0xFFFEFEFE);

  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);

  static const Color textTertiary = Color(0xFFBDC3C7);

  static const Color textDisabled = Color(0xFFCCD1D3);

  static const Color success = Color(0xFF27AE60);
  static const Color successLight = Color(0xFF2ECC71);

  /// Error - Red
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFEC7063);

  /// Warning - Orange
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFF1C40F);

  /// Info - Blue
  static const Color info = Color(0xFF3498DB);
  static const Color infoLight = Color(0xFF5DADE2);

  // ==================== BORDER COLORS ====================
  /// Light border - Very subtle
  static const Color borderLight = Color(0xFFE8E8E8);

  /// Medium border
  static const Color borderMedium = Color(0xFFD0D0D0);

  /// Dark border
  static const Color borderDark = Color(0xFFBDBDBD);

  // ==================== SPECIAL COLORS ====================
  /// Shadow color
  static const Color shadow = Color(0x1A000000);

  /// Overlay/Scrim
  static const Color overlay = Color(0x80000000);

  /// White with opacity for glassmorphism
  static Color whiteGlass = Colors.white.withOpacity(0.85);

  /// Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF2C3E50),
    Color(0xFF3498DB),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF3498DB),
    Color(0xFF2980B9),
  ];

  // ==================== PROPERTY TYPE COLORS ====================
  /// For different property categories
  static const Color apartment = Color(0xFF3498DB);
  static const Color house = Color(0xFF27AE60);
  static const Color villa = Color(0xFF9B59B6);
  static const Color studio = Color(0xFFE67E22);
  static const Color land = Color(0xFF95A5A6);
  static const Color commercial = Color(0xFFE74C3C);

  // ==================== STATUS COLORS ====================
  /// Property/Listing status colors
  static const Color statusActive = Color(0xFF27AE60);
  static const Color statusPending = Color(0xFFF39C12);
  static const Color statusSold = Color(0xFFE74C3C);
  static const Color statusBoosted = Color(0xFF9B59B6);

  // ==================== HELPER METHODS ====================

  /// Get color with custom opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Get property type color by name
 

  /// Get status color by status
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
