import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/avvistamento.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/nome_specie.dart';
import '../../../shared/widgets/avvistamento_foto.dart';
import '../../../shared/widgets/state_views.dart';
import '../../desideri/presentation/desideri_screen.dart';
import '../../raccolte/presentation/aggiungi_a_raccolta_sheet.dart';
import '../../raccolte/presentation/raccolte_screen.dart';
import '../application/collection_controller.dart';
import 'elimina_avvistamento.dart';

/// UT04/UT06/UT07 — Collezione con tre viste: "Avvistamenti" (tutti), "Raccolte"
/// (sotto-gruppi) e "Desideri" (specie da avvistare). Il selettore in alto tiene
/// la bottom nav invariata.
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: l10n.tabSightings),
              Tab(text: l10n.tabCollections),
              Tab(text: l10n.tabWishlist),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _ListaAvvistamenti(),
                RaccolteScreen(),
                DesideriScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// La collezione di TUTTI gli avvistamenti (ex contenuto di CollectionScreen).
class _ListaAvvistamenti extends ConsumerWidget {
  const _ListaAvvistamenti();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncColl = ref.watch(collezioneProvider);
    final l10n = AppLocalizations.of(context);

    return asyncColl.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(
        message: '$e',
        onRetry: () => ref.invalidate(collezioneProvider),
      ),
      data: (avvistamenti) {
        if (avvistamenti.isEmpty) {
          return EmptyState(
            icon: Icons.photo_camera_back_outlined,
            title: l10n.emptyCollectionTitle,
            subtitle: l10n.emptyCollectionSubtitle,
          );
        }
        // Griglia a 2 colonne (foto sopra, nome/scientifico/meta sotto), come
        // nel mockup "La tua Collezione".
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(collezioneProvider),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemCount: avvistamenti.length,
            itemBuilder: (_, i) => _AvvistamentoGridCard(a: avvistamenti[i]),
          ),
        );
      },
    );
  }
}

/// Card della Collezione (griglia): foto in alto, nome comune serif, scientifico
/// in corsivo, data come metadato leggero; menu ⋮ in alto a destra sulla foto.
/// Tap → scheda specie. (Aspetto: dati e azioni invariati.)
class _AvvistamentoGridCard extends StatelessWidget {
  const _AvvistamentoGridCard({required this.a});
  final AvvistamentoDettaglio a;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          InkWell(
            onTap: () => context.push('/specie/${a.specieId}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AvvistamentoFoto(
                    fotoUrl: a.fotoUrl,
                    nomeScientifico: a.specieNomeScientifico,
                    size: null, // riempie la cella
                    borderRadius: 0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        a.specieNomeDaMostrare,
                        style: t.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        a.specieNomeScientifico,
                        style: t.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.event,
                            size: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(_formatData(a.avvistatoIl), style: t.labelSmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: _MenuAvvistamento(a: a),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatData(DateTime d) {
    String due(int n) => n.toString().padLeft(2, '0');
    return '${due(d.day)}/${due(d.month)}/${d.year}';
  }
}

/// Menu ⋮ (compatto, per l'overlay sulla foto): "Aggiungi a raccolta" (non
/// distruttivo) e "Elimina avvistamento" (DISTRUTTIVO: rosso + cestino, con
/// conferma). Il delete è tenuto visivamente distinto dalle azioni "togli da…".
class _MenuAvvistamento extends ConsumerWidget {
  const _MenuAvvistamento({required this.a});
  final AvvistamentoDettaglio a;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      iconSize: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      tooltip: '',
      onSelected: (v) {
        switch (v) {
          case 'raccolta':
            mostraAggiungiARaccolta(context, a.id);
          case 'elimina':
            confermaEliminaAvvistamento(context, ref, a);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'raccolta',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.bookmark_add_outlined),
            title: Text(l10n.addToCollection),
          ),
        ),
        PopupMenuItem(
          value: 'elimina',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_outline, color: scheme.error),
            title: Text(
              l10n.deleteSighting,
              style: TextStyle(color: scheme.error),
            ),
          ),
        ),
      ],
    );
  }
}
