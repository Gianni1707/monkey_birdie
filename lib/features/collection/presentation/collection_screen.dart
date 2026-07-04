import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/avvistamento_tile.dart';
import '../../../shared/widgets/state_views.dart';
import '../../raccolte/presentation/aggiungi_a_raccolta_sheet.dart';
import '../../raccolte/presentation/raccolte_screen.dart';
import '../application/collection_controller.dart';

/// UT04/UT06 — Collezione con due viste: "Avvistamenti" (tutti) e "Raccolte"
/// (sotto-gruppi). Il selettore in alto tiene la bottom nav invariata.
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: l10n.tabSightings),
              Tab(text: l10n.tabCollections),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _ListaAvvistamenti(),
                RaccolteScreen(),
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
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(collezioneProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: avvistamenti.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) {
              final a = avvistamenti[i];
              return AvvistamentoTile(
                a,
                trailing: IconButton(
                  tooltip: l10n.addToCollection,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  onPressed: () => mostraAggiungiARaccolta(context, a.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
