import 'package:flutter/foundation.dart';

import '../models/analytics_event.dart';
import '../services/analytics_monitor_service.dart';

class AnalyticsMonitorViewModel extends ChangeNotifier {
  AnalyticsMonitorViewModel([AnalyticsMonitorService? service])
      : _service = service ?? AnalyticsMonitorService.instance;

  final AnalyticsMonitorService _service;

  bool _isLoading = true;
  List<AnalyticsEvent> _events = const [];

  bool get isLoading => _isLoading;
  List<AnalyticsEvent> get events => List<AnalyticsEvent>.unmodifiable(_events);
  int get totalEvents => _events.length;
  int get errorCount => _events.where((event) => event.isError).length;
  int get actionCount =>
      _events.where((event) => event.type == AnalyticsEventType.action).length;
  int get screenCount =>
      _events.where((event) => event.type == AnalyticsEventType.screen).length;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _events = await _service.loadEvents();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordAppEvent(
    String name, {
    Map<String, String> details = const {},
  }) async {
    await _service.recordAppEvent(name, details: details);
    await load();
  }

  Future<void> recordScreenView(
    String name, {
    Map<String, String> details = const {},
  }) async {
    await _service.recordScreenView(name, details: details);
    await load();
  }

  Future<void> recordAction(
    String name, {
    Map<String, String> details = const {},
  }) async {
    await _service.recordAction(name, details: details);
    await load();
  }

  Future<void> recordError(
    Object error, {
    StackTrace? stackTrace,
    String context = 'unknown',
  }) async {
    await _service.recordError(
      error,
      stackTrace: stackTrace,
      context: context,
    );
    await load();
  }

  Future<void> clear() async {
    await _service.clear();
    await load();
  }
}
