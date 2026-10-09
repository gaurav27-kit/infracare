import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_model.dart';
import '../models/issue_model.dart';
import '../repositories/dashboard_repository.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

// ---------------------------------------------------------------------------
// Dashboard Stats Provider
// ---------------------------------------------------------------------------

/// Provides the dashboard statistics.
/// Loads instantly from local data, refreshes from network in background.
final dashboardStatsProvider =
    AsyncNotifierProvider<DashboardStatsNotifier, DashboardModel>(
  DashboardStatsNotifier.new,
);

class DashboardStatsNotifier extends AsyncNotifier<DashboardModel> {
  @override
  Future<DashboardModel> build() async {
    final repo = ref.read(dashboardRepositoryProvider);
    // Return local stats immediately (no network wait)
    final response = await repo.getDashboardSummary();
    final localStats = response.data ?? const DashboardModel.empty();
    // Silently refresh from network in background
    _backgroundRefresh(repo);
    return localStats;
  }

  /// Refreshes stats from network without flashing a loading skeleton.
  void _backgroundRefresh(DashboardRepository repo) {
    repo.getDashboardSummaryFromNetwork().then((response) {
      if (response.isSuccess && response.data != null) {
        state = AsyncData(response.data!);
      }
    }).catchError((_) {});
  }

  /// Pull-to-refresh: keep existing stats visible while fetching fresh ones.
  Future<void> refresh() async {
    final repo = ref.read(dashboardRepositoryProvider);
    // Show local/computed stats immediately if we don't have data yet
    if (!state.hasValue) {
      final local = await repo.getDashboardSummary();
      state = AsyncData(local.data ?? const DashboardModel.empty());
    }
    // Silently update from network
    _backgroundRefresh(repo);
  }
}

// ---------------------------------------------------------------------------
// Recent Issues Provider
// ---------------------------------------------------------------------------

/// Provides the list of recent issues shown on the dashboard.
/// Loads instantly from local data, refreshes from network in background.
final recentIssuesProvider =
    AsyncNotifierProvider<RecentIssuesNotifier, List<IssueModel>>(
  RecentIssuesNotifier.new,
);

class RecentIssuesNotifier extends AsyncNotifier<List<IssueModel>> {
  @override
  Future<List<IssueModel>> build() async {
    final repo = ref.read(dashboardRepositoryProvider);
    // Return local issues immediately (no network wait)
    final response = await repo.getRecentIssues();
    final localIssues = response.data ?? const [];
    // Silently refresh from network in background
    _backgroundRefresh(repo);
    return localIssues;
  }

  /// Refreshes recent issues from network without flashing a loading skeleton.
  void _backgroundRefresh(DashboardRepository repo) {
    repo.getRecentIssuesFromNetwork().then((response) {
      if (response.isSuccess && response.data != null) {
        state = AsyncData(response.data!);
      }
    }).catchError((_) {});
  }

  /// Pull-to-refresh: keep existing list visible while fetching fresh data.
  Future<void> refresh() async {
    final repo = ref.read(dashboardRepositoryProvider);
    if (!state.hasValue) {
      final local = await repo.getRecentIssues();
      state = AsyncData(local.data ?? const []);
    }
    // Silently update from network
    _backgroundRefresh(repo);
  }
}
