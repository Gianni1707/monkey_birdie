import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/avvistamento.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/avvistamento_foto.dart';
import '../../../shared/widgets/state_views.dart';
import '../application/raccolte_providers.dart';
import 'raccolta_dialoghi.dart';

/// Elenco delle raccolte dell'utente (dentro la tab Collezione). Impaginazione
/// "guida da campo": intestazione, card con chip specie/avvistamenti e miniature,
/// card "inizia una nuova raccolta" e FAB "+".
class RaccolteScreen extends ConsumerWidget {
  const RaccolteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final async = ref.watch(raccolteAnteprimaProvider);

    return async.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(
        message: '$e',
        onRetry: () => ref.invalidate(raccolteAnteprimaProvider),
      ),
      data: (raccolte) {
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async => ref.invalidate(raccolteAnteprimaProvider),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                children: [
                  Text(l10n.collectionsHeading, style: t.headlineSmall),
                  const SizedBox(height: 2),
                  Text(
                    l10n.collectionsHeadingSub,
                    style: t.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final a in raccolte) _RaccoltaCard(a),
                  const SizedBox(height: 4),
                  _NuovaRaccoltaCard(
                    onCrea: () => mostraNuovaRaccolta(context, ref),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                heroTag: 'nuovaRaccolta',
                onPressed: () => mostraNuovaRaccolta(context, ref),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RaccoltaCard extends ConsumerWidget {
  const _RaccoltaCard(this.anteprima);
  final RaccoltaAnteprima anteprima;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final r = anteprima.raccolta;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push('/raccolta/${r.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(r.nome, style: t.titleMedium)),
                  _MenuRaccolta(anteprima: anteprima),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChipInfo(
                    icon: Icons.pets_outlined,
                    testo: l10n.speciesCount(anteprima.numeroSpecie),
                  ),
                  _ChipInfo(
                    icon: Icons.visibility_outlined,
                    testo: l10n.sightingsCount(anteprima.totale),
                  ),
                ],
              ),
              if (anteprima.campioni.isNotEmpty) ...[
                const SizedBox(height: 14),
                _Miniature(
                  campioni: anteprima.campioni,
                  totale: anteprima.totale,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Pillola informativa (icona + testo), es. "12 specie" / "45 avvistamenti".
class _ChipInfo extends StatelessWidget {
  const _ChipInfo({required this.icon, required this.testo});
  final IconData icon;
  final String testo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(testo, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

/// Riga di miniature (fino a 3 celle), con "+N" se ci sono più avvistamenti.
class _Miniature extends StatelessWidget {
  const _Miniature({required this.campioni, required this.totale});
  final List<AvvistamentoDettaglio> campioni;
  final int totale;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    // Con più di 3 avvistamenti: 2 miniature + cella "+N".
    final nThumb = totale > 3 ? 2 : campioni.length.clamp(0, 3);
    final thumbs = campioni.take(nThumb).toList(growable: false);
    final resto = totale - thumbs.length;

    // Quadratini fissi (non stirati a tutta larghezza): con 1 solo campione
    // la foto resta un quadrato, non una striscia che taglia l'uccello.
    Widget cella(Widget child) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 84, height: 84, child: child),
        );

    return Row(
      children: [
        for (var i = 0; i < thumbs.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          cella(
            AvvistamentoFoto(
              fotoUrl: thumbs[i].fotoUrl,
              nomeScientifico: thumbs[i].specieNomeScientifico,
              size: null,
              borderRadius: 0,
            ),
          ),
        ],
        if (resto > 0) ...[
          const SizedBox(width: 8),
          cella(
            ColoredBox(
              color: scheme.surfaceContainerHigh,
              child: Center(
                child: Text('+$resto', style: t.titleMedium),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Menu ⋮ della card raccolta: rinomina / elimina raccolta.
class _MenuRaccolta extends ConsumerWidget {
  const _MenuRaccolta({required this.anteprima});
  final RaccoltaAnteprima anteprima;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final r = anteprima.raccolta;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
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
    );
  }
}

/// Card tratteggiata "Inizia una nuova raccolta".
class _NuovaRaccoltaCard extends StatelessWidget {
  const _NuovaRaccoltaCard({required this.onCrea});
  final VoidCallback onCrea;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onCrea,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outline),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: scheme.primaryContainer,
              child: Icon(
                Icons.add_photo_alternate_outlined,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.startNewCollection, style: t.titleMedium),
            const SizedBox(height: 4),
            Text(
              l10n.startNewCollectionSub,
              textAlign: TextAlign.center,
              style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
