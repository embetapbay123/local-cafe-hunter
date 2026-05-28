import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'analytics/services/analytics_monitor_service.dart';
import 'app.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseService.initialize(
    url: dotenv.maybeGet('SUPABASE_URL'),
    publishableKey: dotenv.maybeGet('SUPABASE_PUBLISHABLE_KEY'),
  );

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(
      AnalyticsMonitorService.instance.recordError(
        details.exception,
        stackTrace: details.stack,
        context: 'flutter_error',
      ),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(
      AnalyticsMonitorService.instance.recordError(
        error,
        stackTrace: stack,
        context: 'platform_error',
      ),
    );
    return true;
  };

  unawaited(
    AnalyticsMonitorService.instance.recordAppEvent(
      'app_launch',
      details: {
        'supabase': SupabaseService.isInitialized ? 'true' : 'false',
      },
    ),
  );
  runApp(const LocalCafeHunterApp());
}
