import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';

/// SharedPreferences iniettato in `main` (override). Sincrono dopo l'init.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider non inizializzato'),
);

const _kLocaleKey = 'locale';

/// Lingua scelta dall'utente: `null` = automatica (segue il sistema).
/// Persistita in SharedPreferences.
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = ref.read(sharedPreferencesProvider).getString(_kLocaleKey);
    return (code == null || code.isEmpty) ? null : Locale(code);
  }

  Future<void> imposta(Locale? locale) async {
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(_kLocaleKey);
    } else {
      await prefs.setString(_kLocaleKey, locale.languageCode);
    }
  }
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);

/// [AppLocalizations] per la lingua corrente, usabile **fuori dai widget**
/// (es. nei controller, senza BuildContext): risolve l'override dell'utente o,
/// se assente, il locale di sistema ridotto a una lingua supportata.
final l10nProvider = Provider<AppLocalizations>((ref) {
  final override = ref.watch(localeControllerProvider);
  final locale = override ??
      _matchSupported(WidgetsBinding.instance.platformDispatcher.locale);
  return lookupAppLocalizations(locale);
});

Locale _matchSupported(Locale system) {
  for (final l in AppLocalizations.supportedLocales) {
    if (l.languageCode == system.languageCode) return l;
  }
  return const Locale('it'); // lingua di default del progetto
}
