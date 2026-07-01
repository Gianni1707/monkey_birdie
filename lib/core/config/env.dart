/// Configurazione di ambiente, iniettata a compile-time con --dart-define.
///
/// Esempio:
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJhb...
class Env {
  Env._();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Chiamare a bootstrap: fallisce subito (in debug) se manca la config.
  static void assertConfigured() {
    assert(
      supabaseUrl.isNotEmpty,
      'SUPABASE_URL mancante: passa --dart-define=SUPABASE_URL=...',
    );
    assert(
      supabaseAnonKey.isNotEmpty,
      'SUPABASE_ANON_KEY mancante: passa --dart-define=SUPABASE_ANON_KEY=...',
    );
  }
}
