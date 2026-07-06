import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/guida.dart';
import '../../../data/models/nota_stagionale.dart';
import '../../../data/models/specie.dart';
import '../../../data/repositories/contenuti_repository.dart';
import '../../../data/repositories/specie_repository.dart';

/// Giorno dell'anno (0-365) della data corrente: chiave DETERMINISTICA per le
/// selezioni "del giorno" (stabile per tutto il giorno, cambia ogni giorno,
/// uguale per tutti gli utenti).
int _giornoDellAnno() {
  final o = DateTime.now();
  return o.difference(DateTime(o.year, 1, 1)).inDays;
}

/// Tutte le guide (per l'elenco "Tutti" e per il consiglio del giorno).
final guideProvider = FutureProvider<List<Guida>>((ref) {
  return ref.watch(contenutiRepositoryProvider).guide();
});

/// Consiglio del giorno: una guida scelta in modo deterministico dalla data.
final consiglioDelGiornoProvider = Provider<Guida?>((ref) {
  final guide = ref.watch(guideProvider).valueOrNull;
  if (guide == null || guide.isEmpty) return null;
  return guide[_giornoDellAnno() % guide.length];
});

/// Nota stagionale del mese corrente ("In questo periodo").
final notaStagionaleProvider = FutureProvider<NotaStagionale?>((ref) {
  return ref.watch(contenutiRepositoryProvider).notaMese(DateTime.now().month);
});

/// Uccello del giorno: specie presentabile scelta deterministicamente dalla data.
final uccelloDelGiornoProvider = FutureProvider<Specie?>((ref) {
  return ref.watch(specieRepositoryProvider).specieDelGiorno(_giornoDellAnno());
});
