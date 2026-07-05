import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/avvistamento.dart';
import '../../../data/repositories/avvistamenti_repository.dart';
import '../../../data/repositories/avvistamento_foto_repository.dart';
import '../../amici/application/condivisione_providers.dart';
import '../../raccolte/application/raccolte_providers.dart';
import 'collection_controller.dart';

/// Azioni distruttive sugli avvistamenti (rifinitura UT04): eliminazione
/// definitiva. Dopo l'eliminazione invalida in reattivo tutte le viste.
class AvvistamentoAzioniController {
  AvvistamentoAzioniController(this._ref);
  final Ref _ref;

  /// Elimina definitivamente un avvistamento:
  /// 1) riga DB (RLS: solo i propri) -> i ponti raccolte spariscono in CASCADE;
  /// 2) foto su Storage best-effort, solo se propria (`foto_url` valorizzato);
  /// 3) invalida collezione, mappa e appartenenze (badge desideri/birder e i
  ///    provider raccolte derivano da questi -> si aggiornano da soli).
  Future<void> elimina(AvvistamentoDettaglio a) async {
    await _ref.read(avvistamentiRepositoryProvider).elimina(a.id);

    final fotoPath = a.fotoUrl;
    if (fotoPath != null && fotoPath.isNotEmpty) {
      await _ref.read(avvistamentoFotoRepositoryProvider).eliminaFile(fotoPath);
    }

    _ref.invalidate(collezioneProvider);
    _ref.invalidate(avvistamentiMappaProvider);
    _ref.invalidate(appartenenzeProvider);
  }
}

final avvistamentoAzioniControllerProvider =
    Provider<AvvistamentoAzioniController>(
  (ref) => AvvistamentoAzioniController(ref),
);
