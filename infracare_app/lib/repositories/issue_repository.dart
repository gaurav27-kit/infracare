import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../core/network/api_response.dart';
import '../models/issue_model.dart';

class IssueRepository {
  final ApiClient _apiClient;

  IssueRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  // ---------------------------------------------------------------------------
  // SharedPreferences key for persisted user-submitted issues
  // ---------------------------------------------------------------------------
  static const String _prefsKey = 'infracare_user_issues';

  // ---------------------------------------------------------------------------
  // Seed / demo issues — always shown as baseline
  // ---------------------------------------------------------------------------
  static const List<IssueModel> _seedIssues = [
    IssueModel(
      id: 'INF-2026-1042',
      title: 'Water pipe leakage in 1st Floor Washroom',
      description: 'Major leak observed underneath the main washroom fixture, causing floor water accumulation.',
      location: 'AIML Building > 1st Floor > Washroom',
      status: 'OPEN',
      priority: 'HIGH',
      reportedBy: 'AIML Staff',
      reportedAt: '2026-08-08T06:30:00Z',
      building: 'AIML Building',
      buildingId: 'BLD-AIML',
      floor: '1st Floor',
      floorId: 'FLR-AIML-01',
      space: 'Washroom',
      spaceId: 'SPC-AIML-12',
      asset: 'Plumbing Fixture',
      assetId: 'AST-AIML-01',
    ),
    IssueModel(
      id: 'INF-2026-1041',
      title: 'Air conditioning failure in CSAM Lab 02',
      description: 'The HVAC cooling unit has stopped working and lab temperature is rising rapidly.',
      location: 'AIML Building > 1st Floor > CSAM Lab 02',
      status: 'IN_PROGRESS',
      priority: 'CRITICAL',
      reportedBy: 'Lab Coordinator',
      reportedAt: '2026-08-07T14:15:00Z',
      building: 'AIML Building',
      buildingId: 'BLD-AIML',
      floor: '1st Floor',
      floorId: 'FLR-AIML-01',
      space: 'CSAM Lab 02',
      spaceId: 'SPC-AIML-02',
      asset: 'High-Performance Workstation Pool A',
      assetId: 'AST-AIML-02',
    ),
    IssueModel(
      id: 'INF-2026-1040',
      title: 'Projector display glitch in CSAM CR-01',
      description: 'The ceiling projector is intermittently losing signal during lectures.',
      location: 'AIML Building > 2nd Floor > CSAM CR-01',
      status: 'RESOLVED',
      priority: 'LOW',
      reportedBy: 'Faculty Member',
      reportedAt: '2026-08-06T09:00:00Z',
      building: 'AIML Building',
      buildingId: 'BLD-AIML',
      floor: '2nd Floor',
      floorId: 'FLR-AIML-02',
      space: 'CSAM CR-01',
      spaceId: 'SPC-AIML-13',
      asset: 'Classroom Smart Projector & Audio',
      assetId: 'AST-AIML-04',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Persistence helpers
  // ---------------------------------------------------------------------------

  /// Loads user-submitted issues from SharedPreferences.
  Future<List<IssueModel>> _loadPersistedIssues() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return [];
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => IssueModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists the given [userIssues] list to SharedPreferences.
  Future<void> _persistIssues(List<IssueModel> userIssues) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(userIssues.map((i) => i.toJson()).toList());
      await prefs.setString(_prefsKey, encoded);
    } catch (_) {
      // Silently fail — app still works without persistence
    }
  }

  /// Returns the merged, deduplicated list of seed + persisted user issues.
  /// User issues are ordered newest-first, then seeds follow.
  Future<List<IssueModel>> _allIssues() async {
    final persisted = await _loadPersistedIssues();
    // Exclude any seed IDs that the user may have also received from the API
    final seedIds = _seedIssues.map((i) => i.id).toSet();
    final userOnly = persisted.where((i) => !seedIds.contains(i.id)).toList();
    return [...userOnly, ..._seedIssues];
  }

