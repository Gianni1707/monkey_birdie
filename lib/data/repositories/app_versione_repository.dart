import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_versione.dart';
import '../supabase/supabase_providers.dart';

/// Legge il "cartello" versione (tabella `app_versione`, riga singola id=1).
/// Sola lettura: nessuno scrive da client (aggiornata dal dashboard).
class AppVersioneRepository {
  AppVersioneRepository(this._client);
  final SupabaseClient _client;

  Future<AppVersione?> ultima() async {
    final row =
        await _client.from('app_versione').select().eq('id', 1).maybeSingle();
    if (row == null) return null;
    return AppVersione.fromJson(row);
  }
}

final appVersioneRepositoryProvider = Provider<AppVersioneRepository>((ref) {
  return AppVersioneRepository(ref.watch(supabaseClientProvider));
});
