import 'attachment_model.dart';

/// Data model representing a single infrastructure issue.
///
/// Campus field has been removed completely. Hierarchy starts from building.
class IssueModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String status;
  final String priority;
  final String reportedBy;
  final String reportedAt;
  final String? assignedTo;
  final String? building;
  final String? buildingId;
  final String? floor;
  final String? floorId;
  final String? space;
  final String? spaceId;
  final String? asset;
  final String? assetId;
  final String? customAssetName;
  final List<AttachmentModel> attachments;

  const IssueModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.status,
    required this.priority,
    required this.reportedBy,
    required this.reportedAt,
    this.assignedTo,
    this.building,
    this.buildingId,
    this.floor,
    this.floorId,
    this.space,
    this.spaceId,
    this.asset,
    this.assetId,
    this.customAssetName,
    this.attachments = const [],
  });

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    // Space and nested floor / building
    String? spaceName;
    String? spaceId = json['spaceId'] as String?;
    String? floorName;
    String? floorId = json['floorId'] as String?;
    String? buildingName;
    String? buildingId = json['buildingId'] as String?;

    if (json['space'] is Map) {
      final spaceMap = json['space'] as Map<String, dynamic>;
      spaceName = spaceMap['name'] as String?;
      spaceId ??= spaceMap['id'] as String?;

      if (spaceMap['floor'] is Map) {
        final floorMap = spaceMap['floor'] as Map<String, dynamic>;
        floorName ??= floorMap['name'] as String?;
        floorId ??= floorMap['id'] as String?;

        if (floorMap['building'] is Map) {
          final bldMap = floorMap['building'] as Map<String, dynamic>;
          buildingName ??= bldMap['name'] as String?;
          buildingId ??= bldMap['id'] as String?;
        }
      }
    } else if (json['space'] is String) {
      spaceName = json['space'] as String;
    }

    buildingName ??= json['building'] as String?;
    buildingId ??= json['buildingId'] as String?;
    floorName ??= json['floor'] as String?;
    floorId ??= json['floorId'] as String?;

    // Asset
    String? assetName;
    String? assetId = json['assetId'] as String?;
    if (json['asset'] is Map) {
      final assetMap = json['asset'] as Map<String, dynamic>;
      assetName = assetMap['name'] as String?;
      assetId ??= assetMap['id'] as String?;
    } else if (json['asset'] is String) {
      assetName = json['asset'] as String;
    }

    final customAssetName = json['customAssetName'] as String?;

    final rawLocation = json['location'] as String? ?? '';
    final location = rawLocation.isNotEmpty
        ? rawLocation
        : [buildingName, floorName, spaceName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' > ');

    final id = (json['issueNumber'] as String?)?.isNotEmpty == true
        ? json['issueNumber'] as String
        : (json['id'] as String? ?? '');

    return IssueModel(
      id: id,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: location,
      status: json['status'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      reportedBy: json['reportedBy'] as String? ??
          json['reporterExternalUserId'] as String? ??
          '',
      reportedAt: json['reportedAt'] as String? ??
          json['createdAt'] as String? ??
          '',
      assignedTo: json['assignedTo'] as String?,
      building: buildingName,
      buildingId: buildingId,
      floor: floorName,
      floorId: floorId,
      space: spaceName,
      spaceId: spaceId,
      asset: assetName,
      assetId: assetId,
      customAssetName: customAssetName,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  /// Converts this model to a JSON map for POST/PATCH API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'status': status,
      'priority': priority,
      'reportedBy': reportedBy,
      'reportedAt': reportedAt,
      if (assignedTo != null) 'assignedTo': assignedTo,
      if (building != null) 'building': building,
      if (buildingId != null) 'buildingId': buildingId,
      if (floor != null) 'floor': floor,
      if (floorId != null) 'floorId': floorId,
      if (space != null) 'space': space,
      if (spaceId != null) 'spaceId': spaceId,
      if (asset != null) 'asset': asset,
      if (assetId != null) 'assetId': assetId,
      if (customAssetName != null) 'customAssetName': customAssetName,
      'attachments': attachments.map((e) => e.toJson()).toList(),
    };
  }

  IssueModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? status,
    String? priority,
    String? reportedBy,
    String? reportedAt,
    String? assignedTo,
    String? building,
    String? buildingId,
    String? floor,
    String? floorId,
    String? space,
    String? spaceId,
    String? asset,
    String? assetId,
    String? customAssetName,
    List<AttachmentModel>? attachments,
  }) {
    return IssueModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedAt: reportedAt ?? this.reportedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      building: building ?? this.building,
      buildingId: buildingId ?? this.buildingId,
      floor: floor ?? this.floor,
      floorId: floorId ?? this.floorId,
      space: space ?? this.space,
      spaceId: spaceId ?? this.spaceId,
      asset: asset ?? this.asset,
      assetId: assetId ?? this.assetId,
      customAssetName: customAssetName ?? this.customAssetName,
      attachments: attachments ?? this.attachments,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          location == other.location &&
          status == other.status &&
          priority == other.priority &&
          reportedBy == other.reportedBy &&
          reportedAt == other.reportedAt &&
          assignedTo == other.assignedTo &&
          building == other.building &&
          buildingId == other.buildingId &&
          floor == other.floor &&
          floorId == other.floorId &&
          space == other.space &&
          spaceId == other.spaceId &&
          asset == other.asset &&
          assetId == other.assetId &&
          customAssetName == other.customAssetName;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      location.hashCode ^
      status.hashCode ^
      priority.hashCode ^
      reportedBy.hashCode ^
      reportedAt.hashCode ^
      assignedTo.hashCode ^
      building.hashCode ^
      buildingId.hashCode ^
      floor.hashCode ^
      floorId.hashCode ^
      space.hashCode ^
      spaceId.hashCode ^
      asset.hashCode ^
      assetId.hashCode ^
      customAssetName.hashCode;

  @override
  String toString() => 'IssueModel(id: $id, title: $title, status: $status)';
}
