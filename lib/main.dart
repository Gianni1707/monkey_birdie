import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/locale/locale_controller.dart';
import 'features/auth/application/recupero_password_stato.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.assertConfigured();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    // publishableKey e anonKey sono equivalenti nell'SDK (publishableKey ?? anonKey):
    // accetta sia la anon key JWT sia la nuova publishable key.
    publishableKey: Env.supabaseAnonKey,
  );

  // Recupero password: il link email apre la PWA e scatta l'evento
  // passwordRecovery. Ci iscriviamo QUI (prima di runApp) per non perderlo;
  // il router poi forza la schermata "nuova password" finché il flag è true.
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      recuperoPasswordInCorso.value = true;
    }
  });

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const App(),
    ),
  );
}
