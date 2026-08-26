import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.background,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      fontFamily: GoogleFonts.outfit().fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme:
            const IconThemeData(color: AppColors.textPrimary, size: 24),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.borderMedium, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.borderMedium, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: GoogleFonts.outfit(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w400),
        labelStyle: GoogleFonts.outfit(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.outfit(
              fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent, width: 2),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5),
        ),
      ),
      iconTheme:
          const IconThemeData(color: AppColors.accent, size: 24),
      dividerTheme: const DividerThemeData(
          color: AppColors.borderLight, thickness: 1, space: 1),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.outfit(
            fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.outfit(
            fontSize: 12, fontWeight: FontWeight.w400),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.subtleBackground,
        deleteIconColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardBackground,
        elevation: 8,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600),
        contentTextStyle: GoogleFonts.outfit(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w400),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w400),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
            fontSize: 57,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -2),
        displayMedium: GoogleFonts.outfit(
            fontSize: 45,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -1.5),
        displaySmall: GoogleFonts.outfit(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -1),
        headlineLarge: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5),
        headlineMedium: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3),
        headlineSmall: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary),
        titleLarge: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        titleMedium: GoogleFonts.outfit(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary),
        titleSmall: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            height: 1.5),
        bodyMedium: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.5),
        bodySmall: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.5),
        labelLarge: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary),
        labelMedium: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary),
        labelSmall: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.borderLight,
        circularTrackColor: AppColors.borderLight,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? Colors.white
                : AppColors.borderMedium),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.accent
                : AppColors.borderLight),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.accent
                : Colors.transparent),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.accent
                : AppColors.borderMedium),
      ),
    );
  }
}
