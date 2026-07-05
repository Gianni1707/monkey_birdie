import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failure.dart';
import '../models/desiderio.dart';
import '../supabase/supabase_providers.dart';

/// Lista desideri (UT07): specie che l'utente vuole ancora avvistare. Tabella
/// `lista_desideri(utente_id, specie_id, note, ...)`, `unique(utente_id,
/// specie_id)`, RLS `for all` sui propri. Nessuna RPC: CRUD via PostgREST.
class ListaDesideriRepository {
  ListaDesideriRepository(this._client);
  final SupabaseClient _client;

  /// I propri desideri (specie completa via embedding), dal più recente.
  Future<List<Desiderio>> lista() async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw const AuthFailure('Sessione non valida.');
      final rows = await _client
          .from('lista_desideri')
          .select('note, aggiunto_il, specie:specie_id(*)')
          .eq('utente_id', uid)
          .order('aggiunto_il', ascending: false);
      return rows.map((j) => Desiderio.fromJson(j)).toList(growable: false);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Aggiunge una specie ai desideri. Idempotente (unique -> ignore duplicati).
  Future<void> aggiungi(String specieId, {String? note}) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw const AuthFailure('Sessione non valida.');
      await _client.from('lista_desideri').upsert(
        {
          'utente_id': uid,
          'specie_id': specieId,
          if (note != null && note.isNotEmpty) 'note': note,
        },
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
          .from('lista_desideri')
          .delete()
          .eq('utente_id', uid)
          .eq('specie_id', specieId);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Aggiorna/azzera la nota di una specie già nei desideri.
  Future<void> aggiornaNota(String specieId, String? note) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw const AuthFailure('Sessione non valida.');
      await _client
          .from('lista_desideri')
          .update({'note': (note == null || note.isEmpty) ? null : note})
          .eq('utente_id', uid)
          .eq('specie_id', specieId);
    } catch (e) {
      throw mapError(e);
    }
  }
}

final listaDesideriRepositoryProvider =
    Provider<ListaDesideriRepository>((ref) {
  return ListaDesideriRepository(ref.watch(supabaseClientProvider));
});
