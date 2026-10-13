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
    final map = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    int? open;
    int? inProgress;
    int? resolved;
    int? critical;

    if (map['status'] is Map) {
      final sMap = map['status'] as Map<String, dynamic>;
      final openVal = (sMap['OPEN'] as num? ?? 0).toInt() + (sMap['REPORTED'] as num? ?? 0).toInt();
      final inProgVal = (sMap['IN_PROGRESS'] as num? ?? 0).toInt() + (sMap['ASSIGNED'] as num? ?? 0).toInt();
      final resVal = (sMap['RESOLVED'] as num? ?? 0).toInt() + (sMap['CLOSED'] as num? ?? 0).toInt();
      open = openVal;
      inProgress = inProgVal;
      resolved = resVal;
    }

    if (map['priority'] is Map) {
      final pMap = map['priority'] as Map<String, dynamic>;
      critical = (pMap['CRITICAL'] as num? ?? 0).toInt() + (pMap['HIGH'] as num? ?? 0).toInt();
    }

    if (map['counts'] is Map) {
      final cMap = map['counts'] as Map<String, dynamic>;
      final total = (cMap['issues'] as num? ?? 0).toInt();
      open ??= total;
    }

    open ??= (map['openCount'] as num?)?.toInt() ?? (map['open'] as num?)?.toInt();
    inProgress ??= (map['inProgressCount'] as num?)?.toInt() ?? (map['inProgress'] as num?)?.toInt();
    resolved ??= (map['resolvedCount'] as num?)?.toInt() ?? (map['resolved'] as num?)?.toInt();
    critical ??= (map['criticalCount'] as num?)?.toInt() ?? (map['critical'] as num?)?.toInt();

    return DashboardModel(
      openCount: open,
      inProgressCount: inProgress,
      resolvedCount: resolved,
      criticalCount: critical,
      systemStatus: map['systemStatus'] as String? ?? 'All AIML systems operational & monitored.',
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
