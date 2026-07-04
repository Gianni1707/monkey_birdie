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
}

final specieRepositoryProvider = Provider<SpecieRepository>((ref) {
  return SpecieRepository(ref.watch(supabaseClientProvider));
});
