import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failure.dart';
import '../supabase/supabase_providers.dart';

/// Autenticazione. Alla registrazione passiamo `username` nei metadata:
/// il trigger `gestisci_nuovo_utente` crea automaticamente la riga in `profili`.
class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

  User? get utenteCorrente => _client.auth.currentUser;

  Future<void> registrati({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  Future<void> accedi({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw mapError(e);
    }
  }

  Future<void> esci() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw mapError(e);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});
