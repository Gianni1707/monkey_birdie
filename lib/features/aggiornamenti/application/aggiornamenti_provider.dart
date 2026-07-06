import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/versione_locale.dart';
import '../../../data/models/app_versione.dart';
import '../../../data/repositories/app_versione_repository.dart';

/// Ritorna l'aggiornamento disponibile (build remoto > locale) oppure null.
///
/// - Disattivato sul web/PWA (`kIsWeb` → null): la web si aggiorna da sola.
/// - Fail-safe: qualunque errore (offline, tabella assente, parsing) → null,
///   così non disturbiamo mai l'utente.
final controlloAggiornamentiProvider =
    FutureProvider<AppVersione?>((ref) async {
  if (kIsWeb) return null;
  try {
    final remota = await ref.read(appVersioneRepositoryProvider).ultima();
    if (remota == null) return null;
    return remota.build > kBuildApp ? remota : null;
  } catch (_) {
    return null;
  }
});
