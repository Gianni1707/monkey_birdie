import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Un luogo trovato dalla ricerca (per centrare la mappa).
class RisultatoLuogo {
  const RisultatoLuogo({
    required this.etichetta,
    required this.lat,
    required this.lng,
    this.tipo = 'other',
  });
  final String etichetta;
  final double lat;
  final double lng;

  /// Tipo Photon (house/street/locality/city/county/state/country/...).
  final String tipo;

  /// Zoom adeguato al tipo: una via si apre da vicino, un paese piu' largo,
  /// uno stato molto largo. Evita il dezoom eccessivo su luoghi piccoli.
  double get zoom => switch (tipo) {
        'house' => 18,
        'street' => 16,
        'locality' || 'district' || 'neighbourhood' => 15,
        'city' || 'town' || 'village' => 13,
        'county' => 10,
        'state' => 8,
        'country' => 5,
        _ => 13,
      };
}

/// Geocoding per la barra di ricerca della mappa, via **Photon** (komoot):
/// gratis, senza API key, con CORS (ok anche sul web). Best-effort: lista vuota
/// su errore/timeout, niente eccezioni verso la UI.
class GeocodingRepository {
  Future<List<RisultatoLuogo>> cerca(String query) async {
    final q = query.trim();
    if (q.length < 2) return const [];
    try {
      // NB: niente parametro `lang`: Photon supporta solo default/de/en/fr e
      // risponde 400 con altri (es. `it`). Il default usa i nomi locali (Roma).
      final uri = Uri.https('photon.komoot.io', '/api', {
        'q': q,
        'limit': '6',
      });
      final resp = await http
          .get(uri, headers: {'User-Agent': 'MonkeyBird/1.0 (birdwatching)'})
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return const [];

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? const [];
      final out = <RisultatoLuogo>[];
      for (final f in features) {
        final feat = f as Map<String, dynamic>;
        final geom = feat['geometry'] as Map<String, dynamic>?;
        final coords = geom?['coordinates'] as List<dynamic>?;
        if (coords == null || coords.length < 2) continue;
        final props = (feat['properties'] as Map<String, dynamic>?) ?? const {};
        out.add(
          RisultatoLuogo(
            etichetta: _etichetta(props),
            lat: (coords[1] as num).toDouble(),
            lng: (coords[0] as num).toDouble(),
            tipo: (props['type'] as String?) ?? 'other',
          ),
        );
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  /// Etichetta leggibile: nome + città/stato + paese (salta i null/duplicati).
  static String _etichetta(Map<String, dynamic> p) {
    final parti = <String>[];
    for (final chiave in ['name', 'city', 'state', 'country']) {
      final v = p[chiave];
      if (v is String && v.isNotEmpty && !parti.contains(v)) parti.add(v);
    }
    return parti.isEmpty ? '?' : parti.join(', ');
  }
}

final geocodingRepositoryProvider =
    Provider<GeocodingRepository>((ref) => GeocodingRepository());
