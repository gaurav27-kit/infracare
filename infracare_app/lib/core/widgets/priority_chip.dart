import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Displays the priority level of an issue as a compact colored chip.
///
/// Supports: Low, Medium, High, Critical.
class PriorityChip extends StatelessWidget {
  final String priority;

  const PriorityChip({super.key, required this.priority});

  Color get _color {
    switch (priority.toLowerCase()) {
      case 'low':
        return AppColors.primaryLight;
      case 'medium':
      case 'med':
        return AppColors.warning;
      case 'high':
        return const Color(0xFFF97316); // orange
      case 'critical':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$priority Priority',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
