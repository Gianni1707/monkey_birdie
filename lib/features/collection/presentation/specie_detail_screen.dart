import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/specie.dart';
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
      appBar: AppBar(title: const Text('Scheda specie')),
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
            Chip(label: Text('Rarità: ${_rarita(specie.rarita)}')),
            Chip(label: Text('Pericolo: ${_pericolo(specie.livelloPericolo)}')),
          ],
        ),
        const SizedBox(height: 16),
        if (specie.descrizione != null) ...[
          Text('Descrizione', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(specie.descrizione!),
          const SizedBox(height: 16),
        ],
        if (specie.habitatDescrizione != null) ...[
          Text('Habitat', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(specie.habitatDescrizione!),
          const SizedBox(height: 16),
        ],
        Card(
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.map_outlined),
                SizedBox(width: 12),
                Expanded(child: Text('Mappa dell’habitat in arrivo nella Fase 2.')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _rarita(String r) => switch (r) {
        'comune' => 'comune',
        'poco_comune' => 'poco comune',
        'rara' => 'rara',
        'molto_rara' => 'molto rara',
        _ => r,
      };

  String _pericolo(int p) => switch (p) {
        0 => 'nessuno',
        1 => 'basso',
        2 => 'medio',
        _ => 'alto',
      };
}
