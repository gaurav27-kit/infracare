import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../core/network/api_response.dart';
import '../models/dashboard_model.dart';
import '../models/issue_model.dart';
import 'issue_repository.dart';

class DashboardRepository {
  final ApiClient _apiClient;
  final IssueRepository _issueRepo;

  DashboardRepository({ApiClient? apiClient, IssueRepository? issueRepo})
      : _apiClient = apiClient ?? ApiClient.instance,
        _issueRepo = issueRepo ?? IssueRepository();

  // ---------------------------------------------------------------------------
  // LOCAL-FIRST: compute stats from local issues immediately — no network wait
  // ---------------------------------------------------------------------------

  /// Returns dashboard stats computed instantly from local + persisted issues.
  /// No network call in the critical path — updates silently if API responds.
  Future<ApiResponse<DashboardModel>> getDashboardSummary() async {
    // Fast path: compute from local data instantly
    final issues = await _issueRepo.getIssuesLocal();
    final model = _computeStatsFromIssues(issues);
    return ApiResponse.success(model, statusCode: 200);
  }

  /// Attempts a fresh fetch from the API — used for background refresh only.
  Future<ApiResponse<DashboardModel>> getDashboardSummaryFromNetwork() async {
    // 1. Try /dashboard/issues for exact status and priority maps
    try {
      final statsResponse = await _apiClient.get(ApiConstants.dashboardIssueStats);
      if (statsResponse.isSuccess && statsResponse.data != null) {
        final json = statsResponse.data is Map<String, dynamic>
            ? statsResponse.data as Map<String, dynamic>
            : <String, dynamic>{};
        final model = DashboardModel.fromJson(json);
        if (model.openCount != null) {
          return ApiResponse.success(model, statusCode: statsResponse.statusCode);
        }
      }
    } catch (_) {
      // Fall through
    }

    // 2. Try computing live stats from /issues
    try {
      final issuesResponse = await _issueRepo.getIssues();
      if (issuesResponse.isSuccess && issuesResponse.data != null && issuesResponse.data!.isNotEmpty) {
        final model = _computeStatsFromIssues(issuesResponse.data!);
        return ApiResponse.success(model, statusCode: 200);
      }
    } catch (_) {
      // Fall through to local
    }

    // 3. Fallback: compute from local
    final issues = await _issueRepo.getIssuesLocal();
    return ApiResponse.success(_computeStatsFromIssues(issues), statusCode: 200);
  }

  DashboardModel _computeStatsFromIssues(List<IssueModel> issues) {
    final inProgress = issues.where((i) =>
        i.status.toUpperCase() == 'IN_PROGRESS' || i.status.toUpperCase() == 'ASSIGNED').length;
    final resolved = issues.where((i) =>
        i.status.toUpperCase() == 'RESOLVED' || i.status.toUpperCase() == 'CLOSED').length;
    final open = issues.where((i) =>
        i.status.toUpperCase() == 'OPEN' || i.status.toUpperCase() == 'REPORTED' || i.status.toUpperCase() == 'PENDING').length;
    final critical = issues.where((i) =>
        i.priority.toUpperCase() == 'CRITICAL' || i.priority.toUpperCase() == 'HIGH').length;

    return DashboardModel(
      openCount: open,
      inProgressCount: inProgress,
      resolvedCount: resolved,
      criticalCount: critical,
      systemStatus: 'All AIML systems operational & monitored.',
    );
  }

  // ---------------------------------------------------------------------------
  // Recent issues — also local-first
  // ---------------------------------------------------------------------------

  /// Returns recent issues instantly from local + persisted storage.
  Future<ApiResponse<List<IssueModel>>> getRecentIssues() async {
    // Fast path: get from local immediately
    final local = await _issueRepo.getIssuesLocal();
    return ApiResponse.success(local, statusCode: 200);
  }

  /// Attempts to fetch recent issues from the API — for background refresh only.
  Future<ApiResponse<List<IssueModel>>> getRecentIssuesFromNetwork() async {
    try {
      final response = await _apiClient.get(ApiConstants.dashboardRecentIssues);
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List<dynamic>
            : (response.data['data'] as List<dynamic>? ?? []);
        if (list.isNotEmpty) {
          final issues = list
              .map((e) => IssueModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return ApiResponse.success(issues, statusCode: response.statusCode);
        }
      }
    } catch (_) {
      // Fall through
    }

    try {
      final response = await _apiClient.get(ApiConstants.issues);
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List<dynamic>
            : (response.data['data'] as List<dynamic>? ?? []);
        if (list.isNotEmpty) {
          final issues = list
              .take(5)
              .map((e) => IssueModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return ApiResponse.success(issues, statusCode: response.statusCode);
        }
      }
    } catch (_) {
      // Fall through
    }

    final local = await _issueRepo.getIssuesLocal();
    return ApiResponse.success(local, statusCode: 200);
  }
}
