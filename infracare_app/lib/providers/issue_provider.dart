import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/issue_model.dart';
import '../repositories/issue_repository.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

final issueRepositoryProvider = Provider<IssueRepository>((ref) {
  return IssueRepository();
});

// ---------------------------------------------------------------------------
// My Issues Provider
// ---------------------------------------------------------------------------

/// Provides the list of issues reported by the current user.
final myIssuesProvider =
    AsyncNotifierProvider<MyIssuesNotifier, List<IssueModel>>(
  MyIssuesNotifier.new,
);

class MyIssuesNotifier extends AsyncNotifier<List<IssueModel>> {
  String? _currentSearch;
  String? _currentStatus;

  @override
  Future<List<IssueModel>> build() async {
    final repo = ref.read(issueRepositoryProvider);
    // Return local data immediately — no network wait
    final local = await repo.getIssuesLocal();
    final filtered = _applyFilters(local, _currentSearch, _currentStatus);
    // Refresh from network silently in background
    _backgroundRefresh(repo);
    return filtered;
  }

  void _backgroundRefresh(IssueRepository repo) {
    repo.getIssues(
      search: _currentSearch,
      status: _currentStatus,
    ).then((response) {
      if (response.isSuccess && response.data != null) {
        state = AsyncData(response.data!);
      }
    }).catchError((_) {});
  }

  List<IssueModel> _applyFilters(
    List<IssueModel> issues,
    String? search,
    String? status,
  ) {
    var results = issues;
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      results = results
          .where((i) =>
              i.title.toLowerCase().contains(q) ||
              i.description.toLowerCase().contains(q) ||
              i.id.toLowerCase().contains(q))
          .toList();
    }
    if (status != null && status.isNotEmpty && status != 'All') {
      results = results
          .where((i) => i.status.toUpperCase() == status.toUpperCase())
          .toList();
    }
    return results;
  }

  /// Refreshes list without flashing a loading skeleton.
  Future<void> refresh({String? search, String? status}) async {
    _currentSearch = search;
    _currentStatus = status;
    final repo = ref.read(issueRepositoryProvider);
    // Show local data immediately if not already loaded
    if (!state.hasValue) {
      final local = await repo.getIssuesLocal();
      state = AsyncData(_applyFilters(local, search, status));
    }
    // Refresh from network in background
    _backgroundRefresh(repo);
  }

  /// Submits a new issue report and updates the state on success.
  Future<IssueModel> submitIssue(IssueModel draft) async {
    final repo = ref.read(issueRepositoryProvider);
    final response = await repo.createIssue(draft);
    if (response.isSuccess && response.data != null) {
      final created = response.data!;
      final currentList = state.valueOrNull ?? [];
      state = AsyncData([created, ...currentList]);
      return created;
    }
    throw Exception(response.message ?? 'Failed to submit issue');
  }
}

// ---------------------------------------------------------------------------
// Issue Detail Provider
// ---------------------------------------------------------------------------

/// Family provider that loads the full detail of a single issue by ID.
final issueDetailProvider = AsyncNotifierProviderFamily<
    IssueDetailNotifier, IssueModel, String>(
  IssueDetailNotifier.new,
);

class IssueDetailNotifier
    extends FamilyAsyncNotifier<IssueModel, String> {
  @override
  Future<IssueModel> build(String arg) async {
    if (arg.isEmpty) {
      throw Exception('Invalid issue ID');
    }
    final repo = ref.read(issueRepositoryProvider);
    final response = await repo.getIssueById(arg);
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message ?? 'Issue not found');
  }

  /// Forces a re-fetch of this issue's details.
  Future<void> refresh() => update((_) => build(arg));
}

// ---------------------------------------------------------------------------
// Issue Submit Form State
// ---------------------------------------------------------------------------

/// Holds the transient form state for the Report Issue wizard.
class IssueFormState {
  // Step 1 — Location & Asset
  final String? building;
  final String? buildingId;
  final String? floor;
  final String? floorId;
  final String? space;
  final String? spaceId;
  final String? asset;
  final String? assetId;
  final String? customAssetName;

  // Step 2 — Details
  final String title;
  final String description;
  final String priority;
  final int attachedPhotoCount;

  // Wizard position & status
  final int currentStep;
  final bool isSubmitting;

