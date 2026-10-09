import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_search_bar.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/issue_card.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../models/issue_model.dart';
import '../../providers/issue_provider.dart';

/// Lists all infrastructure issues reported by the current user.
class MyIssuesScreen extends ConsumerStatefulWidget {
  final Function(String)? onSelectIssue;

  const MyIssuesScreen({super.key, this.onSelectIssue});

  @override
  ConsumerState<MyIssuesScreen> createState() => _MyIssuesScreenState();
}

class _MyIssuesScreenState extends ConsumerState<MyIssuesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  static const List<String> _statusFilters = [
    'All',
    'Open',
    'In Progress',
    'Resolved',
    'Critical',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<IssueModel> _filterIssues(List<IssueModel> issues) {
    final query = _searchController.text.toLowerCase();
    return issues.where((issue) {
      final matchesSearch = query.isEmpty ||
          issue.title.toLowerCase().contains(query) ||
          issue.id.toLowerCase().contains(query) ||
          issue.location.toLowerCase().contains(query);

      if (_selectedFilter == 'All') return matchesSearch;
      return matchesSearch &&
          issue.status.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final issuesAsync = ref.watch(myIssuesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Reported Issues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(myIssuesProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomSearchBar(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  onClear: () => setState(() {}),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _statusFilters.length,
                    itemBuilder: (context, index) {
                      final status = _statusFilters[index];
                      final isSelected = _selectedFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.cardBorder,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedFilter = status);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // List Body
          Expanded(
            child: issuesAsync.when(
              data: (allIssues) {
                final filtered = _filterIssues(allIssues);
                if (filtered.isEmpty) {
                  return EmptyState(
                    title: allIssues.isEmpty
                        ? 'No Issues Yet'
                        : 'No Matching Issues Found',
                    description: allIssues.isEmpty
                        ? 'Issues reported by you will appear here.'
                        : 'Try adjusting your search terms or status filters.',
                    icon: allIssues.isEmpty
                        ? Icons.inbox_outlined
                        : Icons.search_off_rounded,
                    buttonText: allIssues.isNotEmpty ? 'Reset Filters' : null,
                    onButtonPressed: allIssues.isNotEmpty
                        ? () => setState(() {
                              _searchController.clear();
                              _selectedFilter = 'All';
                            })
                        : null,
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: () async =>
                      ref.read(myIssuesProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final issue = filtered[index];
                      return IssueCard(
                        issueId: issue.id,
                        title: issue.title,
                        location: issue.location,
                        date: issue.reportedAt,
                        status: issue.status,
                        priority: issue.priority,
                        onTap: () => widget.onSelectIssue?.call(issue.id),
                      );
                    },
                  ),
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5,
                itemBuilder: (context, index) => const IssueCardSkeleton(),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: AppColors.danger,
                          size: 36,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Failed to Load Issues',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$error',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          label: 'Retry',
                          width: 140,
                          height: 40,
                          onPressed: () =>
                              ref.read(myIssuesProvider.notifier).refresh(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
