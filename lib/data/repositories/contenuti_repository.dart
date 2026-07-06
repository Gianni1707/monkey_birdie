import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failure.dart';
import '../models/guida.dart';
import '../models/nota_stagionale.dart';
import '../supabase/supabase_providers.dart';

/// Contenuti editoriali (sola lettura): guide/consigli + calendario stagionale.
class ContenutiRepository {
  ContenutiRepository(this._client);
  final SupabaseClient _client;

  /// Tutte le guide, in ordine di visualizzazione.
  Future<List<Guida>> guide() async {
    try {
      // NB: `.order()` in supabase-dart è DISCENDENTE di default → forzo asc.
      final rows =
          await _client.from('guide').select().order('ordine', ascending: true);
      return rows.map((j) => Guida.fromJson(j)).toList(growable: false);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Nota stagionale del mese (1-12), o null se assente.
  Future<NotaStagionale?> notaMese(int mese) async {
    try {
      final row = await _client
          .from('calendario_stagionale')
          .select()
          .eq('mese', mese)
          .maybeSingle();
      return row == null ? null : NotaStagionale.fromJson(row);
    } catch (e) {
      throw mapError(e);
    }
  }
}

final contenutiRepositoryProvider = Provider<ContenutiRepository>((ref) {
  return ContenutiRepository(ref.watch(supabaseClientProvider));
});
