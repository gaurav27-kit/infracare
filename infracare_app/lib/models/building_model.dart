class BuildingModel {
  final String id;
  final String name;
  final String? code;

  const BuildingModel({
    required this.id,
    required this.name,
    this.code,
  });

  factory BuildingModel.fromJson(Map<String, dynamic> json) {
    return BuildingModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (code != null) 'code': code,
    };
  }

  BuildingModel copyWith({
    String? id,
    String? name,
    String? code,
  }) {
    return BuildingModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          code == other.code;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ code.hashCode;

  @override
  String toString() => 'BuildingModel(id: $id, name: $name, code: $code)';
}
