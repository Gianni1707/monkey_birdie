import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Accesso a **GBIF** (Global Biodiversity Information Facility) per l'habitat
/// (UT05): risoluzione del `taxonKey` da nome scientifico + costruzione dell'URL
/// dei tile di densità delle occorrenze. Gratuito, pubblico, senza API key.
/// Best-effort come [GeocodingRepository]: `null` su errore/timeout, niente
/// eccezioni verso la UI.
class GbifRepository {
  /// Risolve il `taxonKey` (`usageKey` GBIF) di una specie dal nome scientifico.
  /// Ritorna `null` se non c'è corrispondenza o in caso di errore/timeout.
  Future<int?> taxonKey(String nomeScientifico) async {
    final nome = nomeScientifico.trim();
    if (nome.isEmpty) return null;
    try {
      final uri = Uri.https('api.gbif.org', '/v1/species/match', {
        'name': nome,
      });
      final resp = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return null;

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      // matchType == 'NONE' -> nessuna corrispondenza affidabile.
      if (data['matchType'] == 'NONE') return null;
      final key = data['usageKey'];
      return key is int ? key : null;
    } catch (_) {
      return null;
    }
  }

  /// URL-template XYZ dei tile raster di densità per un `taxonKey`, pronto per
  /// un [TileLayer] di flutter_map (`{z}/{x}/{y}` sostituiti dal renderer).
  /// - `style=classic.poly` + `bin=hex`: celle esagonali leggibili anche fitte.
  /// - `basisOfRecord=HUMAN_OBSERVATION`: solo osservazioni umane (più pulite).
  /// - `srs=EPSG:3857`: proiezione web-mercator = stesso schema delle tile OSM,
  ///   quindi l'overlay è perfettamente allineato alla mappa base.
  static String densityTileUrl(int taxonKey) =>
      'https://api.gbif.org/v2/map/occurrence/density/{z}/{x}/{y}@1x.png'
      '?srs=EPSG:3857'
      '&taxonKey=$taxonKey'
      '&style=classic.poly'
      '&bin=hex'
      '&basisOfRecord=HUMAN_OBSERVATION';

  /// Numero totale di occorrenze (osservazioni umane) registrate su GBIF per un
  /// `taxonKey`. Usato come proxy della "difficoltà" di avvistamento (UT07).
  /// `limit=0`: chiediamo solo il `count`, non i record. `null` su errore/timeout.
  Future<int?> occurrenceCount(int taxonKey) async {
    try {
      final uri = Uri.https('api.gbif.org', '/v1/occurrence/search', {
        'taxonKey': '$taxonKey',
        'basisOfRecord': 'HUMAN_OBSERVATION',
        'limit': '0',
      });
      final resp = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final count = data['count'];
      return count is int ? count : null;
    } catch (_) {
      return null;
    }
  }

  static const String _userAgent =
      'MonkeyBirdie/1.0 (birdwatching; non-commercial)';
}

final gbifRepositoryProvider =
    Provider<GbifRepository>((ref) => GbifRepository());
