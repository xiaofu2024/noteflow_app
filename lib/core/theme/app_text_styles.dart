import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Display Text Styles
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );
  
  static TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );
  
  static TextStyle displaySmall = GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );
  
  // Headline Text Styles
  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );
  
  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );
  
  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );
  
  // Title Text Styles
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );
  
  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.50,
  );
  
  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  // Label Text Styles
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );
  
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );
  
  // Body Text Styles
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.50,
  );
  
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );
  
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );
  
  // Custom App-specific Text Styles
  static TextStyle noteTitle = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.33,
  );
  
  static TextStyle notePreview = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );
  
  static TextStyle tagText = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );
  
  static TextStyle buttonText = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  static TextStyle appBarTitle = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.20,
  );
  
  static TextStyle tabLabel = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  // Helper methods to apply colors
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  // Theme-aware text styles
  static TextStyle getDisplayLarge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return displayLarge.copyWith(
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
  }
  
  static TextStyle getBodyLarge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return bodyLarge.copyWith(
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
  }
  
  static TextStyle getBodyMedium(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return bodyMedium.copyWith(
      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
    );
  }
  
  static TextStyle getNoteTitle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return noteTitle.copyWith(
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
  }
  
  static TextStyle getNotePreview(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return notePreview.copyWith(
      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
    );
  }
}