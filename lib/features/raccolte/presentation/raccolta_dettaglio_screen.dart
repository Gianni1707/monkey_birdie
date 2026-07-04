import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/raccolta.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/avvistamento_tile.dart';
import '../../../shared/widgets/state_views.dart';
import '../application/raccolte_providers.dart';
import 'raccolta_dialoghi.dart';

/// Contenuto di una raccolta: riusa le tile della Collezione. Da qui si
/// rinomina/elimina la raccolta e si tolgono avvistamenti (senza cancellarli).
class RaccoltaDettaglioScreen extends ConsumerWidget {
  const RaccoltaDettaglioScreen({super.key, required this.raccoltaId});
  final String raccoltaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final raccolte = ref.watch(mieRaccolteProvider).valueOrNull ?? const [];
    Raccolta? r;
    for (final x in raccolte) {
      if (x.id == raccoltaId) {
        r = x;
        break;
      }
    }
    final contenuto = ref.watch(contenutoRaccoltaProvider(raccoltaId));

    return Scaffold(
      appBar: AppBar(
        title: Text(r?.nome ?? l10n.collections),
        actions: [
          if (r != null)
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'rinomina') {
                  await mostraRinominaRaccolta(context, ref, r!);
                } else if (v == 'elimina') {
                  final fatto = await mostraEliminaRaccolta(context, ref, r!);
                  if (fatto && context.mounted) context.pop();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'rinomina',
                  child: Text(l10n.renameCollection),
                ),
                PopupMenuItem(
                  value: 'elimina',
                  child: Text(l10n.deleteCollection),
                ),
              ],
            ),
        ],
      ),
      body: contenuto.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: '$e',
          onRetry: () => ref.invalidate(contenutoRaccoltaProvider(raccoltaId)),
        ),
        data: (avvistamenti) {
          if (avvistamenti.isEmpty) {
            return EmptyState(
              icon: Icons.folder_open_outlined,
              title: l10n.collectionDetailEmptyTitle,
              subtitle: l10n.collectionDetailEmptySubtitle,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: avvistamenti.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) {
              final a = avvistamenti[i];
              return AvvistamentoTile(
                a,
                trailing: IconButton(
                  tooltip: l10n.removeFromCollection,
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => ref.read(raccolteControllerProvider).rimuovi(
                        raccoltaId: raccoltaId,
                        avvistamentoId: a.id,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
