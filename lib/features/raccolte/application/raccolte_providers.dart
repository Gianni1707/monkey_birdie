import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/avvistamento.dart';
import '../../../data/models/raccolta.dart';
import '../../../data/repositories/raccolte_repository.dart';
import '../../collection/application/collection_controller.dart';

/// Elenco delle raccolte dell'utente.
final mieRaccolteProvider = FutureProvider<List<Raccolta>>((ref) {
  return ref.watch(raccolteRepositoryProvider).mieRaccolte();
});

/// Tutte le appartenenze (righe del ponte) delle proprie raccolte.
final appartenenzeProvider = FutureProvider<List<Appartenenza>>((ref) {
  return ref.watch(raccolteRepositoryProvider).appartenenze();
});

/// Anteprima di una raccolta per l'elenco: conteggi + qualche avvistamento
/// campione (per le miniature).
class RaccoltaAnteprima {
  const RaccoltaAnteprima({
    required this.raccolta,
    required this.totale,
    required this.numeroSpecie,
    required this.campioni,
  });
  final Raccolta raccolta;
  final int totale;
  final int numeroSpecie;
  final List<AvvistamentoDettaglio> campioni;
}

/// Elenco raccolte con anteprima, combinando raccolte + appartenenze +
/// collezione (nessuna query extra sugli avvistamenti: riusa `collezioneProvider`).
final raccolteAnteprimaProvider =
    FutureProvider<List<RaccoltaAnteprima>>((ref) async {
  final raccolte = await ref.watch(mieRaccolteProvider.future);
  final appartenenze = await ref.watch(appartenenzeProvider.future);
  final collezione = await ref.watch(collezioneProvider.future);
  final perId = {for (final a in collezione) a.id: a};

  final perRaccolta = <String, List<AvvistamentoDettaglio>>{};
  for (final ap in appartenenze) {
    final a = perId[ap.avvistamentoId];
    if (a != null) (perRaccolta[ap.raccoltaId] ??= []).add(a);
  }

  return raccolte.map((r) {
    final items = perRaccolta[r.id] ?? const <AvvistamentoDettaglio>[];
    final specie = items.map((a) => a.specieId).toSet().length;
    return RaccoltaAnteprima(
      raccolta: r,
      totale: items.length,
      numeroSpecie: specie,
      campioni: items.take(3).toList(growable: false),
    );
  }).toList(growable: false);
});

/// Contenuto di una raccolta (avvistamenti completi), riusando la collezione.
final contenutoRaccoltaProvider =
    FutureProvider.family<List<AvvistamentoDettaglio>, String>(
        (ref, raccoltaId) async {
  final appartenenze = await ref.watch(appartenenzeProvider.future);
  final collezione = await ref.watch(collezioneProvider.future);
  final perId = {for (final a in collezione) a.id: a};
  return appartenenze
      .where((ap) => ap.raccoltaId == raccoltaId)
      .map((ap) => perId[ap.avvistamentoId])
      .whereType<AvvistamentoDettaglio>()
      .toList(growable: false);
});

/// Insieme degli id-raccolta che contengono un dato avvistamento (per pre-
/// spuntare i check nel foglio "aggiungi a una raccolta").
final raccolteDiAvvistamentoProvider =
    FutureProvider.family<Set<String>, String>((ref, avvistamentoId) async {
  final appartenenze = await ref.watch(appartenenzeProvider.future);
  return appartenenze
      .where((ap) => ap.avvistamentoId == avvistamentoId)
      .map((ap) => ap.raccoltaId)
      .toSet();
});

/// Azioni sulle raccolte: dopo ogni mutazione invalida i provider derivati.
class RaccolteController {
  RaccolteController(this._ref);
  final Ref _ref;

  RaccolteRepository get _repo => _ref.read(raccolteRepositoryProvider);

  void _aggiorna() {
    _ref.invalidate(mieRaccolteProvider);
    _ref.invalidate(appartenenzeProvider);
  }

  /// Nome gia' usato (confronto case-insensitive, trim). `escludiId` per il
  /// rename (non confrontare con se stessa).
  bool nomeDuplicato(List<Raccolta> esistenti, String nome, {String? escludiId}) {
    final n = nome.trim().toLowerCase();
    return esistenti.any(
      (r) => r.id != escludiId && r.nome.trim().toLowerCase() == n,
    );
  }

  Future<Raccolta> crea({required String nome, String? descrizione}) async {
    final r = await _repo.crea(nome: nome.trim(), descrizione: descrizione);
    _aggiorna();
    return r;
  }

  Future<void> rinomina({
    required String id,
    required String nome,
    String? descrizione,
  }) async {
    await _repo.rinomina(id: id, nome: nome.trim(), descrizione: descrizione);
    _aggiorna();
  }

  Future<void> elimina(String id) async {
    await _repo.elimina(id);
    _aggiorna();
  }

  Future<void> aggiungi({
    required String raccoltaId,
    required String avvistamentoId,
  }) async {
    await _repo.aggiungi(raccoltaId: raccoltaId, avvistamentoId: avvistamentoId);
    _aggiorna();
  }

  Future<void> rimuovi({
    required String raccoltaId,
    required String avvistamentoId,
  }) async {
    await _repo.rimuovi(raccoltaId: raccoltaId, avvistamentoId: avvistamentoId);
    _aggiorna();
  }
}

final raccolteControllerProvider =
    Provider<RaccolteController>((ref) => RaccolteController(ref));
