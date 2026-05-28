enum InAppNotificationCategory { system, catalog, onboarding, preference }

class InAppNotification {
  const InAppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    this.isRead = false,
    this.dedupeKey,
  });

  final String id;
  final String title;
  final String body;
  final InAppNotificationCategory category;
  final DateTime createdAt;
  final bool isRead;
  final String? dedupeKey;

  bool get isUnread => !isRead;

  InAppNotification copyWith({
    String? id,
    String? title,
    String? body,
    InAppNotificationCategory? category,
    DateTime? createdAt,
    bool? isRead,
    String? dedupeKey,
  }) {
    return InAppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      dedupeKey: dedupeKey ?? this.dedupeKey,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'dedupeKey': dedupeKey,
    };
  }

  factory InAppNotification.fromJson(Map<String, dynamic> json) {
    return InAppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      category: InAppNotificationCategory.values.firstWhere(
        (value) => value.name == json['category'],
        orElse: () => InAppNotificationCategory.system,
      ),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      isRead: json['isRead'] == true,
      dedupeKey: json['dedupeKey']?.toString(),
    );
  }
}
