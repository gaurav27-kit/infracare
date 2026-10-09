class AssetModel {
  final String id;
  final String spaceId;
  final String name;
  final String? category;

  const AssetModel({
    required this.id,
    required this.spaceId,
    required this.name,
    this.category,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'] as String? ?? '',
      spaceId: json['spaceId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spaceId': spaceId,
      'name': name,
      if (category != null) 'category': category,
    };
  }

  AssetModel copyWith({
    String? id,
    String? spaceId,
    String? name,
    String? category,
  }) {
    return AssetModel(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      name: name ?? this.name,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          spaceId == other.spaceId &&
          name == other.name &&
          category == other.category;

  @override
  int get hashCode =>
      id.hashCode ^ spaceId.hashCode ^ name.hashCode ^ category.hashCode;

  @override
  String toString() =>
      'AssetModel(id: $id, spaceId: $spaceId, name: $name, category: $category)';
}
