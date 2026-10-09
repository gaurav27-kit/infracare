import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralised [TextStyle] definitions using Google Fonts — Poppins.
///
/// All text styles reference [AppColors] so changing the palette
/// automatically propagates to typography.
class AppTextStyles {
  AppTextStyles._();

  // ---------------------------------------------------------------------------
  // Display
  // ---------------------------------------------------------------------------
  static TextStyle get displayLarge => GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      );

  // ---------------------------------------------------------------------------
  // Headline
  // ---------------------------------------------------------------------------
  static TextStyle get headlineMedium => GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      );

  // ---------------------------------------------------------------------------
  // Title
  // ---------------------------------------------------------------------------
  static TextStyle get titleLarge => GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleMedium => GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------
  static TextStyle get bodyLarge => GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.normal,
      );

  // ---------------------------------------------------------------------------
  // Label / Caption
  // ---------------------------------------------------------------------------
  static TextStyle get labelSmall => GoogleFonts.poppins(
        color: AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get caption => GoogleFonts.poppins(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );

  // ---------------------------------------------------------------------------
  // Overline / Section Header
  // ---------------------------------------------------------------------------
  static TextStyle get overline => GoogleFonts.poppins(
        color: AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      );

  // ---------------------------------------------------------------------------
  // Button
  // ---------------------------------------------------------------------------
  static TextStyle get buttonLabel => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      );
}
