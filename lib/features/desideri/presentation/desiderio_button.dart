import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../l10n/app_localizations.dart';
import '../application/desideri_providers.dart';

/// Toggle "Voglio avvistarlo" riutilizzabile: riflette SEMPRE lo stato reale
/// (da [desideriIdsProvider]) e lo sincronizza ovunque compaia (scheda specie,
/// ricerca, lista). Stesso schema del cuore preferiti.
class DesiderioIconButton extends ConsumerWidget {
  const DesiderioIconButton({super.key, required this.specieId});
  final String specieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final desiderato = ref.watch(desideriIdsProvider).contains(specieId);

    return IconButton(
      tooltip: desiderato ? l10n.removeFromWishlist : l10n.addToWishlist,
      icon: Icon(
        desiderato ? Icons.flag : Icons.flag_outlined,
        color: desiderato ? Theme.of(context).colorScheme.primary : null,
      ),
      onPressed: () async {
        try {
          await ref
              .read(desideriControllerProvider)
              .toggle(specieId, attuale: desiderato);
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
