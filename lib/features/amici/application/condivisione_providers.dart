import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/avvistamento.dart';
import '../../../data/repositories/avvistamenti_repository.dart';
import '../../../data/repositories/profilo_repository.dart';
import '../../../data/supabase/supabase_providers.dart';
import '../../collection/application/collection_controller.dart';
import '../../profilo/application/profilo_providers.dart';

/// Dati per la mappa: avvistamenti (propri + condivisi degli amici), l'id mio
/// (per distinguere i marcatori) e la mappa utente_id -> username (attribuzione).
typedef DatiMappa = ({
  List<AvvistamentoDettaglio> avvistamenti,
  Map<String, String> username,
  String? mioId,
});

final avvistamentiMappaProvider = FutureProvider<DatiMappa>((ref) async {
  final repo = ref.watch(avvistamentiRepositoryProvider);
  final tutti = await repo.perMappa();
  final mioId = ref.watch(supabaseClientProvider).auth.currentUser?.id;

  final altruiIds = <String>{
    for (final a in tutti)
      if (a.utenteId != mioId) a.utenteId,
  }.toList();
  final username = await ref
      .read(profiloRepositoryProvider)
      .usernamePerIds(altruiIds);

  return (avvistamenti: tutti, username: username, mioId: mioId);
});

/// Avvistamenti condivisi di un altro utente (per il profilo pubblico).
final avvistamentiCondivisiDiProvider =
    FutureProvider.family<List<AvvistamentoDettaglio>, String>((ref, userId) {
  return ref.watch(avvistamentiRepositoryProvider).condivisiDi(userId);
});

/// Impostazione UNICA (nel profilo): condivido TUTTI i miei avvistamenti con gli
/// amici? Salvata in `dati_personali['condividi_tutti']`.
final condividiTuttiProvider = Provider<bool>((ref) {
  final p = ref.watch(mioProfiloProvider).valueOrNull;
  return p?.datiPersonali[DatiProfilo.condividiTutti] == true;
});

/// Applica l'impostazione unica: salva il flag nel profilo e allinea in blocco
/// il `condiviso` di TUTTI i miei avvistamenti; aggiorna profilo/collezione/mappa.
class CondivisioneController {
  CondivisioneController(this._ref);
  final Ref _ref;

  Future<void> impostaTutti(bool valore) async {
    final p = _ref.read(mioProfiloProvider).valueOrNull;
    await _ref.read(profiloRepositoryProvider).aggiornaDati({
      ...?p?.datiPersonali,
      DatiProfilo.condividiTutti: valore,
    });
    await _ref
        .read(avvistamentiRepositoryProvider)
        .impostaCondivisoTutti(valore);
    _ref.invalidate(mioProfiloProvider);
    _ref.invalidate(collezioneProvider);
    _ref.invalidate(avvistamentiMappaProvider);
  }
}

final condivisioneControllerProvider =
    Provider<CondivisioneController>((ref) => CondivisioneController(ref));
