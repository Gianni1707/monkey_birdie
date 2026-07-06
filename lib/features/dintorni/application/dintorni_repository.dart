import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';

/// Raggio di ricerca "nei dintorni" (GBIF + community), in km.
const int kRaggioDintorniKm = 25;

/// GBIF per "Uccelli nei dintorni": nomi scientifici delle specie di uccelli
/// (classe Aves, taxonKey 212) osservate entro [kRaggioDintorniKm] dal punto,
/// ordinati per frequenza (più osservate prima). Best-effort come le altre
/// integrazioni GBIF: lista vuota su errore/timeout, niente eccezioni alla UI.
/// Cache 24h per coordinate arrotondate (~1 km) in SharedPreferences.
class DintorniRepository {
  DintorniRepository(this._prefs);
  final SharedPreferences _prefs;

  Future<List<String>> specieVicino(double lat, double lng) async {
    final chiave = 'dintorni_gbif_'
        '${lat.toStringAsFixed(2)}_${lng.toStringAsFixed(2)}_$kRaggioDintorniKm';
    final cache = _leggiCache(chiave);
    if (cache != null) return cache;

    try {
      final annoMax = DateTime.now().year;
      final uri = Uri.https('api.gbif.org', '/v1/occurrence/search', {
        'taxonKey': '212', // classe Aves nel backbone GBIF
        'basisOfRecord': 'HUMAN_OBSERVATION',
        'hasCoordinate': 'true',
        'geoDistance': '$lat,$lng,${kRaggioDintorniKm}km',
        // Dato STORICO ma non preistorico: ultimi ~10 anni.
        'year': '${annoMax - 10},$annoMax',
        'limit': '300',
      });
      final resp = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return const [];

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final results = (data['results'] as List?) ?? const [];
      // Conta le occorrenze per specie → le più osservate ≈ le più presenti.
      final conteggio = <String, int>{};
      for (final r in results) {
        if (r is! Map) continue;
        final sp = r['species'];
        final key = r['speciesKey'];
        // Scarta record identificati solo a genere (senza species/speciesKey).
        if (sp is! String || sp.isEmpty || key == null) continue;
        conteggio[sp] = (conteggio[sp] ?? 0) + 1;
      }
      final ordinati = conteggio.keys.toList()
        ..sort((a, b) => conteggio[b]!.compareTo(conteggio[a]!));
      final top = ordinati.take(40).toList(growable: false);
      _scriviCache(chiave, top);
      return top;
    } catch (_) {
      return const [];
    }
  }

  List<String>? _leggiCache(String chiave) {
    final raw = _prefs.getString(chiave);
    if (raw == null) return null;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final ts = j['ts'] as int?;
      if (ts == null) return null;
      final eta = DateTime.now().millisecondsSinceEpoch - ts;
      if (eta > const Duration(hours: 24).inMilliseconds) return null;
      return (j['specie'] as List).cast<String>();
    } catch (_) {
      return null;
    }
  }

  void _scriviCache(String chiave, List<String> specie) {
    _prefs.setString(
      chiave,
      jsonEncode({
        'ts': DateTime.now().millisecondsSinceEpoch,
        'specie': specie,
      }),
    );
  }

  static const String _userAgent =
      'MonkeyBirdie/1.0 (birdwatching; non-commercial)';
}

final dintorniRepositoryProvider = Provider<DintorniRepository>(
  (ref) => DintorniRepository(ref.read(sharedPreferencesProvider)),
);
