import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failure.dart';
import '../models/specie.dart';
import '../supabase/supabase_providers.dart';

/// Accesso al catalogo `specie` (sola lettura per l'utente).
class SpecieRepository {
  SpecieRepository(this._client);
  final SupabaseClient _client;

  /// Mapping BirdNET -> catalogo per label completa "Sci_Common" (match esatto).
  Future<Specie?> perBirdnetLabel(String label) async {
    try {
      final data = await _client
          .from('specie')
          .select()
          .eq('birdnet_label', label)
          .limit(1)
          .maybeSingle();
      return data == null ? null : Specie.fromJson(data);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Fallback: cerca per nome scientifico (case-insensitive).
  /// Ritorna null se la specie non e' nel catalogo (avvistamento non salvabile).
  Future<Specie?> perNomeScientifico(String nomeScientifico) async {
    try {
      final data = await _client
          .from('specie')
          .select()
          .ilike('nome_scientifico', nomeScientifico)
          .limit(1)
          .maybeSingle();
      return data == null ? null : Specie.fromJson(data);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Mapping completo: prima per birdnet_label, poi per nome scientifico.
  Future<Specie?> perPredizione({
    required String label,
    required String nomeScientifico,
  }) async {
    return await perBirdnetLabel(label) ??
        await perNomeScientifico(nomeScientifico);
  }

  /// Mapping FOTO -> catalogo per `image_label` (nome scientifico AIY, match esatto).
  Future<Specie?> perImageLabel(String imageLabel) async {
    try {
      final data = await _client
          .from('specie')
          .select()
          .eq('image_label', imageLabel)
          .limit(1)
          .maybeSingle();
      return data == null ? null : Specie.fromJson(data);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Mapping completo FOTO: prima per image_label, poi per nome scientifico.
  Future<Specie?> perPredizioneImmagine({
    required String imageLabel,
    required String nomeScientifico,
  }) async {
    return await perImageLabel(imageLabel) ??
        await perNomeScientifico(nomeScientifico);
  }

  Future<Specie> perId(String id) async {
    try {
      final data =
          await _client.from('specie').select().eq('id', id).single();
      return Specie.fromJson(data);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Ricerca testuale nel catalogo per nome comune (IT + EN) o scientifico (per
  /// scegliere una specie preferita/desiderata). Best-effort: lista vuota se
  /// query < 2 caratteri. Include `nome_comune_it` così i nomi ITALIANI (es.
  /// "colomba", "codibugnolo") si trovano, non solo l'inglese/scientifico.
  Future<List<Specie>> cercaCatalogo(String query, {int limite = 25}) async {
    final q = query.trim();
    if (q.length < 2) return const [];
    try {
      final like = '%$q%';
      final rows = await _client
          .from('specie')
          .select()
          .or('nome_comune.ilike.$like,nome_scientifico.ilike.$like,'
              'nome_comune_it.ilike.$like')
          .order('nome_comune')
          .limit(limite);
      return rows.map((j) => Specie.fromJson(j)).toList(growable: false);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// "Uccello del giorno": una specie PRESENTABILE (nome comune IT + descrizione
  /// non nulli) scelta in modo DETERMINISTICO da [giornoAnno] (0-365). Bias sulle
  /// comuni (`rarita = 'comune'`); se quell'insieme è vuoto, ricade su tutte le
  /// presentabili. Selezione via count + offset (niente fetch dell'intero
  /// catalogo). `null` solo se non c'è alcuna specie presentabile.
  Future<Specie?> specieDelGiorno(int giornoAnno) async {
    try {
      Future<Specie?> pesca({required bool soloComuni}) async {
        var conteggio = _client
            .from('specie')
            .count()
            .not('nome_comune_it', 'is', null)
            .not('descrizione', 'is', null);
        if (soloComuni) conteggio = conteggio.eq('rarita', 'comune');
        final n = await conteggio;
        if (n == 0) return null;
        final offset = giornoAnno % n;

        var query = _client
            .from('specie')
            .select()
            .not('nome_comune_it', 'is', null)
            .not('descrizione', 'is', null);
        if (soloComuni) query = query.eq('rarita', 'comune');
        final rows = await query
            .order('nome_scientifico')
            .range(offset, offset); // una sola riga all'offset
        return rows.isEmpty ? null : Specie.fromJson(rows.first);
      }

      return await pesca(soloComuni: true) ?? await pesca(soloComuni: false);
    } catch (e) {
      throw mapError(e);
    }
  }
}

final specieRepositoryProvider = Provider<SpecieRepository>((ref) {
  return SpecieRepository(ref.watch(supabaseClientProvider));
});
