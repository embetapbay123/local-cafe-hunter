import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseService.initialize(
    url: dotenv.maybeGet('SUPABASE_URL'),
    publishableKey: dotenv.maybeGet('SUPABASE_PUBLISHABLE_KEY'),
  );

  runApp(const LocalCafeHunterApp());
}
