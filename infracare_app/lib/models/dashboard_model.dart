class DashboardModel {
  final int? openCount;
  final int? inProgressCount;
  final int? resolvedCount;
  final int? criticalCount;
  final String? systemStatus;

  const DashboardModel({
    this.openCount,
    this.inProgressCount,
    this.resolvedCount,
    this.criticalCount,
    this.systemStatus,
  });

  const DashboardModel.empty()
      : openCount = null,
        inProgressCount = null,
        resolvedCount = null,
        criticalCount = null,
        systemStatus = null;

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      openCount: json['openCount'] as int?,
      inProgressCount: json['inProgressCount'] as int?,
      resolvedCount: json['resolvedCount'] as int?,
      criticalCount: json['criticalCount'] as int?,
      systemStatus: json['systemStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (openCount != null) 'openCount': openCount,
      if (inProgressCount != null) 'inProgressCount': inProgressCount,
      if (resolvedCount != null) 'resolvedCount': resolvedCount,
      if (criticalCount != null) 'criticalCount': criticalCount,
      if (systemStatus != null) 'systemStatus': systemStatus,
    };
  }

  DashboardModel copyWith({
    int? openCount,
    int? inProgressCount,
    int? resolvedCount,
    int? criticalCount,
    String? systemStatus,
  }) {
    return DashboardModel(
      openCount: openCount ?? this.openCount,
      inProgressCount: inProgressCount ?? this.inProgressCount,
      resolvedCount: resolvedCount ?? this.resolvedCount,
      criticalCount: criticalCount ?? this.criticalCount,
      systemStatus: systemStatus ?? this.systemStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardModel &&
          runtimeType == other.runtimeType &&
          openCount == other.openCount &&
          inProgressCount == other.inProgressCount &&
          resolvedCount == other.resolvedCount &&
          criticalCount == other.criticalCount &&
          systemStatus == other.systemStatus;

  @override
  int get hashCode =>
      openCount.hashCode ^
      inProgressCount.hashCode ^
      resolvedCount.hashCode ^
      criticalCount.hashCode ^
      systemStatus.hashCode;

  @override
  String toString() =>
      'DashboardModel(openCount: $openCount, inProgressCount: $inProgressCount, resolvedCount: $resolvedCount, criticalCount: $criticalCount, systemStatus: $systemStatus)';
}
