import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF42A5F5);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryDark = Color(0xFFE65100);
  static const Color secondaryLight = Color(0xFFFFCC02);
  
  // Accent Colors
  static const Color accent = Color(0xFF4CAF50);
  static const Color accentDark = Color(0xFF2E7D32);
  static const Color accentLight = Color(0xFF81C784);
  
  // Neutral Colors - Light Theme
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F5F5);
  
  // Neutral Colors - Dark Theme
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);
  
  // Text Colors - Light Theme
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textTertiaryLight = Color(0xFFBDBDBD);
  
  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFE0E0E0);
  static const Color textTertiaryDark = Color(0xFF9E9E9E);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);
  
  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
  
  // Note Category Colors
  static const List<Color> noteCategoryColors = [
    Color(0xFFFFCDD2), // Red
    Color(0xFFF8BBD9), // Pink
    Color(0xFFE1BEE7), // Purple
    Color(0xFFE91E63), // Red
    Color(0xFF3F51B5), // Dark Blue
    Color(0xFFBBDEFB), // Blue
    Color(0xFFB3E5FC), // Light Blue
    Color(0xFF2196F3), // Blue
    Color(0xFFB2DFDB), // Teal
    Color(0xFFC8E6C9), // Light Green
    Color(0xFF4CAF50), // Green
    Color(0xFFF0F4C3), // Lime
    Color(0xFFFFF9C4), // Yellow
    Color(0xFFFFECB3), // Amber
    Color(0xFFFFC107), // Orange
    Color(0xFFFFCCBC), // Deep Orange
  ];

  //0xFF4CAF50，0xFF2196F3，0xFFFFC107，
  
  // Gradient Colors
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  
  static const Gradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );
}