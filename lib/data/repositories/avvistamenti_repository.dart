import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failure.dart';
import '../models/avvistamento.dart';
import '../supabase/supabase_providers.dart';

/// Lettura/scrittura degli avvistamenti.
/// - scrittura via RPC `inserisci_avvistamento` (costruisce il geography point)
/// - lettura via view `avvistamenti_dettaglio` (lat/lng piatti + dati specie)
class AvvistamentiRepository {
  AvvistamentiRepository(this._client);
  final SupabaseClient _client;

  Future<String> inserisci({
    required String specieId,
    required double lat,
    required double lng,
    double? confidenza,
    String? fotoUrl,
    String? audioUrl,
    bool condiviso = false,
  }) async {
    try {
      final id = await _client.rpc(
        'inserisci_avvistamento',
        params: {
          'p_specie_id': specieId,
          'p_lat': lat,
          'p_lng': lng,
          'p_confidenza': confidenza,
          'p_foto_url': fotoUrl,
          'p_audio_url': audioUrl,
          'p_condiviso': condiviso,
        },
      );
      return id as String;
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Collezione dell'utente corrente, dal piu' recente. La RLS limita gia'
  /// alle righe visibili; filtriamo comunque sull'utente per la "collezione".
  Future<List<AvvistamentoDettaglio>> mieiAvvistamenti() async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw const AuthFailure('Sessione non valida.');

      final rows = await _client
          .from('avvistamenti_dettaglio')
          .select()
          .eq('utente_id', uid)
          .order('avvistato_il', ascending: false);

      return rows
          .map((j) => AvvistamentoDettaglio.fromJson(j))
          .toList(growable: false);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Per la MAPPA (UT08): i propri + i condivisi degli amici. Nessun filtro
  /// utente: la RLS della view (`security_invoker`) restituisce gia' propri +
  /// `condiviso=true` di amici accettati.
  Future<List<AvvistamentoDettaglio>> perMappa() async {
    try {
      final rows = await _client
          .from('avvistamenti_dettaglio')
          .select()
          .order('avvistato_il', ascending: false);
      return rows
          .map((j) => AvvistamentoDettaglio.fromJson(j))
          .toList(growable: false);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Avvistamenti CONDIVISI di un altro utente (profilo pubblico amico): la RLS
  /// restituisce solo quelli con `condiviso=true` visibili.
  Future<List<AvvistamentoDettaglio>> condivisiDi(String utenteId) async {
    try {
      final rows = await _client
          .from('avvistamenti_dettaglio')
          .select()
          .eq('utente_id', utenteId)
          .order('avvistato_il', ascending: false);
      return rows
          .map((j) => AvvistamentoDettaglio.fromJson(j))
          .toList(growable: false);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Imposta il flag `condiviso` su TUTTI i propri avvistamenti (impostazione
  /// unica dal profilo). RLS: modifica solo i propri.
  Future<void> impostaCondivisoTutti(bool condiviso) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw const AuthFailure('Sessione non valida.');
      await _client
          .from('avvistamenti')
          .update({'condiviso': condiviso}).eq('utente_id', uid);
    } catch (e) {
      throw mapError(e);
    }
  }
}

final avvistamentiRepositoryProvider = Provider<AvvistamentiRepository>((ref) {
  return AvvistamentiRepository(ref.watch(supabaseClientProvider));
});
