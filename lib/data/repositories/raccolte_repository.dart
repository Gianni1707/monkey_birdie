import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failure.dart';
import '../models/raccolta.dart';
import '../supabase/supabase_providers.dart';

/// Una riga del ponte N-N raccolte<->avvistamenti.
typedef Appartenenza = ({String raccoltaId, String avvistamentoId});

/// Accesso alle RACCOLTE (UT06) e al loro contenuto. Nessuna RPC: la RLS
/// esistente (`raccolte: gestisci le proprie`, `raccolte_avvistamenti: ...`)
/// consente CRUD diretto sui propri dati e blocca gli altrui.
class RaccolteRepository {
  RaccolteRepository(this._client);
  final SupabaseClient _client;

  Future<List<Raccolta>> mieRaccolte() async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw const AuthFailure('Sessione non valida.');
      final rows = await _client
          .from('raccolte')
          .select()
          .eq('utente_id', uid)
          .order('creata_il', ascending: false);
      return rows.map((j) => Raccolta.fromJson(j)).toList(growable: false);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Tutte le appartenenze delle PROPRIE raccolte (la RLS limita gia' alle
  /// proprie). Usato per anteprime, contenuto e stato dei check.
  Future<List<Appartenenza>> appartenenze() async {
    try {
      final rows = await _client
          .from('raccolte_avvistamenti')
          .select('raccolta_id, avvistamento_id');
      return rows.map((j) {
        return (
          raccoltaId: j['raccolta_id'] as String,
          avvistamentoId: j['avvistamento_id'] as String,
        );
      }).toList(growable: false);
    } catch (e) {
      throw mapError(e);
    }
  }

  Future<Raccolta> crea({required String nome, String? descrizione}) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw const AuthFailure('Sessione non valida.');
      final row = await _client
          .from('raccolte')
          .insert({
            'utente_id': uid,
            'nome': nome,
            'descrizione': descrizione,
          })
          .select()
          .single();
      return Raccolta.fromJson(row);
    } catch (e) {
      throw mapError(e);
    }
  }

  Future<void> rinomina({
    required String id,
    required String nome,
    String? descrizione,
  }) async {
    try {
      await _client
          .from('raccolte')
          .update({'nome': nome, 'descrizione': descrizione})
          .eq('id', id);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Elimina SOLO la raccolta (il ponte va in cascade); gli avvistamenti restano.
  Future<void> elimina(String id) async {
    try {
      await _client.from('raccolte').delete().eq('id', id);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Aggiunge un avvistamento a una raccolta. Idempotente: se gia' presente
  /// (PK composita) non fa nulla.
  Future<void> aggiungi({
    required String raccoltaId,
    required String avvistamentoId,
  }) async {
    try {
      await _client.from('raccolte_avvistamenti').upsert(
        {'raccolta_id': raccoltaId, 'avvistamento_id': avvistamentoId},
        onConflict: 'raccolta_id,avvistamento_id',
        ignoreDuplicates: true,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  Future<void> rimuovi({
    required String raccoltaId,
    required String avvistamentoId,
  }) async {
    try {
      await _client
          .from('raccolte_avvistamenti')
          .delete()
          .eq('raccolta_id', raccoltaId)
          .eq('avvistamento_id', avvistamentoId);
    } catch (e) {
      throw mapError(e);
    }
  }
}

final raccolteRepositoryProvider = Provider<RaccolteRepository>((ref) {
  return RaccolteRepository(ref.watch(supabaseClientProvider));
});
