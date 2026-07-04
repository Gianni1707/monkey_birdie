import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failure.dart';
import '../models/specie.dart';
import '../supabase/supabase_providers.dart';

/// Specie preferite dell'utente (UT09). Tabella `preferiti(utente_id,
/// specie_id)`; RLS `for all` sui propri. Ritorna le Specie complete via
/// embedding PostgREST (FK preferiti.specie_id -> specie).
class PreferitiRepository {
  PreferitiRepository(this._client);
  final SupabaseClient _client;

  Future<List<Specie>> preferiti() async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw const AuthFailure('Sessione non valida.');
      return _perUtente(uid);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Preferiti di un altro utente (profilo pubblico amico). La RLS (0008) li
  /// restituisce solo se `sono_amici`, altrimenti lista vuota.
  Future<List<Specie>> preferitiDi(String utenteId) async {
    try {
      return _perUtente(utenteId);
    } catch (e) {
      throw mapError(e);
    }
  }

  Future<List<Specie>> _perUtente(String utenteId) async {
    final rows = await _client
        .from('preferiti')
        .select('specie:specie_id(*)')
        .eq('utente_id', utenteId);
    return rows
        .map((j) => Specie.fromJson(j['specie'] as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Aggiunge ai preferiti. Idempotente (PK composita -> ignore duplicati).
  Future<void> aggiungi(String specieId) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw const AuthFailure('Sessione non valida.');
      await _client.from('preferiti').upsert(
        {'utente_id': uid, 'specie_id': specieId},
        onConflict: 'utente_id,specie_id',
        ignoreDuplicates: true,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  Future<void> rimuovi(String specieId) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw const AuthFailure('Sessione non valida.');
      await _client
          .from('preferiti')
          .delete()
          .eq('utente_id', uid)
          .eq('specie_id', specieId);
    } catch (e) {
      throw mapError(e);
    }
  }
}

final preferitiRepositoryProvider = Provider<PreferitiRepository>((ref) {
  return PreferitiRepository(ref.watch(supabaseClientProvider));
});
