import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Surface & Background
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceVariant = Color(0xFF334155);
  static const Color cardBorder = Color(0xFF334155);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Status Background Tints (Low Opacity)
  static Color successBackground = const Color(0xFF22C55E).withOpacity(0.15);
  static Color warningBackground = const Color(0xFFF59E0B).withOpacity(0.15);
  static Color dangerBackground = const Color(0xFFEF4444).withOpacity(0.15);
  static Color infoBackground = const Color(0xFF2563EB).withOpacity(0.15);
}
