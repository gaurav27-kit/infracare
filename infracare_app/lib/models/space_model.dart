class SpaceModel {
  final String id;
  final String floorId;
  final String name;
  final String? roomNumber;

  const SpaceModel({
    required this.id,
    required this.floorId,
    required this.name,
    this.roomNumber,
  });

  factory SpaceModel.fromJson(Map<String, dynamic> json) {
    return SpaceModel(
      id: json['id'] as String? ?? '',
      floorId: json['floorId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      roomNumber: json['roomNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'floorId': floorId,
      'name': name,
      if (roomNumber != null) 'roomNumber': roomNumber,
    };
  }

  SpaceModel copyWith({
    String? id,
    String? floorId,
    String? name,
    String? roomNumber,
  }) {
    return SpaceModel(
      id: id ?? this.id,
      floorId: floorId ?? this.floorId,
      name: name ?? this.name,
      roomNumber: roomNumber ?? this.roomNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpaceModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          floorId == other.floorId &&
          name == other.name &&
          roomNumber == other.roomNumber;

  @override
  int get hashCode =>
      id.hashCode ^ floorId.hashCode ^ name.hashCode ^ roomNumber.hashCode;

  @override
  String toString() =>
      'SpaceModel(id: $id, floorId: $floorId, name: $name, roomNumber: $roomNumber)';
}
