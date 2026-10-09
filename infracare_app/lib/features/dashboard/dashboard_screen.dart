import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/issue_card.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/dashboard_model.dart';
import '../../providers/dashboard_provider.dart';

/// Dashboard — the first tab of the application.
class DashboardScreen extends ConsumerWidget {
  /// Callback to switch the bottom-nav tab.
  final Function(int)? onNavigateToTab;

  /// Callback to open issue details inline.
  final Function(String)? onSelectIssue;

  const DashboardScreen({
    super.key,
    this.onNavigateToTab,
    this.onSelectIssue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final recentAsync = ref.watch(recentIssuesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.domain_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'InfraCare',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.primary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceVariant,
              child: Icon(
                Icons.person,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.read(dashboardStatsProvider.notifier).refresh();
          ref.read(recentIssuesProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              const Text(
                'Welcome Back 👋',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Here's your infrastructure overview for today.",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Quick action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text(
                        'Report Issue',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => onNavigateToTab?.call(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.format_list_bulleted,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      label: const Text(
                        'My Issues',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => onNavigateToTab?.call(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Metrics grid
              statsAsync.when(
                data: (stats) => _buildMetricsGrid(stats),
                loading: () => _buildMetricsSkeleton(),
                error: (error, stack) => _buildErrorCard(
                  'Failed to load dashboard metrics: $error',
                  onRetry: () => ref.read(dashboardStatsProvider.notifier).refresh(),
                ),
              ),
              const SizedBox(height: 28),

              // Recent issues header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Issues',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigateToTab?.call(2),
                    child: const Row(
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Recent issues list
              recentAsync.when(
                data: (issues) => issues.isEmpty
                    ? _buildEmptyRecentIssues()
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: issues.length,
                        itemBuilder: (context, index) {
                          final item = issues[index];
                          return IssueCard(
                            issueId: item.id,
                            title: item.title,
                            location: item.location,
                            date: item.reportedAt,
                            status: item.status,
                            priority: item.priority,
                            onTap: () => onSelectIssue?.call(item.id),
                          );
                        },
                      ),
                loading: () => const Column(
                  children: [
                    IssueCardSkeleton(),
                    IssueCardSkeleton(),
                  ],
                ),
                error: (error, stack) => _buildErrorCard(
                  'Failed to load recent issues: $error',
                  onRetry: () => ref.read(recentIssuesProvider.notifier).refresh(),
                ),
              ),
              const SizedBox(height: 24),

              // System status banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.show_chart_rounded,
                        color: AppColors.success,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SYSTEM OPERATIONAL',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            statsAsync.valueOrNull?.systemStatus ??
                                'All infrastructure systems operating nominally.',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(DashboardModel stats) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Open Issues',
          count: stats.openCount?.toString() ?? '--',
          icon: Icons.assignment_outlined,
          color: AppColors.primary,
        ),
        _buildStatCard(
          title: 'In Progress',
          count: stats.inProgressCount?.toString() ?? '--',
          icon: Icons.pending_actions_rounded,
          color: AppColors.warning,
        ),
        _buildStatCard(
          title: 'Resolved',
          count: stats.resolvedCount?.toString() ?? '--',
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.success,
        ),
        _buildStatCard(
          title: 'Critical',
          count: stats.criticalCount?.toString() ?? '--',
          icon: Icons.warning_amber_rounded,
          color: AppColors.danger,
          isAlert: true,
        ),
      ],
    );
  }

  Widget _buildMetricsSkeleton() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        LoadingSkeleton(height: 80, borderRadius: 16),
        LoadingSkeleton(height: 80, borderRadius: 16),
        LoadingSkeleton(height: 80, borderRadius: 16),
        LoadingSkeleton(height: 80, borderRadius: 16),
      ],
    );
  }

  Widget _buildErrorCard(String message, {required VoidCallback onRetry}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomButton(
            label: 'Retry',
            type: ButtonType.secondary,
            height: 36,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecentIssues() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 32, color: AppColors.textMuted),
            SizedBox(height: 8),
            Text(
              'No recent issues',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert ? AppColors.danger.withValues(alpha: 0.5) : AppColors.cardBorder,
          width: isAlert ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isAlert ? AppColors.danger : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            count,
            style: TextStyle(
              color: isAlert ? AppColors.danger : AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
