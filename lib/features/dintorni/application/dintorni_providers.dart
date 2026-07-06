import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/location/location_service.dart';
import '../../../data/repositories/specie_repository.dart';
import '../../../shared/nome_specie.dart';
import '../../amici/application/condivisione_providers.dart';
import 'dintorni_repository.dart';

/// Finestra "di recente" per gli avvistamenti community (badge dedicato).
const int kGiorniRecenteDintorni = 90;

/// Una specie "nei dintorni". [community] = presente tra gli avvistamenti
/// condivisi (miei + amici) vicini e recenti (dato reale, badge + in cima);
/// altrimenti viene solo da GBIF (presente in zona, dato storico).
class SpecieVicina {
  const SpecieVicina({
    required this.specieId,
    required this.nome,
    required this.nomeScientifico,
    required this.community,
  });

  final String specieId;
  final String nome;
  final String nomeScientifico;
  final bool community;
}

/// Posizione corrente per la sezione dintorni. In errore (permesso negato, GPS
/// off) propaga l'eccezione: la UI mostra il messaggio "attiva posizione".
final posizioneDintorniProvider = FutureProvider<LatLng>((ref) async {
  return ref.read(locationServiceProvider).posizioneCorrente();
});

/// Lista fusa GBIF + community delle specie nei dintorni. Community in cima
/// (dedup per specieId). Best-effort: se una delle due fonti fallisce, si usa
/// l'altra; solo l'assenza di posizione fa fallire l'intero provider.
final uccelliVicinoProvider = FutureProvider<List<SpecieVicina>>((ref) async {
  final pos = await ref.watch(posizioneDintorniProvider.future);

  // 1) Community: avvistamenti condivisi (RLS = miei + amici) vicini e recenti.
  final community = <String, SpecieVicina>{};
  try {
    final dati = await ref.watch(avvistamentiMappaProvider.future);
    final soglia = DateTime.now().subtract(
      const Duration(days: kGiorniRecenteDintorni),
    );
    for (final a in dati.avvistamenti) {
      if (a.lat == null || a.lng == null) continue;
      if (a.avvistatoIl.isBefore(soglia)) continue;
      if (_distanzaKm(pos.lat, pos.lng, a.lat!, a.lng!) > kRaggioDintorniKm) {
        continue;
      }
      community.putIfAbsent(
        a.specieId,
        () => SpecieVicina(
          specieId: a.specieId,
          nome: a.specieNomeDaMostrare,
          nomeScientifico: a.specieNomeScientifico,
          community: true,
        ),
      );
    }
  } catch (_) {
    // community best-effort
  }

  final risultato = <SpecieVicina>[...community.values];
  final idVisti = {...community.keys};

  // 2) GBIF: specie osservate in zona (storiche), mappate al catalogo.
  try {
    final nomi =
        await ref.read(dintorniRepositoryProvider).specieVicino(pos.lat, pos.lng);
    if (nomi.isNotEmpty) {
      final specie =
          await ref.read(specieRepositoryProvider).perNomiScientifici(nomi);
      final perNome = {
        for (final s in specie) s.nomeScientifico.toLowerCase(): s,
      };
      // Preserva l'ordine per frequenza di `nomi`.
      for (final n in nomi) {
        final s = perNome[n.toLowerCase()];
        if (s == null || idVisti.contains(s.id)) continue;
        idVisti.add(s.id);
        risultato.add(
          SpecieVicina(
            specieId: s.id,
            nome: s.nomeDaMostrare,
            nomeScientifico: s.nomeScientifico,
            community: false,
          ),
        );
      }
    }
  } catch (_) {
    // GBIF best-effort
  }

  return risultato;
});

double _distanzaKm(double lat1, double lon1, double lat2, double lon2) {
  const raggioTerra = 6371.0;
  final dLat = _rad(lat2 - lat1);
  final dLon = _rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  return raggioTerra * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _rad(double gradi) => gradi * pi / 180.0;
