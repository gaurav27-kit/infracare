import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'custom_button.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final IconData? icon;
  final Color iconColor;

  const CustomDialog({
    Key? key,
    required this.title,
    required this.message,
    this.primaryButtonText = 'Confirm',
    this.secondaryButtonText = 'Cancel',
    required this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.icon = Icons.info_outline,
    this.iconColor = AppColors.primary,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String primaryButtonText = 'Confirm',
    String? secondaryButtonText = 'Cancel',
    required VoidCallback onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    IconData? icon,
    Color iconColor = AppColors.primary,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: title,
          message: message,
          primaryButtonText: primaryButtonText,
          secondaryButtonText: secondaryButtonText,
          onPrimaryPressed: onPrimaryPressed,
          onSecondaryPressed: onSecondaryPressed,
          icon: icon,
          iconColor: iconColor,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (secondaryButtonText != null) ...[
                  Expanded(
                    child: CustomButton(
                      label: secondaryButtonText!,
                      type: ButtonType.secondary,
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (onSecondaryPressed != null) onSecondaryPressed!();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: CustomButton(
                    label: primaryButtonText,
                    type: ButtonType.primary,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onPrimaryPressed();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
