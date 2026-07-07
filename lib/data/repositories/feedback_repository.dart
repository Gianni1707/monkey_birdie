import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failure.dart';
import '../supabase/supabase_providers.dart';

/// Invio feedback (consigli / bug / altro). Solo INSERT del proprio feedback
/// (RLS `feedback_insert_proprio`); nessuna lettura da client. La notifica email
/// parte lato server (Database Webhook → Worker → Resend), non da qui.
class FeedbackRepository {
  FeedbackRepository(this._client);
  final SupabaseClient _client;

  Future<void> invia({
    required String tipo,
    required String messaggio,
    String? versioneApp,
    String? piattaforma,
  }) async {
    try {
      await _client.from('feedback').insert({
        'utente_id': _client.auth.currentUser?.id,
        'tipo': tipo,
        'messaggio': messaggio,
        'versione_app': versioneApp,
        'piattaforma': piattaforma,
      });
    } catch (e) {
      throw mapError(e);
    }
  }
}

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository(ref.watch(supabaseClientProvider));
});
