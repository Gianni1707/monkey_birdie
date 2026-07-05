import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../l10n/app_localizations.dart';
import '../application/amici_providers.dart';

/// Pulsante di amicizia riusabile: riflette lo stato reale (da
/// `relazioneConProvider`) e offre l'azione giusta. Usato nella ricerca utenti
/// e in cima al profilo pubblico. La RLS impone la direzione (insert solo come
/// richiedente): "Aggiungi" appare solo se non c'e' gia' una richiesta.
class PulsanteAmicizia extends ConsumerWidget {
  const PulsanteAmicizia({
    super.key,
    required this.utenteId,
    required this.username,
    this.compatto = false,
  });
  final String utenteId;
  final String username;

  /// Se true: solo icone (con tooltip), per la lista amici. Se false: pulsanti
  /// con etichetta (profilo pubblico).
  final bool compatto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stato = ref.watch(relazioneConProvider(utenteId));
    final ctrl = ref.read(amiciControllerProvider);

    if (compatto) return _compatto(context, ref, l10n, stato, ctrl);

    switch (stato) {
      case StatoRelazione.nessuna:
        return FilledButton.icon(
          onPressed: () => _fai(context, () => ctrl.inviaRichiesta(utenteId)),
          icon: const Icon(Icons.person_add_alt_1),
          label: Text(l10n.addFriend),
        );
      case StatoRelazione.inviata:
        return OutlinedButton.icon(
          onPressed: () => _fai(context, () => ctrl.annulla(utenteId)),
          icon: const Icon(Icons.schedule),
          label: Text(l10n.cancelRequest),
        );
      case StatoRelazione.ricevuta:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () => _fai(context, () => ctrl.accetta(utenteId)),
              child: Text(l10n.accept),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _fai(context, () => ctrl.rifiuta(utenteId)),
              child: Text(l10n.reject),
            ),
          ],
        );
      case StatoRelazione.amici:
        return OutlinedButton.icon(
          onPressed: () => _confermaRimozione(context, ref),
          icon: const Icon(Icons.how_to_reg),
          label: Text(l10n.friendLabel),
        );
    }
  }

  /// Variante compatta: solo icone intuitive (tooltip = etichetta).
  Widget _compatto(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    StatoRelazione stato,
    AmiciController ctrl,
  ) {
    switch (stato) {
      case StatoRelazione.nessuna:
        return IconButton.filled(
          tooltip: l10n.addFriend,
          onPressed: () => _fai(context, () => ctrl.inviaRichiesta(utenteId)),
          icon: const Icon(Icons.person_add_alt_1),
        );
      case StatoRelazione.inviata:
        return IconButton.outlined(
          tooltip: l10n.cancelRequest,
          onPressed: () => _fai(context, () => ctrl.annulla(utenteId)),
          icon: const Icon(Icons.schedule),
        );
      case StatoRelazione.ricevuta:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.filled(
              tooltip: l10n.accept,
              onPressed: () => _fai(context, () => ctrl.accetta(utenteId)),
              icon: const Icon(Icons.check),
            ),
            const SizedBox(width: 4),
            IconButton.outlined(
              tooltip: l10n.reject,
              onPressed: () => _fai(context, () => ctrl.rifiuta(utenteId)),
              icon: const Icon(Icons.close),
            ),
          ],
        );
      case StatoRelazione.amici:
        return IconButton.outlined(
          tooltip: l10n.friendLabel,
          onPressed: () => _confermaRimozione(context, ref),
          icon: const Icon(Icons.how_to_reg),
        );
    }
  }

  Future<void> _confermaRimozione(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removeFriend),
        content: Text(l10n.removeFriendConfirm(username)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.removeFriend),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await _fai(
        context,
        () => ref.read(amiciControllerProvider).rimuovi(utenteId),
      );
    }
  }

  Future<void> _fai(BuildContext context, Future<void> Function() azione) async {
    try {
      await azione();
    } catch (e) {
      if (!context.mounted) return;
      final msg = e is Failure ? e.message : e.toString();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}