  /// Returns issues instantly from local storage + seeds — no network call.
  /// Use this for dashboard stats and any UI that needs immediate data.
  Future<List<IssueModel>> getIssuesLocal() => _allIssues();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Fetches paginated/filtered list of issues.
  Future<ApiResponse<List<IssueModel>>> getIssues({
    String? search,
    String? status,
    String? priority,
    String? buildingId,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (status != null && status.isNotEmpty && status != 'All') {
        query['status'] = status.toUpperCase();
      }
      if (priority != null && priority.isNotEmpty) query['priority'] = priority;
      if (buildingId != null && buildingId.isNotEmpty) query['buildingId'] = buildingId;

      final response = await _apiClient.get(
        ApiConstants.issues,
        queryParameters: query,
      );
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List<dynamic>
            : (response.data['data'] as List<dynamic>? ?? []);
        final networkIssues = list
            .map((e) => IssueModel.fromJson(e as Map<String, dynamic>))
            .toList();
        final persisted = await _loadPersistedIssues();
        final networkIds = networkIssues.map((i) => i.id).toSet();
        final merged = [
          ...persisted.where((i) => !networkIds.contains(i.id)),
          ...networkIssues,
        ];
        return ApiResponse.success(merged, statusCode: response.statusCode);
      }
    } catch (_) {
      // Fall through to local cache
    }

