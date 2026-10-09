import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable button with four display variants: primary, secondary, danger, text.
///
/// Wraps [ElevatedButton], [OutlinedButton], and [TextButton] behind a
/// single API so the call-site never needs to import Flutter button classes
/// directly.
enum ButtonType { primary, secondary, danger, text }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 50,
  });

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    switch (type) {
      case ButtonType.primary:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            child: _buildChild(),
          ),
        );

      case ButtonType.secondary:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: OutlinedButton(
            onPressed: effectiveOnPressed,
            child: _buildChild(),
          ),
        );

      case ButtonType.danger:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: effectiveOnPressed,
            child: _buildChild(),
          ),
        );

      case ButtonType.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          child: _buildChild(),
        );
    }
  }
}
