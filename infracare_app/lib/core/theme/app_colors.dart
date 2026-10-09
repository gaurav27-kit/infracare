import 'package:flutter/material.dart';

/// Central color palette for the InfraCare dark theme.
///
/// All colors are derived from this single source of truth.
/// Do NOT hardcode color values in individual widgets — always reference
/// a constant from this class.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand / Primary
  // ---------------------------------------------------------------------------
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // ---------------------------------------------------------------------------
  // Background & Surface
  // ---------------------------------------------------------------------------
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceVariant = Color(0xFF334155);
  static const Color cardBorder = Color(0xFF334155);

  // ---------------------------------------------------------------------------
  // Semantic / Status
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // ---------------------------------------------------------------------------
  // Status tint backgrounds (low-opacity fills for chips / badges)
  // ---------------------------------------------------------------------------
  static Color successBackground = success.withValues(alpha: 0.15);
  static Color warningBackground = warning.withValues(alpha: 0.15);
  static Color dangerBackground = danger.withValues(alpha: 0.15);
  static Color infoBackground = primary.withValues(alpha: 0.15);
}
