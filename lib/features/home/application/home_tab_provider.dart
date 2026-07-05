import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indice della tab attiva in `HomeShell` (0 Home · 1 Mappa · 2 Collezione ·
/// 3 Profilo). È un provider così altre schermate possono cambiare tab (es.
/// "Mostra sulla mappa" dalla collezione, o "Vedi collezione" dalla Home).
final homeTabProvider = StateProvider<int>((ref) => 0);
