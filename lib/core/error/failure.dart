import 'dart:io' show SocketException;

import 'package:supabase_flutter/supabase_flutter.dart';

/// Errore di dominio tipizzato. I repository lanciano sottoclassi di [Failure];
/// i controller le catturano con AsyncValue.guard e la UI mostra [message].
sealed class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Connessione assente o instabile.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Elemento non trovato.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Si è verificato un errore imprevisto.']);
}

/// Converte le eccezioni di Supabase/IO in una [Failure] leggibile.
Failure mapError(Object error) {
  if (error is Failure) return error;
  if (error is AuthException) return AuthFailure(error.message);
  if (error is PostgrestException) {
    // PGRST116 = nessuna riga quando ci si aspetta .single()
    if (error.code == 'PGRST116') return const NotFoundFailure();
    return UnknownFailure(error.message);
  }
  if (error is StorageException) return UnknownFailure(error.message);
  if (error is SocketException) return const NetworkFailure();
  return const UnknownFailure();
}
