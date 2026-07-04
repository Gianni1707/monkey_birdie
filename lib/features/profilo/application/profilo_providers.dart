import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/profilo.dart';
import '../../../data/models/specie.dart';
import '../../../data/repositories/preferiti_repository.dart';
import '../../../data/repositories/profilo_repository.dart';
import '../../../data/repositories/specie_repository.dart';
import '../../collection/application/collection_controller.dart';

/// Chiavi dei campi liberi in `profili.dati_personali` (jsonb).
abstract final class DatiProfilo {
  static const localita = 'localita';
  static const avatar = 'avatar'; // path dell'avatar nel bucket 'avatar'
}

/// Livello "birder" ASSEGNATO DAL SISTEMA in base al numero di SPECIE DIVERSE
/// memorizzate (life list). `soglia` = specie minime per raggiungerlo.
enum LivelloBirder {
  principiante(0, '🐣'),
  appassionato(5, '🐦'),
  esperto(20, '🦉'),
  maestro(50, '🦅');

  const LivelloBirder(this.soglia, this.emoji);
  final int soglia;
  final String emoji;

  static LivelloBirder perSpecie(int n) {
    var risultato = LivelloBirder.principiante;
    for (final l in LivelloBirder.values) {
      if (n >= l.soglia) risultato = l;
    }
    return risultato;
  }

  /// Soglia del livello successivo, o null se gia' al massimo.
  int? get prossimaSoglia {
    final i = index + 1;
    return i < LivelloBirder.values.length
        ? LivelloBirder.values[i].soglia
        : null;
  }
}

/// Stato del badge: livello, numero di specie, quante ne mancano al prossimo.
typedef BadgeBirder = ({LivelloBirder livello, int specie, int? mancanti});

/// Badge derivato dalla collezione (specie distinte). Si aggiorna da solo
/// quando la collezione cresce.
final badgeBirderProvider = Provider<AsyncValue<BadgeBirder>>((ref) {
  return ref.watch(collezioneProvider).whenData((avvistamenti) {
    final n = avvistamenti.map((a) => a.specieId).toSet().length;
    final livello = LivelloBirder.perSpecie(n);
    final soglia = livello.prossimaSoglia;
    return (
      livello: livello,
      specie: n,
      mancanti: soglia == null ? null : soglia - n,
    );
  });
});

/// Profilo dell'utente loggato.
final mioProfiloProvider = FutureProvider<Profilo>((ref) {
  return ref.watch(profiloRepositoryProvider).mioProfilo();
});

/// Specie preferite (SORGENTE DI VERITA'), ordinate per nome comune.
final preferitiProvider = FutureProvider<List<Specie>>((ref) async {
  final lista = await ref.watch(preferitiRepositoryProvider).preferiti();
  return [...lista]..sort(
      (a, b) =>
          a.nomeComune.toLowerCase().compareTo(b.nomeComune.toLowerCase()),
    );
});

/// Insieme degli id-specie preferiti, derivato da [preferitiProvider]. E' la
/// fonte unica su cui si basa il cuore ovunque compaia -> sempre sincronizzato.
final preferitiIdsProvider = Provider<Set<String>>((ref) {
  final async = ref.watch(preferitiProvider);
  return async.valueOrNull?.map((s) => s.id).toSet() ?? const {};
});

/// Ricerca nel catalogo specie (per aggiungere un preferito).
final ricercaCatalogoProvider =
    FutureProvider.family<List<Specie>, String>((ref, q) {
  return ref.watch(specieRepositoryProvider).cercaCatalogo(q);
});

/// Azioni su profilo e preferiti: dopo ogni mutazione invalida i provider
/// coinvolti (il cuore e la lista si aggiornano insieme).
class ProfiloController {
  ProfiloController(this._ref);
  final Ref _ref;

  Future<void> salvaProfilo({
    required String username,
    required String? bio,
    required Map<String, dynamic> datiPersonali,
  }) async {
    await _ref.read(profiloRepositoryProvider).aggiorna(
          username: username,
          bio: bio,
          datiPersonali: datiPersonali,
        );
    _ref.invalidate(mioProfiloProvider);
  }

  Future<bool> usernameDisponibile(String username) {
    return _ref.read(profiloRepositoryProvider).usernameDisponibile(username);
  }

  /// Carica un nuovo avatar, lo registra in dati_personali (merge) ed elimina
  /// il vecchio (best-effort). Non tocca username/bio.
  Future<void> impostaAvatar(Uint8List bytes) async {
    final repo = _ref.read(profiloRepositoryProvider);
    final p = _ref.read(mioProfiloProvider).valueOrNull;
    final vecchio = p?.datiPersonali[DatiProfilo.avatar] as String?;
    final path = await repo.caricaAvatar(bytes);
    await repo.aggiornaDati({
      ...?p?.datiPersonali,
      DatiProfilo.avatar: path,
    });
    _ref.invalidate(mioProfiloProvider);
    if (vecchio != null && vecchio != path) repo.eliminaAvatar(vecchio);
  }

  Future<void> rimuoviAvatar() async {
    final repo = _ref.read(profiloRepositoryProvider);
    final p = _ref.read(mioProfiloProvider).valueOrNull;
    final vecchio = p?.datiPersonali[DatiProfilo.avatar] as String?;
    final dati = {...?p?.datiPersonali}..remove(DatiProfilo.avatar);
    await repo.aggiornaDati(dati);
    _ref.invalidate(mioProfiloProvider);
    if (vecchio != null) repo.eliminaAvatar(vecchio);
  }

  Future<void> aggiungiPreferito(String specieId) async {
    await _ref.read(preferitiRepositoryProvider).aggiungi(specieId);
    _ref.invalidate(preferitiProvider);
  }

  Future<void> rimuoviPreferito(String specieId) async {
    await _ref.read(preferitiRepositoryProvider).rimuovi(specieId);
    _ref.invalidate(preferitiProvider);
  }

  Future<void> togglePreferito(String specieId, {required bool attuale}) {
    return attuale ? rimuoviPreferito(specieId) : aggiungiPreferito(specieId);
  }
}

final profiloControllerProvider =
    Provider<ProfiloController>((ref) => ProfiloController(ref));
