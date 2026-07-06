import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/desiderio.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/nome_specie.dart';
import '../../../shared/widgets/avvistamento_foto.dart';
import '../../../shared/widgets/state_views.dart';
import '../application/desideri_providers.dart';
import '../application/difficolta_provider.dart';
import 'aggiungi_desiderio_sheet.dart';

/// UT07 — Lista desideri: specie che l'utente vuole ancora avvistare. Card con
/// foto, badge difficoltà (stima), nome comune/scientifico, stato "da avvistare"
/// / "già avvistata", menu ⋮ (nota / rimuovi). Toggle sincronizzato.
class DesideriScreen extends ConsumerWidget {
  const DesideriScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final async = ref.watch(listaDesideriProvider);

    return async.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(
        message: '$e',
        onRetry: () => ref.invalidate(listaDesideriProvider),
      ),
      data: (desideri) {
        final avvistate = ref.watch(specieAvvistateIdsProvider);
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(listaDesideriProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(l10n.wishlistHeading, style: t.headlineSmall),
              const SizedBox(height: 2),
              Text(
                l10n.wishlistHeadingSub,
                style: t.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => mostraAggiungiDesiderio(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.addSpecies),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 16),
              if (desideri.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: EmptyState(
                    icon: Icons.flag_outlined,
                    title: l10n.emptyWishlistTitle,
                    subtitle: l10n.emptyWishlistSubtitle,
                  ),
                )
              else
                for (final d in desideri)
                  _DesiderioCard(
                    d,
                    giaAvvistata: avvistate.contains(d.specie.id),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _DesiderioCard extends ConsumerWidget {
  const _DesiderioCard(this.desiderio, {required this.giaAvvistata});
  final Desiderio desiderio;
  final bool giaAvvistata;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = desiderio.specie;
    final diff = ref.watch(difficoltaProvider(s.nomeScientifico)).valueOrNull;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/specie/${s.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                // Rapporto 16:9 (invece di altezza fissa): su schermi larghi il
                // banner non diventa una striscia che taglia l'uccello.
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: AvvistamentoFoto(
                    fotoUrl: null,
                    nomeScientifico: s.nomeScientifico,
                    size: null,
                    borderRadius: 0,
                  ),
                ),
                if (diff != null && diff != Difficolta.nd)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _BadgeDifficolta(diff),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.nomeDaMostrare, style: t.titleMedium),
                  Text(
                    s.nomeScientifico,
                    style: t.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatoPill(giaAvvistata: giaAvvistata),
                      const Spacer(),
                      _MenuDesiderio(desiderio: desiderio),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge difficoltà (stima) in alto a destra sulla foto.
class _BadgeDifficolta extends StatelessWidget {
  const _BadgeDifficolta(this.difficolta);
  final Difficolta difficolta;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final label = switch (difficolta) {
      Difficolta.comune => l10n.difficultyCommon,
      Difficolta.pocoComune => l10n.difficultyUncommon,
      Difficolta.difficile => l10n.difficultyHard,
      Difficolta.moltoRaro => l10n.difficultyVeryRare,
      Difficolta.nd => l10n.difficultyNA,
    };
    final capitalizzato =
        label.isEmpty ? label : label[0].toUpperCase() + label.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_outline, size: 14, color: scheme.onSurface),
          const SizedBox(width: 4),
          Text(capitalizzato, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

/// Pillola di stato: "già avvistata" (verde pieno) / "da avvistare" (outline).
class _StatoPill extends StatelessWidget {
  const _StatoPill({required this.giaAvvistata});
  final bool giaAvvistata;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme.labelMedium;
    if (giaAvvistata) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 15, color: scheme.onPrimary),
            const SizedBox(width: 6),
            Text(
              l10n.statusSpotted,
              style: t?.copyWith(color: scheme.onPrimary),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline),
      ),
      child: Text(l10n.statusToSpot, style: t),
    );
  }
}

/// Menu ⋮ del desiderio: modifica nota / rimuovi dai desideri.
class _MenuDesiderio extends ConsumerWidget {
  const _MenuDesiderio({required this.desiderio});
  final Desiderio desiderio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (v) {
        if (v == 'nota') {
          _modificaNota(context, ref);
        } else if (v == 'rimuovi') {
          _rimuovi(context, ref);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'nota', child: Text(l10n.wishlistNote)),
        PopupMenuItem(value: 'rimuovi', child: Text(l10n.removeFromWishlist)),
      ],
    );
  }

  Future<void> _rimuovi(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(desideriControllerProvider).rimuovi(desiderio.specie.id);
    } catch (e) {
      if (!context.mounted) return;
      final msg = e is Failure ? e.message : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _modificaNota(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: desiderio.note ?? '');
    final nuova = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.wishlistNote),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 300,
          maxLines: 3,
          decoration: InputDecoration(hintText: l10n.wishlistNoteHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (nuova == null) return;
    try {
      await ref
          .read(desideriControllerProvider)
          .aggiornaNota(desiderio.specie.id, nuova);
    } catch (e) {
      if (!context.mounted) return;
      final msg = e is Failure ? e.message : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}