    // Use merged local + persisted list
    var results = await _allIssues();

    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      results = results.where((i) =>
        i.title.toLowerCase().contains(q) ||
        i.description.toLowerCase().contains(q) ||
        i.location.toLowerCase().contains(q) ||
        i.id.toLowerCase().contains(q)
      ).toList();
    }
    if (status != null && status.isNotEmpty && status != 'All') {
      final s = status.toUpperCase();
      results = results.where((i) => i.status.toUpperCase() == s).toList();
    }
    if (priority != null && priority.isNotEmpty && priority != 'All') {
      final p = priority.toUpperCase();
      results = results.where((i) => i.priority.toUpperCase() == p).toList();
    }
    if (buildingId != null && buildingId.isNotEmpty) {
      results = results.where((i) => i.buildingId == buildingId).toList();
    }

    return ApiResponse.success(results, statusCode: 200);
  }

  /// Fetches single issue details by [id].
  Future<ApiResponse<IssueModel>> getIssueById(String id) async {
    try {
      final response = await _apiClient.get(ApiConstants.issueDetail(id));
      if (response.isSuccess && response.data != null) {
        final issue = IssueModel.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse.success(issue, statusCode: response.statusCode);
      }
    } catch (_) {
      // Fall through
    }
    final all = await _allIssues();
    final match = all.cast<IssueModel?>().firstWhere(
      (i) => i?.id == id,
      orElse: () => null,
    );
    if (match != null) {
      return ApiResponse.success(match, statusCode: 200);
    }
    return ApiResponse.error('Issue not found', statusCode: 404);
  }

  /// Creates a new issue entity — saves locally and syncs to backend API.
  Future<ApiResponse<IssueModel>> createIssue(IssueModel issue) async {
    final normalized = issue.copyWith(
      status: (issue.status.isNotEmpty ? issue.status : 'OPEN').toUpperCase(),
      priority: (issue.priority.isNotEmpty ? issue.priority : 'MEDIUM').toUpperCase(),
    );

    // 1. Try sending to the backend API first
    try {
      final response = await _apiClient.post(
        ApiConstants.issues,
        data: normalized.toJson(),
      );
      if (response.isSuccess && response.data != null) {
        final serverIssue = IssueModel.fromJson(response.data as Map<String, dynamic>);
        final persisted = await _loadPersistedIssues();
        persisted.removeWhere((i) => i.id == serverIssue.id);
        persisted.insert(0, serverIssue);
        await _persistIssues(persisted);
        return ApiResponse.success(serverIssue, statusCode: response.statusCode);
      }
    } catch (_) {
      // Backend temporarily offline — fallback to local creation
    }

    // 2. Fallback: Save locally immediately so UI can update without any wait
    final persisted = await _loadPersistedIssues();
    final ticketNumber = 1043 + persisted.length;
    final created = normalized.copyWith(
      id: normalized.id.isNotEmpty ? normalized.id : 'INF-2026-$ticketNumber',
      reportedAt: normalized.reportedAt.isNotEmpty
          ? normalized.reportedAt
          : DateTime.now().toIso8601String(),
      reportedBy: normalized.reportedBy.isNotEmpty ? normalized.reportedBy : 'You (Current User)',
      location: normalized.location.isNotEmpty
          ? normalized.location
          : '${normalized.building ?? "AIML Building"} > ${normalized.floor ?? "1st Floor"} > ${normalized.space ?? "Main Space"}',
    );
    persisted.insert(0, created);
    await _persistIssues(persisted);

    // 3. Sync to network in background
    _syncCreatedIssueToNetwork(created);

    return ApiResponse.success(created, statusCode: 201);
  }

  /// Fires a background POST to the API. If it succeeds, the server-assigned
  /// ID replaces the local one in persisted storage.
  void _syncCreatedIssueToNetwork(IssueModel created) {
    _apiClient.post(ApiConstants.issues, data: created.toJson()).then((response) {
      if (response.isSuccess && response.data != null) {
        try {
          final serverIssue = IssueModel.fromJson(response.data as Map<String, dynamic>);
          _loadPersistedIssues().then((persisted) {
            final idx = persisted.indexWhere((i) => i.id == created.id);
            if (idx != -1) {
              persisted[idx] = serverIssue;
              _persistIssues(persisted);
            }
          });
        } catch (_) {}
      }
    }).catchError((_) {
      // Network unavailable — local copy is already saved
    });
  }

  /// Updates an issue by [id].
  Future<ApiResponse<IssueModel>> updateIssue(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.issueDetail(id),
        data: data,
      );
      if (response.isSuccess && response.data != null) {
        final updated = IssueModel.fromJson(response.data as Map<String, dynamic>);
        // Update in persisted list if present
        final persisted = await _loadPersistedIssues();
        final idx = persisted.indexWhere((i) => i.id == id);
        if (idx != -1) {
          persisted[idx] = updated;
          await _persistIssues(persisted);
        }
        return ApiResponse.success(updated, statusCode: response.statusCode);
      }
    } catch (_) {
      // Fall through
    }

    final persisted = await _loadPersistedIssues();
    final idx = persisted.indexWhere((i) => i.id == id);
    if (idx != -1) {
      final existing = persisted[idx];
      final updated = existing.copyWith(
        status: data['status'] as String? ?? existing.status,
        priority: data['priority'] as String? ?? existing.priority,
        assignedTo: data['assignedTo'] as String? ?? existing.assignedTo,
      );
      persisted[idx] = updated;
      await _persistIssues(persisted);
      return ApiResponse.success(updated, statusCode: 200);
    }
    return ApiResponse.error('Failed to update issue', statusCode: 400);
  }

  /// Soft-deletes an issue by [id].
  Future<ApiResponse<bool>> deleteIssue(String id) async {
    try {
      final response = await _apiClient.delete(ApiConstants.issueDetail(id));
      if (response.isSuccess) {
        final persisted = await _loadPersistedIssues();
        persisted.removeWhere((i) => i.id == id);
        await _persistIssues(persisted);
        return ApiResponse.success(true, statusCode: response.statusCode);
      }
    } catch (_) {
      // Fall through
    }
    final persisted = await _loadPersistedIssues();
    persisted.removeWhere((i) => i.id == id);
    await _persistIssues(persisted);
    return ApiResponse.success(true, statusCode: 200);
  }
}
