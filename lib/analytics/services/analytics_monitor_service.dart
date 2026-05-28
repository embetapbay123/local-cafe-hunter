import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/analytics_event.dart';

class AnalyticsMonitorService {
  AnalyticsMonitorService._();

  static final AnalyticsMonitorService instance = AnalyticsMonitorService._();

  static const _storageKey = 'local_cafe_hunter.analytics.events';
  static const _maxEvents = 80;

  Future<List<AnalyticsEvent>> loadEvents() async {
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
          .map(
            (item) => AnalyticsEvent.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .where((item) => item.id.isNotEmpty)
          .toList()
        ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    } catch (_) {
      return const [];
    }
  }

  Future<void> recordAppEvent(
    String name, {
    Map<String, String> details = const {},
  }) async {
    await _record(
      AnalyticsEvent(
        id: 'analytics-${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        type: AnalyticsEventType.app,
        createdAt: DateTime.now(),
        details: details,
      ),
    );
  }

  Future<void> recordScreenView(
    String screenName, {
    Map<String, String> details = const {},
  }) async {
    await _record(
      AnalyticsEvent(
        id: 'analytics-${DateTime.now().microsecondsSinceEpoch}',
        name: screenName,
        type: AnalyticsEventType.screen,
        createdAt: DateTime.now(),
        details: details,
      ),
    );
  }

  Future<void> recordAction(
    String actionName, {
    Map<String, String> details = const {},
  }) async {
    await _record(
      AnalyticsEvent(
        id: 'analytics-${DateTime.now().microsecondsSinceEpoch}',
        name: actionName,
        type: AnalyticsEventType.action,
        createdAt: DateTime.now(),
        details: details,
      ),
    );
  }

  Future<void> recordError(
    Object error, {
    StackTrace? stackTrace,
    String context = 'unknown',
  }) async {
    final details = <String, String>{
      'context': context,
      'error': error.toString(),
      if (stackTrace != null) 'stack': stackTrace.toString(),
    };
    await _record(
      AnalyticsEvent(
        id: 'analytics-${DateTime.now().microsecondsSinceEpoch}',
        name: 'error',
        type: AnalyticsEventType.error,
        createdAt: DateTime.now(),
        details: details,
        severity: 'critical',
      ),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<int> countErrors() async {
    final events = await loadEvents();
    return events.where((item) => item.isError).length;
  }

  Future<int> countEvents() async {
    return (await loadEvents()).length;
  }

  Future<void> _record(AnalyticsEvent event) async {
    final events = await loadEvents();
    final updated = [event, ...events].take(_maxEvents).toList();
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(updated.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
