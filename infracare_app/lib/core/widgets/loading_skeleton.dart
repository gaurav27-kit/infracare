import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated pulsing skeleton placeholder used during data loading.
///
/// Uses a simple opacity tween so there is no extra dependency.
/// For richer shimmer effects, see the `shimmer` package — this
/// widget can be replaced with `Shimmer.fromColors` when needed.
class LoadingSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// Pre-built skeleton matching the layout of [IssueCard].
///
/// Use inside a [ListView.builder] while waiting for API data.
class IssueCardSkeleton extends StatelessWidget {
  const IssueCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LoadingSkeleton(width: 80, height: 20, borderRadius: 6),
              LoadingSkeleton(width: 90, height: 24, borderRadius: 20),
            ],
          ),
          SizedBox(height: 12),
          LoadingSkeleton(width: 220, height: 18, borderRadius: 6),
          SizedBox(height: 12),
          LoadingSkeleton(width: 160, height: 14, borderRadius: 6),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LoadingSkeleton(width: 100, height: 14, borderRadius: 6),
              LoadingSkeleton(width: 80, height: 20, borderRadius: 8),
            ],
          ),
        ],
      ),
    );
  }
}
