import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Recupera una **thumbnail** della specie (per nome scientifico) dall'API pubblica
/// di **iNaturalist**, per aiutare l'utente a scegliere il candidato giusto.
/// Best-effort: ritorna null se non trovata o in caso di errore/timeout (niente
/// eccezioni verso la UI). Le foto iNaturalist hanno licenze proprie (CC): qui
/// sono usate solo come anteprima, coerente con l'uso non commerciale.
class SpecieImmagineRepository {
  Future<String?> thumbnailPerNomeScientifico(String nomeScientifico) async {
    if (nomeScientifico.trim().isEmpty) return null;
    try {
      final uri = Uri.https('api.inaturalist.org', '/v1/taxa', {
        'q': nomeScientifico,
        'rank': 'species',
        'per_page': '1',
      });
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;
      final photo = (results.first as Map<String, dynamic>)['default_photo'];
      if (photo is Map<String, dynamic>) {
        return (photo['medium_url'] ?? photo['square_url']) as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

final specieImmagineRepositoryProvider =
    Provider<SpecieImmagineRepository>((ref) => SpecieImmagineRepository());

/// URL della thumbnail per nome scientifico (cache per sessione via Riverpod).
final specieThumbnailProvider =
    FutureProvider.family<String?, String>((ref, nomeScientifico) {
  return ref
      .read(specieImmagineRepositoryProvider)
      .thumbnailPerNomeScientifico(nomeScientifico);
});
