class FloorModel {
  final String id;
  final String buildingId;
  final String name;
  final int? level;

  const FloorModel({
    required this.id,
    required this.buildingId,
    required this.name,
    this.level,
  });

  factory FloorModel.fromJson(Map<String, dynamic> json) {
    return FloorModel(
      id: json['id'] as String? ?? '',
      buildingId: json['buildingId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      level: json['level'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buildingId': buildingId,
      'name': name,
      if (level != null) 'level': level,
    };
  }

  FloorModel copyWith({
    String? id,
    String? buildingId,
    String? name,
    int? level,
  }) {
    return FloorModel(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      name: name ?? this.name,
      level: level ?? this.level,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FloorModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          buildingId == other.buildingId &&
          name == other.name &&
          level == other.level;

  @override
  int get hashCode =>
      id.hashCode ^ buildingId.hashCode ^ name.hashCode ^ level.hashCode;

  @override
  String toString() =>
      'FloorModel(id: $id, buildingId: $buildingId, name: $name, level: $level)';
}
