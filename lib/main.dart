import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.assertConfigured();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    // publishableKey e anonKey sono equivalenti nell'SDK (publishableKey ?? anonKey):
    // accetta sia la anon key JWT sia la nuova publishable key.
    publishableKey: Env.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: App()));
}
