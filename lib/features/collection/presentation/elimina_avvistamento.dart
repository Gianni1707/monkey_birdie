import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/avvistamento.dart';
import '../../../l10n/app_localizations.dart';
import '../application/avvistamento_azioni.dart';

/// Conferma ed esegue l'eliminazione DEFINITIVA di un avvistamento. Helper unico
/// condiviso da Collezione (menu ⋮) e bottom sheet della mappa, così il dialog e
/// il comportamento sono identici. Sempre con conferma esplicita (irreversibile).
///
/// Ritorna `true` se l'avvistamento è stato eliminato (utile a chi deve chiudere
/// un contenitore, es. il bottom sheet). `false` se annullato o in errore.
Future<bool> confermaEliminaAvvistamento(
  BuildContext context,
  WidgetRef ref,
  AvvistamentoDettaglio a,
) async {
  final l10n = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;

  final conferma = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.deleteSightingTitle),
      content: Text(l10n.deleteSightingBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.deleteAction),
        ),
      ],
    ),
  );
  if (conferma != true) return false;

  try {
    await ref.read(avvistamentoAzioniControllerProvider).elimina(a);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.sightingDeleted)));
    }
    return true;
  } catch (e) {
    if (context.mounted) {
      final msg = e is Failure ? e.message : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
    return false;
  }
}
