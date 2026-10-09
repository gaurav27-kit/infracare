import 'package:flutter/material.dart';

/// Convenience extensions on [BuildContext].
///
/// Provides typed shortcuts to the most frequently accessed
/// theme and layout properties so screens stay clean.
extension ContextExtension on BuildContext {
  // ---------------------------------------------------------------------------
  // Screen dimensions
  // ---------------------------------------------------------------------------

  /// The logical width of the screen.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// The logical height of the screen.
  double get screenHeight => MediaQuery.of(this).size.height;

  /// The height of the bottom safe-area / keyboard inset.
  double get bottomInset => MediaQuery.of(this).viewInsets.bottom;

  // ---------------------------------------------------------------------------
  // Theme shortcuts
  // ---------------------------------------------------------------------------

  /// The active [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// The active [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// The active [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // ---------------------------------------------------------------------------
  // Brightness helpers
  // ---------------------------------------------------------------------------

  /// Whether the current theme brightness is [Brightness.dark].
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ---------------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------------

  /// Pushes a named route.
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);

  /// Pops the current route.
  void pop<T>([T? result]) => Navigator.of(this).pop<T>(result);
}
