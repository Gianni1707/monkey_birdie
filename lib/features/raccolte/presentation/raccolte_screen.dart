import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/avvistamento.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/avvistamento_foto.dart';
import '../../../shared/widgets/state_views.dart';
import '../application/raccolte_providers.dart';
import 'raccolta_dialoghi.dart';

/// Elenco delle raccolte dell'utente (dentro la tab Collezione).
class RaccolteScreen extends ConsumerWidget {
  const RaccolteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(raccolteAnteprimaProvider);

    return async.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(
        message: '$e',
        onRetry: () => ref.invalidate(raccolteAnteprimaProvider),
      ),
      data: (raccolte) {
        if (raccolte.isEmpty) {
          return _VuotoConAzione(
            onCrea: () => mostraNuovaRaccolta(context, ref),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(raccolteAnteprimaProvider),
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.create_new_folder_outlined),
                  title: Text(l10n.newCollection),
                  onTap: () => mostraNuovaRaccolta(context, ref),
                ),
              ),
              const SizedBox(height: 4),
              for (final a in raccolte) _RaccoltaTile(a),
            ],
          ),
        );
      },
    );
  }
}

class _RaccoltaTile extends ConsumerWidget {
  const _RaccoltaTile(this.anteprima);
  final RaccoltaAnteprima anteprima;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final r = anteprima.raccolta;
    return Card(
      child: ListTile(
        leading: _Miniature(anteprima.campioni),
        title: Text(r.nome),
        subtitle: Text(
          '${l10n.speciesCount(anteprima.numeroSpecie)} · '
          '${l10n.sightingsCount(anteprima.totale)}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == 'rinomina') {
              await mostraRinominaRaccolta(context, ref, r);
            } else if (v == 'elimina') {
              await mostraEliminaRaccolta(context, ref, r);
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'rinomina', child: Text(l10n.renameCollection)),
            PopupMenuItem(value: 'elimina', child: Text(l10n.deleteCollection)),
          ],
        ),
        onTap: () => context.push('/raccolta/${r.id}'),
      ),
    );
  }
}

/// Fino a 3 miniature affiancate (o icona cartella se la raccolta e' vuota).
class _Miniature extends StatelessWidget {
  const _Miniature(this.campioni);
  final List<AvvistamentoDettaglio> campioni;

  @override
  Widget build(BuildContext context) {
    if (campioni.isEmpty) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Icon(Icons.folder_outlined, size: 32),
      );
    }
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          for (var i = 0; i < campioni.length && i < 3; i++)
            Positioned(
              left: i * 10.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                child: AvvistamentoFoto(
                  fotoUrl: campioni[i].fotoUrl,
                  nomeScientifico: campioni[i].specieNomeScientifico,
                  size: 34,
                  borderRadius: 6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VuotoConAzione extends StatelessWidget {
  const _VuotoConAzione({required this.onCrea});
  final VoidCallback onCrea;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_special_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.collectionsEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              l10n.collectionsEmptySubtitle,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onCrea,
            icon: const Icon(Icons.add),
            label: Text(l10n.newCollection),
          ),
        ],
      ),
    );
  }
}
