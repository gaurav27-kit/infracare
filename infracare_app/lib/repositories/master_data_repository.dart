import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../core/network/api_response.dart';
import '../models/building_model.dart';
import '../models/floor_model.dart';
import '../models/space_model.dart';
import '../models/asset_model.dart';

class MasterDataRepository {
  final ApiClient _apiClient;

  MasterDataRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  // ---------------------------------------------------------------------------
  // Default Master Data (AIML Department Scoped Fallback & Offline Capability)
  // ---------------------------------------------------------------------------
  static final List<BuildingModel> _fallbackBuildings = [
    const BuildingModel(id: 'BLD-AIML', name: 'AIML Building', code: 'AIML-BLD'),
  ];

  static final List<FloorModel> _fallbackFloors = [
    const FloorModel(id: 'FLR-AIML-01', buildingId: 'BLD-AIML', name: '1st Floor', level: 1),
    const FloorModel(id: 'FLR-AIML-02', buildingId: 'BLD-AIML', name: '2nd Floor', level: 2),
  ];

  static final List<SpaceModel> _fallbackSpaces = [
    // 1st Floor
    const SpaceModel(id: 'SPC-AIML-01', floorId: 'FLR-AIML-01', name: 'Apple Lab', roomNumber: 'APPLE-LAB'),
    const SpaceModel(id: 'SPC-AIML-02', floorId: 'FLR-AIML-01', name: 'CSAM Lab 02', roomNumber: 'CSAM-LAB-02'),
    const SpaceModel(id: 'SPC-AIML-03', floorId: 'FLR-AIML-01', name: 'CSAM Lab 03', roomNumber: 'CSAM-LAB-03'),
    const SpaceModel(id: 'SPC-AIML-04', floorId: 'FLR-AIML-01', name: 'UPS Room', roomNumber: 'UPS-ROOM-L1'),
    const SpaceModel(id: 'SPC-AIML-05', floorId: 'FLR-AIML-01', name: 'CSAM CR-02', roomNumber: 'CSAM-CR-02'),
    const SpaceModel(id: 'SPC-AIML-06', floorId: 'FLR-AIML-01', name: 'CSAM CR-03', roomNumber: 'CSAM-CR-03'),
    const SpaceModel(id: 'SPC-AIML-07', floorId: 'FLR-AIML-01', name: 'CSAM CR-04', roomNumber: 'CSAM-CR-04'),
    const SpaceModel(id: 'SPC-AIML-08', floorId: 'FLR-AIML-01', name: 'CSAM CR-05', roomNumber: 'CSAM-CR-05'),
    const SpaceModel(id: 'SPC-AIML-09', floorId: 'FLR-AIML-01', name: 'CSAM CR-06', roomNumber: 'CSAM-CR-06'),
    const SpaceModel(id: 'SPC-AIML-10', floorId: 'FLR-AIML-01', name: 'CSAM Lab 04', roomNumber: 'CSAM-LAB-04'),
    const SpaceModel(id: 'SPC-AIML-11', floorId: 'FLR-AIML-01', name: 'CSDS Lab 01', roomNumber: 'CSDS-LAB-01'),
    const SpaceModel(id: 'SPC-AIML-12', floorId: 'FLR-AIML-01', name: 'Washroom', roomNumber: 'WASHROOM-L1'),

    // 2nd Floor
    const SpaceModel(id: 'SPC-AIML-13', floorId: 'FLR-AIML-02', name: 'CSAM CR-01', roomNumber: 'CSAM-CR-01'),
    const SpaceModel(id: 'SPC-AIML-14', floorId: 'FLR-AIML-02', name: 'CSDS CR-01', roomNumber: 'CSDS-CR-01'),
    const SpaceModel(id: 'SPC-AIML-15', floorId: 'FLR-AIML-02', name: 'CBCR-06', roomNumber: 'ETCR-04'),
    const SpaceModel(id: 'SPC-AIML-16', floorId: 'FLR-AIML-02', name: 'Washroom', roomNumber: 'WASHROOM-L2'),
  ];

  static final List<AssetModel> _fallbackAssets = [
    const AssetModel(id: 'AST-PROJECTOR', spaceId: '', name: 'Projector', category: 'IT & Audio/Visual'),
    const AssetModel(id: 'AST-AC', spaceId: '', name: 'Air Conditioner (AC)', category: 'HVAC & Climate Control'),
    const AssetModel(id: 'AST-ELEC-PANEL', spaceId: '', name: 'Electrical Panel', category: 'Electrical & Power'),
    const AssetModel(id: 'AST-UPS', spaceId: '', name: 'UPS System', category: 'Electrical & Power'),
    const AssetModel(id: 'AST-LIGHTING', spaceId: '', name: 'Lighting Fixture', category: 'Electrical & Power'),
    const AssetModel(id: 'AST-CUSTOM', spaceId: '', name: 'Other / Custom Asset', category: 'Other'),
  ];

