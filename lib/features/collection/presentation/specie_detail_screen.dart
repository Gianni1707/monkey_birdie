import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/specie.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/state_views.dart';
import '../application/collection_controller.dart';

/// UT04 — scheda informativa sulla specie. (UT05 mappa habitat: Fase 2.)
class SpecieDetailScreen extends ConsumerWidget {
  const SpecieDetailScreen({super.key, required this.specieId});
  final String specieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSpecie = ref.watch(specieProvider(specieId));

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).speciesCard)),
      body: asyncSpecie.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: '$e',
          onRetry: () => ref.invalidate(specieProvider(specieId)),
        ),
        data: (specie) => _Dettaglio(specie),
      ),
    );
  }
}

class _Dettaglio extends StatelessWidget {
  const _Dettaglio(this.specie);
  final Specie specie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(specie.nomeComune, style: theme.textTheme.headlineSmall),
        Text(
          specie.nomeScientifico,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontStyle: FontStyle.italic, color: theme.colorScheme.outline),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            Chip(label: Text(l10n.rarityLabel(_rarita(l10n, specie.rarita)))),
            Chip(
              label: Text(l10n.dangerLabel(_pericolo(l10n, specie.livelloPericolo))),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (specie.descrizione != null) ...[
          Text(l10n.description, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(specie.descrizione!),
          const SizedBox(height: 16),
        ],
        if (specie.habitatDescrizione != null) ...[
          Text(l10n.habitat, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(specie.habitatDescrizione!),
          const SizedBox(height: 16),
        ],
        Card(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.map_outlined),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.habitatComingSoon)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _rarita(AppLocalizations l10n, String r) => switch (r) {
        'comune' => l10n.rarityCommon,
        'poco_comune' => l10n.rarityUncommon,
        'rara' => l10n.rarityRare,
        'molto_rara' => l10n.rarityVeryRare,
        _ => r,
      };

  String _pericolo(AppLocalizations l10n, int p) => switch (p) {
        0 => l10n.dangerNone,
        1 => l10n.dangerLow,
        2 => l10n.dangerMedium,
        _ => l10n.dangerHigh,
      };
}