  const IssueFormState({
    this.building,
    this.buildingId,
    this.floor,
    this.floorId,
    this.space,
    this.spaceId,
    this.asset,
    this.assetId,
    this.customAssetName,
    this.title = '',
    this.description = '',
    this.priority = 'Medium',
    this.attachedPhotoCount = 0,
    this.currentStep = 0,
    this.isSubmitting = false,
  });

  bool get isCustomAsset => asset == 'Other / Custom Asset';

  bool get isStep1Valid {
    if (buildingId == null || buildingId!.isEmpty) return false;
    if (floorId == null || floorId!.isEmpty) return false;
    if (spaceId == null || spaceId!.isEmpty) return false;
    if (isCustomAsset && (customAssetName == null || customAssetName!.trim().isEmpty)) {
      return false;
    }
    return true;
  }

  bool get isStep2Valid => title.trim().isNotEmpty && description.trim().isNotEmpty;

  IssueFormState copyWith({
    String? building,
    String? buildingId,
    String? floor,
    String? floorId,
    String? space,
    String? spaceId,
    String? asset,
    String? assetId,
    String? customAssetName,
    String? title,
    String? description,
    String? priority,
    int? attachedPhotoCount,
    int? currentStep,
    bool? isSubmitting,
    bool clearFloor = false,
    bool clearSpace = false,
    bool clearAsset = false,
    bool clearCustomAsset = false,
  }) {
    return IssueFormState(
      building: building ?? this.building,
      buildingId: buildingId ?? this.buildingId,
      floor: clearFloor ? null : (floor ?? this.floor),
      floorId: clearFloor ? null : (floorId ?? this.floorId),
      space: (clearFloor || clearSpace) ? null : (space ?? this.space),
      spaceId: (clearFloor || clearSpace) ? null : (spaceId ?? this.spaceId),
      asset: (clearFloor || clearSpace || clearAsset) ? null : (asset ?? this.asset),
      assetId: (clearFloor || clearSpace || clearAsset) ? null : (assetId ?? this.assetId),
      customAssetName: (clearFloor || clearSpace || clearAsset || clearCustomAsset)
          ? null
          : (customAssetName ?? this.customAssetName),
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      attachedPhotoCount: attachedPhotoCount ?? this.attachedPhotoCount,
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// Auto-disposing notifier for the Report Issue wizard form.
final issueFormProvider =
    NotifierProvider.autoDispose<IssueFormNotifier, IssueFormState>(
  IssueFormNotifier.new,
);

class IssueFormNotifier extends AutoDisposeNotifier<IssueFormState> {
  @override
  IssueFormState build() => const IssueFormState();

  // Step navigation
  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  // Step 1 — Location with cascading reset:
  // Changing Building clears Floor, Space, Asset, Custom Asset
  void setBuilding(String? name, String? id) {
    state = state.copyWith(
      building: name,
      buildingId: id,
      clearFloor: true,
      clearSpace: true,
      clearAsset: true,
      clearCustomAsset: true,
    );
  }

  // Changing Floor clears Space, Asset, Custom Asset
  void setFloor(String? name, String? id) {
    state = state.copyWith(
      floor: name,
      floorId: id,
      clearSpace: true,
      clearAsset: true,
      clearCustomAsset: true,
    );
  }

  // Changing Space clears Asset, Custom Asset
  void setSpace(String? name, String? id) {
    state = state.copyWith(
      space: name,
      spaceId: id,
      clearAsset: true,
      clearCustomAsset: true,
    );
  }

  void setAsset(String? name, String? id) {
    state = state.copyWith(
      asset: name,
      assetId: id,
      customAssetName: name == 'Other / Custom Asset' ? state.customAssetName : null,
      clearCustomAsset: name != 'Other / Custom Asset',
    );
  }

  void setCustomAssetName(String? name) {
    state = state.copyWith(customAssetName: name);
  }

  // Step 2 — Details
  void setTitle(String v) => state = state.copyWith(title: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setPriority(String v) => state = state.copyWith(priority: v);
  void incrementPhotoCount() =>
      state = state.copyWith(attachedPhotoCount: state.attachedPhotoCount + 1);

  // Submission status
  void setSubmitting(bool v) => state = state.copyWith(isSubmitting: v);

  /// Resets the form to initial state.
  void reset() => state = const IssueFormState();
}
