import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/issue_model.dart';
import '../../../providers/admin_provider.dart';

/// Admin Issues Management Screen matching Stitch Design.
class IssuesManagementScreen extends ConsumerStatefulWidget {
  final Function(String)? onSelectIssue;
  final Function(int)? onNavigateToTab;

  const IssuesManagementScreen({
    super.key,
    this.onSelectIssue,
    this.onNavigateToTab,
  });

  @override
  ConsumerState<IssuesManagementScreen> createState() =>
      _IssuesManagementScreenState();
}

class _IssuesManagementScreenState
    extends ConsumerState<IssuesManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _statusFilters = [
    'All',
    'Open',
    'Assigned',
    'In Progress',
    'Resolved',
    'Closed',
  ];

  static const List<String> _priorityFilters = [
    'All',
    'Critical',
    'High',
    'Medium',
    'Low',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _inferCategory(IssueModel issue) {
    final text = '${issue.asset ?? ''} ${issue.customAssetName ?? ''} ${issue.title} ${issue.description}'.toLowerCase();
    if (text.contains('projector') || text.contains('imac') || text.contains('monitor') || text.contains('computer') || text.contains('screen') || text.contains('display') || text.contains('audio') || text.contains('visual') || text.contains('it')) {
      return 'IT & AV';
    } else if (text.contains('ac') || text.contains('air') || text.contains('hvac') || text.contains('cool') || text.contains('ventilation')) {
      return 'HVAC';
    } else if (text.contains('electric') || text.contains('light') || text.contains('power') || text.contains('panel') || text.contains('ups') || text.contains('switch')) {
      return 'Electrical';
    } else if (text.contains('water') || text.contains('pipe') || text.contains('leak') || text.contains('tap') || text.contains('restroom') || text.contains('washroom')) {
      return 'Plumbing';
    } else if (text.contains('fire') || text.contains('safety') || text.contains('alarm') || text.contains('extinguisher')) {
      return 'Safety';
    }
    return 'Other';
  }

  @override
  Widget build(BuildContext context) {
    final issuesState = ref.watch(adminIssuesProvider);
    final filteredList = issuesState.filteredIssues;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Issues Management',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(adminIssuesProvider.notifier).fetchIssues(),
          ),
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
            onPressed: () => widget.onNavigateToTab?.call(3),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSearchBar(
                  controller: _searchController,
                  hintText: 'Search issues...',
                  onChanged: (val) {
                    ref.read(adminIssuesProvider.notifier).setSearchQuery(val);
                  },
                  onClear: () {
                    ref.read(adminIssuesProvider.notifier).setSearchQuery('');
                  },
                ),
                const SizedBox(height: 12),

                // Status horizontal filter chips
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _statusFilters.length,
                    separatorBuilder: (_, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final status = _statusFilters[index];
                      final isSelected = issuesState.statusFilter == status;
                      return ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceVariant,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.cardBorder,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            ref
                                .read(adminIssuesProvider.notifier)
                                .setStatusFilter(status);
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Priority horizontal filter chips
                SizedBox(
                  height: 30,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _priorityFilters.length,
                    separatorBuilder: (_, index) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final priority = _priorityFilters[index];
                      final isSelected = issuesState.priorityFilter == priority;
                      return FilterChip(
                        label: Text(
                          priority == 'All' ? 'All Priorities' : priority,
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        backgroundColor: Colors.transparent,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primaryLight
                              : AppColors.textMuted,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryLight
                                : AppColors.cardBorder,
                          ),
                        ),
                        onSelected: (selected) {
                          ref
                              .read(adminIssuesProvider.notifier)
                              .setPriorityFilter(selected ? priority : 'All');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Issues List Body
          Expanded(
            child: issuesState.isLoading && filteredList.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryLight),
                  )
                : filteredList.isEmpty
                    ? EmptyState(
                        title: issuesState.issues.isEmpty
                            ? 'No Issues Found'
                            : 'No Matching Issues',
                        description: issuesState.issues.isEmpty
                            ? 'No infrastructure incidents are currently in the system.'
                            : 'Try adjusting your search query or filter options.',
                        icon: issuesState.issues.isEmpty
                            ? Icons.inbox_outlined
                            : Icons.search_off_rounded,
                        buttonText: issuesState.issues.isNotEmpty
                            ? 'Reset Filters'
                            : null,
                        onButtonPressed: () {
                          _searchController.clear();
                          ref
                              .read(adminIssuesProvider.notifier)
                              .setSearchQuery('');
                          ref
                              .read(adminIssuesProvider.notifier)
                              .setStatusFilter('All');
                          ref
                              .read(adminIssuesProvider.notifier)
                              .setPriorityFilter('All');
                        },
                      )
                    : RefreshIndicator(
                        color: AppColors.primaryLight,
                        backgroundColor: AppColors.surface,
                        onRefresh: () => ref
                            .read(adminIssuesProvider.notifier)
                            .fetchIssues(),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          itemCount: filteredList.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final issue = filteredList[index];
                            return _buildIssueCard(issue);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCard(IssueModel issue) {
    final isResolved = issue.status.toUpperCase() == 'RESOLVED' ||
        issue.status.toUpperCase() == 'CLOSED';
    final category = _inferCategory(issue);

    Color accentColor = AppColors.primaryLight;
    final pUpper = issue.priority.toUpperCase();
    if (pUpper == 'CRITICAL') {
      accentColor = AppColors.danger;
    } else if (pUpper == 'HIGH') {
      accentColor = const Color(0xFFF97316);
    } else if (pUpper == 'MEDIUM' || pUpper == 'MED') {
      accentColor = AppColors.warning;
    } else if (pUpper == 'LOW') {
      accentColor = AppColors.primaryLight;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left priority stripe
            Container(
              width: 4,
              color: accentColor,
            ),
            // Card Content
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => widget.onSelectIssue?.call(issue.id),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: ID, Priority, Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  issue.id,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    issue.priority.toUpperCase(),
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            _buildStatusBadge(issue.status),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          issue.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            decoration: isResolved
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Location & Category Row
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
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
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
                        const SizedBox(height: 10),

                        // Bottom Row: Reported time and View Details action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 13,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  issue.reportedAt.contains('T')
                                      ? issue.reportedAt.split('T').first
                                      : issue.reportedAt,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View Details',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primaryLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: AppColors.primaryLight,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = AppColors.surfaceVariant;
    Color text = AppColors.textSecondary;
    String label = status.replaceAll('_', ' ');

    final upper = status.toUpperCase().replaceAll(' ', '_');
    if (upper == 'OPEN' || upper == 'REPORTED') {
      bg = AppColors.warning.withValues(alpha: 0.15);
      text = AppColors.warning;
      label = 'Open';
    } else if (upper == 'ASSIGNED') {
      bg = AppColors.primary.withValues(alpha: 0.15);
      text = AppColors.primaryLight;
      label = 'Assigned';
    } else if (upper == 'IN_PROGRESS') {
      bg = const Color(0xFF3B82F6).withValues(alpha: 0.15);
      text = const Color(0xFF60A5FA);
      label = 'In Progress';
    } else if (upper == 'RESOLVED') {
      bg = AppColors.success.withValues(alpha: 0.15);
      text = AppColors.success;
      label = 'Resolved';
    } else if (upper == 'CLOSED') {
      bg = AppColors.surfaceVariant;
      text = AppColors.textMuted;
      label = 'Closed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
