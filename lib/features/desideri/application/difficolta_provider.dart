import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_controller.dart'
    show sharedPreferencesProvider;
import '../../map/application/gbif_repository.dart';
import '../../map/application/habitat_providers.dart';

/// Difficoltà di avvistamento STIMATA (UT07) dal volume di occorrenze GBIF.
/// È solo un'indicazione qualitativa: la UI la etichetta esplicitamente come
/// stima. `nd` = non calcolabile (nessun taxonKey o rete non disponibile).
enum Difficolta { comune, pocoComune, difficile, moltoRaro, nd }

/// Soglie (tarabili) sul numero di osservazioni umane GBIF. Un uccello europeo
/// comune ha milioni di record; una specie sfuggente/localizzata pochissimi.
Difficolta _daCount(int? count) {
  if (count == null) return Difficolta.nd;
  if (count >= 1000000) return Difficolta.comune;
  if (count >= 100000) return Difficolta.pocoComune;
  if (count >= 10000) return Difficolta.difficile;
  return Difficolta.moltoRaro;
}

/// Difficoltà per una specie (chiave = nome scientifico). Riusa il `taxonKey`
/// già risolto e cachato da UT05; il `count` è cachato a parte (per taxonKey).
/// Best-effort: qualunque errore -> `Difficolta.nd`.
final difficoltaProvider =
    FutureProvider.family<Difficolta, String>((ref, nomeScientifico) async {
  final key = await ref.watch(gbifTaxonKeyProvider(nomeScientifico).future);
  if (key == null) return Difficolta.nd;

  final prefs = ref.watch(sharedPreferencesProvider);
  final chiave = 'gbif_count:$key';
  if (prefs.containsKey(chiave)) return _daCount(prefs.getInt(chiave));

  final count = await ref.watch(gbifRepositoryProvider).occurrenceCount(key);
  // Cache solo i valori validi: un errore di rete resta ritentabile.
  if (count != null) await prefs.setInt(chiave, count);
  return _daCount(count);
});
