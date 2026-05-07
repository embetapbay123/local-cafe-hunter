import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static SupabaseClient? get client =>
      _initialized ? Supabase.instance.client : null;

  static String? get missingConfigMessage {
    if (_initialized) return null;
    return 'Supabase is not configured. Add SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY to .env.';
  }

  static Future<void> initialize({
    required String? url,
    required String? publishableKey,
  }) async {
    final resolvedUrl = url?.trim() ?? '';
    final resolvedKey = publishableKey?.trim() ?? '';
    if (resolvedUrl.isEmpty || resolvedKey.isEmpty) {
      debugPrint(
        'Supabase is not configured. Missing SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY.',
      );
      return;
    }

    await Supabase.initialize(
      url: resolvedUrl,
      anonKey: resolvedKey,
    );
    _initialized = true;
  }
}
