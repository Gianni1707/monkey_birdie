import 'package:flutter/foundation.dart';
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

  // Recupero password (web): il link email riporta alla PWA con un marcatore
  // nell'URL (`type=recovery` in implicit, oppure un `code` in PKCE). Lo leggiamo
  // QUI, PRIMA di Supabase.initialize (che ripulisce l'URL) e a prescindere
  // dall'evento passwordRecovery — che con PKCE può non scattare. L'app non ha
  // altri flussi che tornano con un `code`, quindi è un marcatore affidabile.
  final bool recuperoDaLinkEmail = kIsWeb &&
      (Uri.base.toString().contains('type=recovery') ||
          Uri.base.queryParameters.containsKey('code'));

  Env.assertConfigured();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    // publishableKey e anonKey sono equivalenti nell'SDK (publishableKey ?? anonKey):
    // accetta sia la anon key JWT sia la nuova publishable key.
    publishableKey: Env.supabaseAnonKey,
  );

  // Attiva subito il flusso "nuova password" se siamo arrivati dal link email.
  if (recuperoDaLinkEmail) recuperoPasswordInCorso.value = true;

  // Backup: se in futuro il flusso emette l'evento passwordRecovery, lo cogliamo.
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
