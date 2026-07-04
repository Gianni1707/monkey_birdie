import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/profilo.dart';
import '../../../data/repositories/amicizia_repository.dart';

/// Stato della relazione con un dato utente, dal MIO punto di vista.
enum StatoRelazione { nessuna, inviata, ricevuta, amici }

/// Tutte le mie relazioni (sorgente di verita'); i derivati sotto ne dipendono.
final relazioniProvider = FutureProvider<List<Relazione>>((ref) {
  return ref.watch(amiciziaRepositoryProvider).relazioni();
});

/// Amici accettati (l'altro profilo).
final amiciProvider = Provider<List<Profilo>>((ref) {
  final rel = ref.watch(relazioniProvider).valueOrNull ?? const [];
  return [
    for (final r in rel)
      if (r.stato == 'accettata') r.altro,
  ];
});

/// Richieste in ARRIVO (altri -> me, in attesa): posso accettare/rifiutare.
final richiesteInArrivoProvider = Provider<List<Profilo>>((ref) {
  final rel = ref.watch(relazioniProvider).valueOrNull ?? const [];
  return [
    for (final r in rel)
      if (r.stato == 'in_attesa' && !r.ioRichiedente) r.altro,
  ];
});

/// Richieste in USCITA (me -> altri, in attesa): "in attesa".
final richiesteInUscitaProvider = Provider<List<Profilo>>((ref) {
  final rel = ref.watch(relazioniProvider).valueOrNull ?? const [];
  return [
    for (final r in rel)
      if (r.stato == 'in_attesa' && r.ioRichiedente) r.altro,
  ];
});

/// Numero di richieste in arrivo (badge sulla riga "Amici" del profilo).
final numeroRichiesteProvider = Provider<int>((ref) {
  return ref.watch(richiesteInArrivoProvider).length;
});

/// Stato della relazione con [userId] (per il pulsante amicizia). Priorita':
/// amici > ricevuta > inviata > nessuna (una coppia puo' avere piu' righe).
final relazioneConProvider =
    Provider.family<StatoRelazione, String>((ref, userId) {
  final rel = ref.watch(relazioniProvider).valueOrNull ?? const [];
  var esito = StatoRelazione.nessuna;
  for (final r in rel) {
    if (r.altro.id != userId) continue;
    if (r.stato == 'accettata') return StatoRelazione.amici;
    if (r.stato == 'in_attesa') {
      if (!r.ioRichiedente) {
        esito = StatoRelazione.ricevuta;
      } else if (esito != StatoRelazione.ricevuta) {
        esito = StatoRelazione.inviata;
      }
    }
  }
  return esito;
});

/// Ricerca utenti per username.
final ricercaUtentiProvider =
    FutureProvider.family<List<Profilo>, String>((ref, q) {
  return ref.watch(amiciziaRepositoryProvider).cercaUtenti(q);
});

/// Azioni: dopo ogni mutazione invalida le relazioni (badge e derivati si
/// aggiornano insieme).
class AmiciController {
  AmiciController(this._ref);
  final Ref _ref;

  AmiciziaRepository get _repo => _ref.read(amiciziaRepositoryProvider);
  void _aggiorna() => _ref.invalidate(relazioniProvider);

  Future<void> inviaRichiesta(String altroId) async {
    await _repo.inviaRichiesta(altroId);
    _aggiorna();
  }

  Future<void> accetta(String richiedenteId) async {
    await _repo.accetta(richiedenteId);
    _aggiorna();
  }

  Future<void> rifiuta(String richiedenteId) async {
    await _repo.rifiuta(richiedenteId);
    _aggiorna();
  }

  Future<void> annulla(String destinatarioId) async {
    await _repo.annulla(destinatarioId);
    _aggiorna();
  }

  Future<void> rimuovi(String altroId) async {
    await _repo.rimuovi(altroId);
    _aggiorna();
  }
}

final amiciControllerProvider =
    Provider<AmiciController>((ref) => AmiciController(ref));
