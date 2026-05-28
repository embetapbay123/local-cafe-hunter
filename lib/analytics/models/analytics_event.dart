enum AnalyticsEventType { app, screen, action, error }

class AnalyticsEvent {
  const AnalyticsEvent({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    this.details = const {},
    this.severity = 'info',
  });

  final String id;
  final String name;
  final AnalyticsEventType type;
  final DateTime createdAt;
  final Map<String, String> details;
  final String severity;

  bool get isError => type == AnalyticsEventType.error;

  AnalyticsEvent copyWith({
    String? id,
    String? name,
    AnalyticsEventType? type,
    DateTime? createdAt,
    Map<String, String>? details,
    String? severity,
  }) {
    return AnalyticsEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      details: details ?? this.details,
      severity: severity ?? this.severity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'details': details,
      'severity': severity,
    };
  }

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    final rawDetails = json['details'];
    return AnalyticsEvent(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: AnalyticsEventType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => AnalyticsEventType.app,
      ),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      details: rawDetails is Map
          ? rawDetails.map(
              (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
            )
          : const {},
      severity: json['severity']?.toString() ?? 'info',
    );
  }
}
