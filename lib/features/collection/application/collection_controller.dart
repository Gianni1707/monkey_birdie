import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/avvistamento.dart';
import '../../../data/models/specie.dart';
import '../../../data/repositories/avvistamenti_repository.dart';
import '../../../data/repositories/specie_repository.dart';

/// Collezione (avvistamenti) dell'utente corrente, dal piu' recente.
final collezioneProvider =
    FutureProvider<List<AvvistamentoDettaglio>>((ref) async {
  return ref.watch(avvistamentiRepositoryProvider).mieiAvvistamenti();
});

/// Scheda di una specie del catalogo (per la pagina di dettaglio).
final specieProvider = FutureProvider.family<Specie, String>((ref, id) async {
  return ref.watch(specieRepositoryProvider).perId(id);
});
