import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

/// A styled [Dialog] with an icon, title, message, and up to two action buttons.
///
/// Use the static [CustomDialog.show] factory to display it without
/// managing a [StatefulWidget] at the call-site.
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
    super.key,
    required this.title,
    required this.message,
    this.primaryButtonText = 'Confirm',
    this.secondaryButtonText = 'Cancel',
    required this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.icon = Icons.info_outline,
    this.iconColor = AppColors.primary,
  });

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
      builder: (_) => CustomDialog(
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  /// Displays arbitrary child content in a centered, styled modal dialog.
  static Future<void> showContentDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    IconData? icon,
    Color iconColor = AppColors.primary,
    String closeButtonText = 'Close',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (icon != null) ...[
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: iconColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: content,
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomButton(
                    label: closeButtonText,
                    width: 100,
                    height: 38,
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
                  color: iconColor.withValues(alpha: 0.12),
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
                      height: 46,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onSecondaryPressed?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: CustomButton(
                    label: primaryButtonText,
                    height: 46,
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
