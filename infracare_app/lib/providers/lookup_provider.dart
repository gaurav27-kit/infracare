import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/building_model.dart';
import '../models/floor_model.dart';
import '../models/space_model.dart';
import '../models/asset_model.dart';
import '../repositories/master_data_repository.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

final masterDataRepositoryProvider = Provider<MasterDataRepository>((ref) {
  return MasterDataRepository();
});

// ---------------------------------------------------------------------------
// Buildings
// ---------------------------------------------------------------------------

/// Provides the list of all buildings.
/// Returns LOCAL data instantly, then silently refreshes from network.
final buildingsProvider =
    AsyncNotifierProvider<BuildingsNotifier, List<BuildingModel>>(
  BuildingsNotifier.new,
);

class BuildingsNotifier extends AsyncNotifier<List<BuildingModel>> {
  @override
  Future<List<BuildingModel>> build() async {
    final repo = ref.read(masterDataRepositoryProvider);
    // Return local data immediately — no network wait
    final local = repo.getBuildingsLocal();
    // Refresh from network in background (fire-and-forget)
    _backgroundRefresh(repo);
    return local;
  }

  /// Silently updates from network without flashing a loading state.
  void _backgroundRefresh(MasterDataRepository repo) {
    repo.getBuildings().then((response) {
      if (response.isSuccess && (response.data?.isNotEmpty ?? false)) {
        state = AsyncData(response.data!);
      }
    }).catchError((_) {});
  }

  /// Keeps existing data visible while fetching fresh data.
  Future<void> refresh() async {
    final repo = ref.read(masterDataRepositoryProvider);
    final fresh = await repo.getBuildings();
    if (fresh.isSuccess && (fresh.data?.isNotEmpty ?? false)) {
      state = AsyncData(fresh.data!);
    }
  }
}

// ---------------------------------------------------------------------------
// Floors
// ---------------------------------------------------------------------------

/// Provides floors for the selected [buildingId].
/// Returns LOCAL data instantly, then silently refreshes from network.
final floorsProvider =
    AsyncNotifierProviderFamily<FloorsNotifier, List<FloorModel>, String>(
  FloorsNotifier.new,
);

class FloorsNotifier extends FamilyAsyncNotifier<List<FloorModel>, String> {
  @override
  Future<List<FloorModel>> build(String arg) async {
    if (arg.isEmpty) return const [];
    final repo = ref.read(masterDataRepositoryProvider);
    // Return local data immediately — no network wait
    final local = repo.getFloorsLocal(buildingId: arg);
    // Refresh from network in background (fire-and-forget)
    _backgroundRefresh(repo, arg);
    return local;
  }

  void _backgroundRefresh(MasterDataRepository repo, String buildingId) {
    repo.getFloors(buildingId: buildingId).then((response) {
      if (response.isSuccess && (response.data?.isNotEmpty ?? false)) {
        state = AsyncData(response.data!);
      }
    }).catchError((_) {});
  }
}

// ---------------------------------------------------------------------------
// Spaces / Rooms
// ---------------------------------------------------------------------------

/// Provides spaces/rooms for the selected [floorId].
/// Returns LOCAL data instantly, then silently refreshes from network.
final spacesProvider =
    AsyncNotifierProviderFamily<SpacesNotifier, List<SpaceModel>, String>(
  SpacesNotifier.new,
);

class SpacesNotifier extends FamilyAsyncNotifier<List<SpaceModel>, String> {
  @override
  Future<List<SpaceModel>> build(String arg) async {
    if (arg.isEmpty) return const [];
    final repo = ref.read(masterDataRepositoryProvider);
    // Return local data immediately — no network wait
    final local = repo.getSpacesLocal(floorId: arg);
    // Refresh from network in background (fire-and-forget)
    _backgroundRefresh(repo, arg);
    return local;
  }

  void _backgroundRefresh(MasterDataRepository repo, String floorId) {
    repo.getSpaces(floorId: floorId).then((response) {
      if (response.isSuccess && (response.data?.isNotEmpty ?? false)) {
        state = AsyncData(response.data!);
      }
    }).catchError((_) {});
  }
}

// ---------------------------------------------------------------------------
// Assets
// ---------------------------------------------------------------------------

/// Provides assets for the selected [spaceId].
/// Returns LOCAL data instantly, then silently refreshes from network.
final assetsProvider =
    AsyncNotifierProviderFamily<AssetsNotifier, List<AssetModel>, String>(
  AssetsNotifier.new,
);

class AssetsNotifier extends FamilyAsyncNotifier<List<AssetModel>, String> {
  @override
  Future<List<AssetModel>> build(String arg) async {
    final repo = ref.read(masterDataRepositoryProvider);
    return repo.getAssetsLocal(spaceId: arg);
  }
}
