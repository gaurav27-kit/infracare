import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Displays the current status of an issue as a colored chip
/// with an icon and label.
///
/// Supports: Open, In Progress, Resolved, Closed, Critical.
class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'open':
        return AppColors.primary;
      case 'in progress':
      case 'inprogress':
        return AppColors.warning;
      case 'resolved':
      case 'closed':
        return AppColors.success;
      case 'critical':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (status.toLowerCase()) {
      case 'open':
        return Icons.info_outline;
      case 'in progress':
      case 'inprogress':
        return Icons.pending_actions;
      case 'resolved':
      case 'closed':
        return Icons.check_circle_outline;
      case 'critical':
        return Icons.warning_amber_rounded;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
