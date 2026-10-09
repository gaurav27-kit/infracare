/// Application-level constants.
///
/// Only generic, UI-level constants are stored here.
/// Domain data (buildings, floors, spaces, assets) will be
/// fetched from the InfraCare REST API and must NOT be hardcoded here.
class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------------
  // App Identity
  // ---------------------------------------------------------------------------
  static const String appName = 'InfraCare';
  static const String appTagline = 'Campus Infrastructure Management';
  static const String appVersion = 'v1.0.0 (Build 2026.1)';

  // ---------------------------------------------------------------------------
  // API (placeholder — update with real values before backend integration)
  // ---------------------------------------------------------------------------
  static const String apiBaseUrl = 'https://api.infracare.example.com/v1';

  // ---------------------------------------------------------------------------
  // Layout / Spacing
  // ---------------------------------------------------------------------------
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  static const double defaultBorderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double chipBorderRadius = 20.0;

  // ---------------------------------------------------------------------------
  // Animation Durations
  // ---------------------------------------------------------------------------
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 600);

  static const Duration skeletonPulseDuration = Duration(milliseconds: 1200);
}
