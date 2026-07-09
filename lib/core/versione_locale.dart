/// Versione dell'app, tenuta allineata a mano a `pubspec.yaml` (niente
/// package_info_plus per non aggiungere un plugin). Mostrata nelle Informazioni
/// e usata dal controllo aggiornamenti Android.
const String kVersioneApp = '1.2.2';

/// Build number locale (= il "+N" di `pubspec.yaml`, es. `1.0.0+1` → 1). Il
/// controllo aggiornamenti confronta questo con `app_versione.build` remoto.
const int kBuildApp = 5;
