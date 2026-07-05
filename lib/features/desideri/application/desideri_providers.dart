import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/desiderio.dart';
import '../../../data/repositories/lista_desideri_repository.dart';
import '../../collection/application/collection_controller.dart';

/// Lista desideri dell'utente (SORGENTE DI VERITÀ), dal più recente.
final listaDesideriProvider = FutureProvider<List<Desiderio>>((ref) async {
  return ref.watch(listaDesideriRepositoryProvider).lista();
});

/// Insieme degli id-specie desiderati, derivato da [listaDesideriProvider]. È
/// la fonte unica su cui si basa il toggle "Voglio avvistarlo" ovunque compaia
/// (scheda specie, ricerca, lista) -> sempre sincronizzato, come il cuore.
final desideriIdsProvider = Provider<Set<String>>((ref) {
  final async = ref.watch(listaDesideriProvider);
  return async.valueOrNull?.map((d) => d.specie.id).toSet() ?? const {};
});

/// Id delle specie GIÀ presenti in collezione (avvistate), derivato dalla
/// collezione: alimenta il badge "già avvistata 🎉" senza query extra.
final specieAvvistateIdsProvider = Provider<Set<String>>((ref) {
  final async = ref.watch(collezioneProvider);
  return async.valueOrNull?.map((a) => a.specieId).toSet() ?? const {};
});

/// Azioni sulla lista desideri: dopo ogni mutazione invalida la lista (il
/// toggle e la lista si aggiornano insieme).
class DesideriController {
  DesideriController(this._ref);
  final Ref _ref;

  Future<void> aggiungi(String specieId, {String? note}) async {
    await _ref.read(listaDesideriRepositoryProvider).aggiungi(specieId, note: note);
    _ref.invalidate(listaDesideriProvider);
  }

  Future<void> rimuovi(String specieId) async {
    await _ref.read(listaDesideriRepositoryProvider).rimuovi(specieId);
    _ref.invalidate(listaDesideriProvider);
  }

  Future<void> toggle(String specieId, {required bool attuale}) {
    return attuale ? rimuovi(specieId) : aggiungi(specieId);
  }

  Future<void> aggiornaNota(String specieId, String? note) async {
    await _ref.read(listaDesideriRepositoryProvider).aggiornaNota(specieId, note);
    _ref.invalidate(listaDesideriProvider);
  }
}

final desideriControllerProvider =
    Provider<DesideriController>((ref) => DesideriController(ref));
