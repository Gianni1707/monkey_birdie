import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failure.dart';
import '../models/profilo.dart';
import '../supabase/supabase_providers.dart';

/// Una relazione di amicizia vista dal MIO lato: l'altro utente, lo stato e se
/// la richiesta l'ho inviata io (`ioRichiedente`) o ricevuta.
class Relazione {
  const Relazione({
    required this.altro,
    required this.stato,
    required this.ioRichiedente,
  });
  final Profilo altro;
  final String stato; // in_attesa | accettata | rifiutata
  final bool ioRichiedente;
}

/// Amicizie e ricerca utenti (UT08). RLS: vedi solo le amicizie che ti
/// coinvolgono; INSERT solo come richiedente; update/delete se coinvolto. La
/// direzione (richiedente->destinatario) va rispettata per non violare la RLS.
class AmiciziaRepository {
  AmiciziaRepository(this._client);
  final SupabaseClient _client;

  String get _uid {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw const AuthFailure('Sessione non valida.');
    return uid;
  }

  /// Tutte le mie relazioni (la RLS filtra gia'), con il profilo dell'altro via
  /// embedding (amicizie ha due FK verso profili).
  Future<List<Relazione>> relazioni() async {
    try {
      final uid = _uid;
      final rows = await _client.from('amicizie').select(
            'richiedente_id, destinatario_id, stato, '
            'richiedente:richiedente_id(*), destinatario:destinatario_id(*)',
          );
      final out = <Relazione>[];
      for (final j in rows) {
        final ioRich = j['richiedente_id'] == uid;
        final altro = (ioRich ? j['destinatario'] : j['richiedente'])
            as Map<String, dynamic>?;
        if (altro == null) continue;
        out.add(
          Relazione(
            altro: Profilo.fromJson(altro),
            stato: j['stato'] as String,
            ioRichiedente: ioRich,
          ),
        );
      }
      return out;
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Cerca utenti per username (esclude sé stessi). Profili a lettura pubblica.
  Future<List<Profilo>> cercaUtenti(String query) async {
    final q = query.trim();
    if (q.length < 2) return const [];
    try {
      final rows = await _client
          .from('profili')
          .select()
          .ilike('username', '%$q%')
          .neq('id', _uid)
          .order('username')
          .limit(20);
      return rows.map((j) => Profilo.fromJson(j)).toList(growable: false);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Invia (o re-invia, se era rifiutata) una richiesta: io richiedente.
  Future<void> inviaRichiesta(String altroId) async {
    try {
      await _client.from('amicizie').upsert(
        {
          'richiedente_id': _uid,
          'destinatario_id': altroId,
          'stato': 'in_attesa',
        },
        onConflict: 'richiedente_id,destinatario_id',
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  Future<void> accetta(String richiedenteId) =>
      _rispondi(richiedenteId, 'accettata');

  Future<void> rifiuta(String richiedenteId) =>
      _rispondi(richiedenteId, 'rifiutata');

  Future<void> _rispondi(String richiedenteId, String stato) async {
    try {
      await _client
          .from('amicizie')
          .update({'stato': stato})
          .eq('richiedente_id', richiedenteId)
          .eq('destinatario_id', _uid);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Annulla una richiesta in USCITA (io richiedente).
  Future<void> annulla(String destinatarioId) async {
    try {
      await _client
          .from('amicizie')
          .delete()
          .eq('richiedente_id', _uid)
          .eq('destinatario_id', destinatarioId);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Rimuove un'amicizia (riga in una delle due direzioni).
  Future<void> rimuovi(String altroId) async {
    try {
      final uid = _uid;
      await _client.from('amicizie').delete().or(
            'and(richiedente_id.eq.$uid,destinatario_id.eq.$altroId),'
            'and(richiedente_id.eq.$altroId,destinatario_id.eq.$uid)',
          );
    } catch (e) {
      throw mapError(e);
    }
  }
}

final amiciziaRepositoryProvider = Provider<AmiciziaRepository>((ref) {
  return AmiciziaRepository(ref.watch(supabaseClientProvider));
});
