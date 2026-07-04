import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../l10n/app_localizations.dart';
import '../application/profilo_providers.dart';

/// Cuore preferito riutilizzabile: riflette SEMPRE lo stato reale (da
/// [preferitiIdsProvider]) e lo sincronizza ovunque compaia (scheda specie,
/// ricerca, ...). Toggle -> aggiorna la lista preferiti del profilo.
class PreferitoIconButton extends ConsumerWidget {
  const PreferitoIconButton({super.key, required this.specieId});
  final String specieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final preferito = ref.watch(preferitiIdsProvider).contains(specieId);

    return IconButton(
      tooltip: preferito ? l10n.removeFavorite : l10n.addFavorite,
      icon: Icon(
        preferito ? Icons.favorite : Icons.favorite_border,
        color: preferito ? Colors.red : null,
      ),
      onPressed: () async {
        try {
          await ref
              .read(profiloControllerProvider)
              .togglePreferito(specieId, attuale: preferito);
        } catch (e) {
          if (!context.mounted) return;
          final msg = e is Failure ? e.message : e.toString();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg)));
        }
      },
    );
  }
}
