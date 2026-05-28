import 'package:flutter/foundation.dart';

import '../models/in_app_notification.dart';
import '../services/notification_center_service.dart';

class NotificationCenterViewModel extends ChangeNotifier {
  NotificationCenterViewModel([NotificationCenterService? service])
      : _service = service ?? NotificationCenterService();

  final NotificationCenterService _service;

  bool _isLoading = true;
  List<InAppNotification> _notifications = const [];

  bool get isLoading => _isLoading;
  List<InAppNotification> get notifications =>
      List<InAppNotification>.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((item) => item.isUnread).length;
  bool get hasUnread => unreadCount > 0;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _service.loadNotifications();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordCatalogSync({
    required bool usedFallback,
    required int cafeCount,
    required String sourceLabel,
  }) async {
    await _service.recordCatalogSync(
      usedFallback: usedFallback,
      cafeCount: cafeCount,
      sourceLabel: sourceLabel,
    );
    await load();
  }

  Future<void> recordPreferenceEvent({
    required String title,
    required String body,
  }) async {
    await _service.recordPreferenceEvent(title: title, body: body);
    await load();
  }

  Future<void> recordOnboardingComplete() async {
    await _service.recordOnboardingComplete();
    await load();
  }

  Future<void> markAsRead(String id) async {
    await _service.markAsRead(id);
    await load();
  }

  Future<void> markAllAsRead() async {
    await _service.markAllAsRead();
    await load();
  }

  Future<void> clear() async {
    await _service.clear();
    await load();
  }

  InAppNotification? latestUnread() {
    for (final notification in _notifications) {
      if (notification.isUnread) return notification;
    }
    return null;
  }
}
