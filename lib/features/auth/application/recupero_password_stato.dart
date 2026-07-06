import 'package:flutter/foundation.dart';

/// Flag globale "recupero password in corso".
///
/// Viene impostato in `main()` da un listener su `onAuthStateChange` agganciato
/// SUBITO dopo `Supabase.initialize`: l'evento `passwordRecovery` può scattare
/// durante il rilevamento della sessione dall'URL (link email aperto nella PWA),
/// prima che il router si iscriva — così non lo perdiamo. È un `ValueNotifier`
/// (quindi `Listenable`) così il redirect di go_router si aggiorna al cambio.
final recuperoPasswordInCorso = ValueNotifier<bool>(false);
