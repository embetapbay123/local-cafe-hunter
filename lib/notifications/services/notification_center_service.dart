import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/in_app_notification.dart';

class NotificationCenterService {
  static const _storageKey = 'local_cafe_hunter.notifications.feed';

  Future<List<InAppNotification>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_storageKey);
    if (encoded == null || encoded.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((item) => InAppNotification.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ))
          .where((item) => item.id.isNotEmpty)
          .toList()
        ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    } catch (_) {
      return const [];
    }
  }

  Future<int> unreadCount() async {
    final notifications = await loadNotifications();
    return notifications.where((item) => item.isUnread).length;
  }

  Future<InAppNotification> recordNotification({
    required String title,
    required String body,
    required InAppNotificationCategory category,
    String? dedupeKey,
  }) async {
    final notifications = await loadNotifications();
    final notification = InAppNotification(
      id: 'notification-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      body: body,
      category: category,
      createdAt: DateTime.now(),
      dedupeKey: dedupeKey,
    );

    final updated = [
      notification,
      ...notifications.where((item) => item.dedupeKey != dedupeKey),
    ];

    await _saveNotifications(updated);
    return notification;
  }

  Future<void> recordCatalogSync({
    required bool usedFallback,
    required int cafeCount,
    required String sourceLabel,
  }) async {
    final title = usedFallback
        ? 'Catalog dang dung local seed'
        : 'Catalog da dong bo thanh cong';
    final body = usedFallback
        ? 'Supabase chua san sang, app da quay ve local seed voi $cafeCount quan cafe.'
        : 'Da tai $cafeCount quan cafe tu $sourceLabel.';

    await recordNotification(
      title: title,
      body: body,
      category: InAppNotificationCategory.catalog,
      dedupeKey: 'catalog-sync',
    );
  }

  Future<void> recordPreferenceEvent({
    required String title,
    required String body,
  }) async {
    await recordNotification(
      title: title,
      body: body,
      category: InAppNotificationCategory.preference,
    );
  }

  Future<void> recordOnboardingComplete() async {
    await recordNotification(
      title: 'Onboarding da hoan tat',
      body: 'Nguoi dung da sang trang chinh va co the tiep tuc kham pha app.',
      category: InAppNotificationCategory.onboarding,
      dedupeKey: 'onboarding-complete',
    );
  }

  Future<void> markAsRead(String id) async {
    final notifications = await loadNotifications();
    final updated = notifications.map((item) {
      if (item.id != id) return item;
      return item.copyWith(isRead: true);
    }).toList();
    await _saveNotifications(updated);
  }

  Future<void> markAllAsRead() async {
    final notifications = await loadNotifications();
    await _saveNotifications(
      notifications.map((item) => item.copyWith(isRead: true)).toList(),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _saveNotifications(List<InAppNotification> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = notifications.take(40).toList();
    final encoded = jsonEncode(trimmed.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
