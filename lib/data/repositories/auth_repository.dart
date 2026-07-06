import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failure.dart';
import '../supabase/supabase_providers.dart';

/// URL di produzione della PWA (dominio custom): il recupero password reindirizza
/// sempre qui (anche per gli utenti Android → reimpostano nel browser, niente deep
/// link). Deve essere tra i Redirect URLs consentiti su Supabase.
const String kUrlWebProd = 'https://monkeybirdie.com';

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

  /// Invia l'email col link per reimpostare la password. Il link riporta sempre
  /// alla PWA: sul web all'origine corrente (prod o localhost in dev), altrove
  /// all'URL di produzione. La PWA intercetta l'evento `passwordRecovery`.
  Future<void> inviaRecuperoPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? Uri.base.origin : kUrlWebProd,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Imposta la nuova password sull'utente della sessione di recupero.
  Future<void> aggiornaPassword(String nuova) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: nuova));
    } catch (e) {
      throw mapError(e);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});
