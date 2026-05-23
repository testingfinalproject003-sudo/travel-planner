import 'package:flutter/material.dart';

class AppColors {
  // Primary Color - #D99379 (Premium Terracotta/Salmon)
  static const Color primary = Color(0xFFD99379);
  static const Color primaryLight = Color(0xFFF5D5C8);
  static const Color primaryDark = Color(0xFFB8735A);
  static const Color primaryAccent = Color(0xFFE8B4A0);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF2C3E50);
  static const Color secondaryLight = Color(0xFF34495E);
  
  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF8F4F2);
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF16213E);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textLight = Color(0xFFBDC3C7);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);
  
  // Chat Colors
  static const Color chatSent = Color(0xFFD99379);
  static const Color chatReceived = Color(0xFFF0F0F0);
  static const Color chatBackground = Color(0xFFF8F4F2);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFD99379), Color(0xFFE8B4A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}