  // ---------------------------------------------------------------------------
  // LOCAL-FIRST methods — return instant results from in-memory data
  // ---------------------------------------------------------------------------

  /// Returns buildings instantly from in-memory fallback — no network wait.
  List<BuildingModel> getBuildingsLocal() => _fallbackBuildings;

  /// Returns floors for [buildingId] instantly from in-memory fallback.
  List<FloorModel> getFloorsLocal({required String buildingId}) {
    if (buildingId.isEmpty) return _fallbackFloors;
    final filtered = _fallbackFloors.where((f) => f.buildingId == buildingId).toList();
    if (filtered.isNotEmpty) return filtered;
    return [
      FloorModel(id: '${buildingId}_FLR_1', buildingId: buildingId, name: '1st Floor', level: 1),
      FloorModel(id: '${buildingId}_FLR_2', buildingId: buildingId, name: '2nd Floor', level: 2),
    ];
  }

  /// Returns spaces for [floorId] instantly from in-memory fallback.
  List<SpaceModel> getSpacesLocal({required String floorId}) {
    if (floorId.isEmpty) return [];
    final filtered = _fallbackSpaces.where((s) => s.floorId == floorId).toList();
    if (filtered.isNotEmpty) return filtered;

    // Detect if 2nd Floor is selected based on ID string
    final isSecondFloor = floorId.endsWith('2') ||
        floorId.toLowerCase().contains('2nd') ||
        floorId.toLowerCase().contains('flr_2');

    if (isSecondFloor) {
      return _fallbackSpaces.where((s) => s.floorId == 'FLR-AIML-02').toList();
    }
    return _fallbackSpaces.where((s) => s.floorId == 'FLR-AIML-01').toList();
  }

  /// Returns the exact predefined asset options.
  List<AssetModel> getAssetsLocal({required String spaceId}) {
    return _fallbackAssets;
  }

  // ---------------------------------------------------------------------------
  // NETWORK methods — used only for background refresh
  // ---------------------------------------------------------------------------

  /// Fetches all active buildings from the network (background refresh only).
  Future<ApiResponse<List<BuildingModel>>> getBuildings() async {
    try {
      final response = await _apiClient.get(ApiConstants.masterBuildings);
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List<dynamic>
            : (response.data['data'] as List<dynamic>? ?? []);
        if (list.isNotEmpty) {
          final buildings = list
              .map((e) => BuildingModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return ApiResponse.success(buildings, statusCode: response.statusCode);
        }
      }
    } catch (_) {
      // Fall through
    }
    return ApiResponse.success(_fallbackBuildings, statusCode: 200);
  }

  /// Fetches floors filtered by [buildingId] from the network (background refresh only).
  Future<ApiResponse<List<FloorModel>>> getFloors({String? buildingId}) async {
    if (buildingId == null || buildingId.isEmpty) {
      return ApiResponse.success(_fallbackFloors, statusCode: 200);
    }
    try {
      final query = <String, dynamic>{'buildingId': buildingId, 'limit': 50};
      final response = await _apiClient.get(
        ApiConstants.masterFloors,
        queryParameters: query,
      );
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List<dynamic>
            : (response.data['data'] as List<dynamic>? ?? []);
        if (list.isNotEmpty) {
          final floors = list
              .map((e) => FloorModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return ApiResponse.success(floors, statusCode: response.statusCode);
        }
      }
    } catch (_) {
      // Fall through
    }
    return ApiResponse.success(getFloorsLocal(buildingId: buildingId), statusCode: 200);
  }

  /// Fetches spaces filtered by [floorId] from the network (background refresh only).
  Future<ApiResponse<List<SpaceModel>>> getSpaces({String? floorId}) async {
    if (floorId == null || floorId.isEmpty) {
      return ApiResponse.success([], statusCode: 200);
    }
    try {
      final query = <String, dynamic>{'floorId': floorId, 'limit': 100};
      final response = await _apiClient.get(
        ApiConstants.masterSpaces,
        queryParameters: query,
      );
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List<dynamic>
            : (response.data['data'] as List<dynamic>? ?? []);
        if (list.isNotEmpty) {
          final spaces = list
              .map((e) => SpaceModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return ApiResponse.success(spaces, statusCode: response.statusCode);
        }
      }
    } catch (_) {
      // Fall through
    }
    return ApiResponse.success(getSpacesLocal(floorId: floorId), statusCode: 200);
  }

  /// Returns the exact predefined asset options.
  Future<ApiResponse<List<AssetModel>>> getAssets({String? spaceId}) async {
    return ApiResponse.success(_fallbackAssets, statusCode: 200);
  }
}
