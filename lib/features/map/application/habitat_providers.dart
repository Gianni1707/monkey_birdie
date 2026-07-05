import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_controller.dart' show sharedPreferencesProvider;
import '../../../data/models/avvistamento.dart';
import '../../amici/application/condivisione_providers.dart';
import 'gbif_repository.dart';

/// Sentinel in cache per "nessuna corrispondenza GBIF": evita di ripetere la
/// chiamata di rete sulle specie che non hanno un taxonKey.
const int _kNoMatch = -1;

String _cacheKey(String nomeScientifico) => 'gbif_taxon:$nomeScientifico';

/// `taxonKey` GBIF per una specie (chiave = nome scientifico), **cache-first**
/// lato client (SharedPreferences). Memorizza anche il "no match" (sentinel -1)
/// così non si ripete il match. Ritorna `null` se la specie non ha occorrenze
/// GBIF o in caso di errore di rete.
final gbifTaxonKeyProvider =
    FutureProvider.family<int?, String>((ref, nomeScientifico) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  final chiave = _cacheKey(nomeScientifico.trim());

  if (prefs.containsKey(chiave)) {
    final cached = prefs.getInt(chiave);
    return (cached == null || cached == _kNoMatch) ? null : cached;
  }

  final key = await ref.watch(gbifRepositoryProvider).taxonKey(nomeScientifico);
  await prefs.setInt(chiave, key ?? _kNoMatch);
  return key;
});

/// Avvistamenti di UNA specie da mostrare come layer sulla mappa habitat: i
/// propri + i condivisi dagli amici (con posizione). **Derivato** da
/// [avvistamentiMappaProvider] (RLS già applicata) filtrando per `specieId`:
/// nessuna query aggiuntiva. `mioId` distingue i propri dagli altrui.
typedef AvvistamentiSpecie = ({
  List<AvvistamentoDettaglio> avvistamenti,
  String? mioId,
});

final avvistamentiSpecieProvider =
    FutureProvider.family<AvvistamentiSpecie, String>((ref, specieId) async {
  final dati = await ref.watch(avvistamentiMappaProvider.future);
  final filtrati = dati.avvistamenti
      .where((a) => a.specieId == specieId && a.lat != null && a.lng != null)
      .toList(growable: false);
  return (avvistamenti: filtrati, mioId: dati.mioId);
});
