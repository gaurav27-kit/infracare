import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/issue_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/dashboard_provider.dart';

/// Admin Dashboard Screen recreating the Stitch Admin Dashboard design.
class AdminDashboardScreen extends ConsumerWidget {
  final Function(int)? onNavigateToTab;
  final Function(String)? onSelectIssue;

  const AdminDashboardScreen({
    super.key,
    this.onNavigateToTab,
    this.onSelectIssue,
  });

  String _inferCategory(IssueModel issue) {
    final text = '${issue.asset ?? ''} ${issue.title} ${issue.description}'.toLowerCase();
    if (text.contains('electric') || text.contains('light') || text.contains('power') || text.contains('projector')) {
      return 'Electrical';
    } else if (text.contains('ac') || text.contains('air') || text.contains('hvac') || text.contains('cool')) {
      return 'HVAC';
    } else if (text.contains('water') || text.contains('pipe') || text.contains('leak') || text.contains('restroom')) {
      return 'Plumbing';
    } else if (text.contains('door') || text.contains('window') || text.contains('wall') || text.contains('elevator')) {
      return 'Structural';
    }
    return 'General';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(adminAnalyticsProvider);
    final issuesState = ref.watch(adminIssuesProvider);
    final recentIssues = issuesState.issues.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
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
                color: AppColors.primaryLight,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Admin Dashboard',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.surfaceVariant,
              child: Icon(
                Icons.person,
                size: 18,
                color: AppColors.primaryLight,
              ),
            ),
            tooltip: 'Admin Profile',
            onPressed: () => onNavigateToTab?.call(3),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryLight,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          await ref.read(adminIssuesProvider.notifier).fetchIssues();
          await ref.read(dashboardStatsProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System Overview Header
              Text(
                'System Overview',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Real-time status of facility infrastructure and open incidents.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Stats 2x2 Grid matching Stitch design
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    title: 'TOTAL ISSUES',
                    value: '${analytics.totalIssues}',
                    subtitle: 'Total recorded',
                    icon: Icons.dataset_outlined,
                    iconColor: AppColors.primaryLight,
                    glowColor: AppColors.primary.withValues(alpha: 0.15),
                  ),
                  _buildStatCard(
                    title: 'OPEN',
                    value: '${analytics.openCount}',
                    subtitle: 'Requires attention',
                    icon: Icons.pending_actions_rounded,
                    iconColor: AppColors.warning,
                    glowColor: AppColors.warning.withValues(alpha: 0.15),
                  ),
                  _buildStatCard(
                    title: 'IN PROGRESS',
                    value: '${analytics.inProgressCount}',
                    subtitle: 'Currently assigned',
                    icon: Icons.engineering_rounded,
                    iconColor: const Color(0xFF60A5FA),
                    glowColor: const Color(0xFF60A5FA).withValues(alpha: 0.15),
                  ),
                  _buildStatCard(
                    title: 'CRITICAL',
                    value: '${analytics.criticalPriorityCount}',
                    subtitle: 'Immediate action required',
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppColors.danger,
                    glowColor: AppColors.danger.withValues(alpha: 0.15),
                    isAlert: analytics.criticalPriorityCount > 0,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Recent Issues Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Issues',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigateToTab?.call(1),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: AppTextStyles.buttonLabel.copyWith(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppColors.primaryLight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Recent Issues List
              if (issuesState.isLoading && recentIssues.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppColors.primaryLight),
                  ),
                )
              else if (recentIssues.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.inbox_outlined, size: 36, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No recent issues reported.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentIssues.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final issue = recentIssues[index];
                    return _buildAdminRecentIssueCard(issue);
                  },
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color glowColor,
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert ? AppColors.danger.withValues(alpha: 0.6) : AppColors.cardBorder,
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: isAlert ? AppColors.danger : AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: isAlert ? AppColors.danger : AppColors.textSecondary,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminRecentIssueCard(IssueModel issue) {
    final category = _inferCategory(issue);
    final isCritical = issue.priority.toUpperCase() == 'CRITICAL';
    final isHigh = issue.priority.toUpperCase() == 'HIGH';

    Color priorityColor = AppColors.primaryLight;
    if (isCritical) {
      priorityColor = AppColors.danger;
    } else if (isHigh) {
      priorityColor = const Color(0xFFF97316);
    } else if (issue.priority.toUpperCase() == 'MEDIUM') {
      priorityColor = AppColors.warning;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onSelectIssue?.call(issue.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: ID, Priority, and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            issue.id,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            issue.priority.toUpperCase(),
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _buildStatusPill(issue.status),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  issue.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Location and Category
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        issue.location.isNotEmpty
                            ? issue.location
                            : '${issue.building ?? "AIML Building"} > ${issue.space ?? "Main Area"}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color dotColor = AppColors.warning;
    String label = status.replaceAll('_', ' ');

    final upper = status.toUpperCase().replaceAll(' ', '_');
    if (upper == 'OPEN' || upper == 'REPORTED') {
      dotColor = AppColors.warning;
      label = 'Open';
    } else if (upper == 'ASSIGNED') {
      dotColor = AppColors.primaryLight;
      label = 'Assigned';
    } else if (upper == 'IN_PROGRESS') {
      dotColor = const Color(0xFF60A5FA);
      label = 'In Progress';
    } else if (upper == 'RESOLVED') {
      dotColor = AppColors.success;
      label = 'Resolved';
    } else if (upper == 'CLOSED') {
      dotColor = AppColors.textMuted;
      label = 'Closed';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
