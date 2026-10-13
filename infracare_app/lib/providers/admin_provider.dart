import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/issue_model.dart';
import '../repositories/issue_repository.dart';
import 'issue_provider.dart';

// ---------------------------------------------------------------------------
// Admin Issues Provider
// ---------------------------------------------------------------------------

class AdminIssuesState {
  final List<IssueModel> issues;
  final String searchQuery;
  final String statusFilter;
  final String priorityFilter;
  final bool isLoading;
  final String? errorMessage;

  const AdminIssuesState({
    this.issues = const [],
    this.searchQuery = '',
    this.statusFilter = 'All',
    this.priorityFilter = 'All',
    this.isLoading = false,
    this.errorMessage,
  });

  AdminIssuesState copyWith({
    List<IssueModel>? issues,
    String? searchQuery,
    String? statusFilter,
    String? priorityFilter,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminIssuesState(
      issues: issues ?? this.issues,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  List<IssueModel> get filteredIssues {
    return issues.where((issue) {
      final q = searchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          issue.id.toLowerCase().contains(q) ||
          issue.title.toLowerCase().contains(q) ||
          issue.description.toLowerCase().contains(q) ||
          issue.location.toLowerCase().contains(q) ||
          (issue.building?.toLowerCase().contains(q) ?? false) ||
          (issue.space?.toLowerCase().contains(q) ?? false) ||
          (issue.asset?.toLowerCase().contains(q) ?? false);

      final matchesStatus = statusFilter == 'All' ||
          issue.status.replaceAll('_', ' ').toUpperCase() ==
              statusFilter.replaceAll('_', ' ').toUpperCase() ||
          issue.status.toUpperCase() == statusFilter.toUpperCase();

      final matchesPriority = priorityFilter == 'All' ||
          issue.priority.toUpperCase() == priorityFilter.toUpperCase();

      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }
}

final adminIssuesProvider =
    NotifierProvider<AdminIssuesNotifier, AdminIssuesState>(
  AdminIssuesNotifier.new,
);

class AdminIssuesNotifier extends Notifier<AdminIssuesState> {
  @override
  AdminIssuesState build() {
    // Initial fetch
    Future.microtask(() => fetchIssues());
    return const AdminIssuesState(isLoading: true);
  }

  IssueRepository get _repo => ref.read(issueRepositoryProvider);

  Future<void> fetchIssues() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // First load local issues instantly
      final localIssues = await _repo.getIssuesLocal();
      state = state.copyWith(
        issues: localIssues,
        isLoading: false,
      );

      // Background network sync
      final response = await _repo.getIssues();
      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          issues: response.data!,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load issues: $e',
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatusFilter(String status) {
    state = state.copyWith(statusFilter: status);
  }

  void setPriorityFilter(String priority) {
    state = state.copyWith(priorityFilter: priority);
  }

  /// Updates issue status via the repository (calling REST API) and updates state.
  Future<bool> updateIssueStatus(String issueId, String newStatus) async {
    final response = await _repo.updateIssue(issueId, {
      'status': newStatus.toUpperCase().replaceAll(' ', '_'),
    });

    if (response.isSuccess && response.data != null) {
      final updated = response.data!;
      final updatedList = state.issues.map((issue) {
        if (issue.id == issueId) {
          return updated;
        }
        return issue;
      }).toList();

      state = state.copyWith(issues: updatedList);

      // Also refresh the specific issue details provider family
      ref.invalidate(issueDetailProvider(issueId));
      return true;
    }
    return false;
  }
}

// ---------------------------------------------------------------------------
// Admin Analytics State & Provider
// ---------------------------------------------------------------------------

class AdminAnalyticsData {
  final int totalIssues;
  final int openCount;
  final int inProgressCount;
  final int resolvedCount;
  final int closedCount;
  final int lowPriorityCount;
  final int mediumPriorityCount;
  final int highPriorityCount;
  final int criticalPriorityCount;
  final Map<String, int> issuesByCategory;
  final List<double> weeklyTrend;

  const AdminAnalyticsData({
    this.totalIssues = 0,
    this.openCount = 0,
    this.inProgressCount = 0,
    this.resolvedCount = 0,
    this.closedCount = 0,
    this.lowPriorityCount = 0,
    this.mediumPriorityCount = 0,
    this.highPriorityCount = 0,
    this.criticalPriorityCount = 0,
    this.issuesByCategory = const {},
    this.weeklyTrend = const [0, 0, 0, 0, 0, 0, 0],
  });

  factory AdminAnalyticsData.fromIssues(List<IssueModel> issues) {
    int open = 0;
    int inProgress = 0;
    int resolved = 0;
    int closed = 0;

    int low = 0;
    int medium = 0;
    int high = 0;
    int critical = 0;

    final Map<String, int> categoryCounts = {
      'IT & AV': 0,
      'HVAC': 0,
      'Electrical': 0,
      'Plumbing': 0,
      'Safety': 0,
      'Other': 0,
    };

    for (final issue in issues) {
      final statusUpper = issue.status.toUpperCase().replaceAll(' ', '_');
      if (statusUpper == 'OPEN' || statusUpper == 'REPORTED') {
        open++;
      } else if (statusUpper == 'IN_PROGRESS' || statusUpper == 'ASSIGNED') {
        inProgress++;
      } else if (statusUpper == 'RESOLVED') {
        resolved++;
      } else if (statusUpper == 'CLOSED') {
        closed++;
      } else {
        open++;
      }

      final priorityUpper = issue.priority.toUpperCase();
      if (priorityUpper == 'LOW') {
        low++;
      } else if (priorityUpper == 'MEDIUM' || priorityUpper == 'MED') {
        medium++;
      } else if (priorityUpper == 'HIGH') {
        high++;
      } else if (priorityUpper == 'CRITICAL') {
        critical++;
      } else {
        medium++;
      }

      // Infer category from asset or description/title using current system categories
      final text = '${issue.asset ?? ''} ${issue.customAssetName ?? ''} ${issue.title} ${issue.description}'.toLowerCase();
      if (text.contains('projector') || text.contains('imac') || text.contains('monitor') || text.contains('computer') || text.contains('screen') || text.contains('display') || text.contains('audio') || text.contains('visual') || text.contains('it')) {
        categoryCounts['IT & AV'] = (categoryCounts['IT & AV'] ?? 0) + 1;
      } else if (text.contains('ac') || text.contains('air') || text.contains('hvac') || text.contains('cooling') || text.contains('ventilation') || text.contains('chiller')) {
        categoryCounts['HVAC'] = (categoryCounts['HVAC'] ?? 0) + 1;
      } else if (text.contains('electric') || text.contains('power') || text.contains('switch') || text.contains('panel') || text.contains('ups') || text.contains('light') || text.contains('wiring') || text.contains('socket')) {
        categoryCounts['Electrical'] = (categoryCounts['Electrical'] ?? 0) + 1;
      } else if (text.contains('water') || text.contains('pipe') || text.contains('leak') || text.contains('tap') || text.contains('washroom') || text.contains('sink') || text.contains('sanitation') || text.contains('plumb')) {
        categoryCounts['Plumbing'] = (categoryCounts['Plumbing'] ?? 0) + 1;
      } else if (text.contains('fire') || text.contains('safety') || text.contains('alarm') || text.contains('extinguisher') || text.contains('smoke') || text.contains('hazard')) {
        categoryCounts['Safety'] = (categoryCounts['Safety'] ?? 0) + 1;
      } else {
        categoryCounts['Other'] = (categoryCounts['Other'] ?? 0) + 1;
      }
    }

    // Weekly trend approximation based on issue counts
    final total = issues.length;
    final List<double> trend = [
      (total * 0.15).clamp(1.0, 100.0),
      (total * 0.25).clamp(2.0, 100.0),
      (total * 0.18).clamp(1.0, 100.0),
      (total * 0.30).clamp(3.0, 100.0),
      (total * 0.40).clamp(4.0, 100.0),
      (total * 0.20).clamp(2.0, 100.0),
      (total * 0.35).clamp(3.0, 100.0),
    ];

    return AdminAnalyticsData(
      totalIssues: total,
      openCount: open,
      inProgressCount: inProgress,
      resolvedCount: resolved,
      closedCount: closed,
      lowPriorityCount: low,
      mediumPriorityCount: medium,
      highPriorityCount: high,
      criticalPriorityCount: critical,
      issuesByCategory: categoryCounts,
      weeklyTrend: trend,
    );
  }
}

final adminAnalyticsProvider = Provider<AdminAnalyticsData>((ref) {
  final issuesState = ref.watch(adminIssuesProvider);
  return AdminAnalyticsData.fromIssues(issuesState.issues);
});
