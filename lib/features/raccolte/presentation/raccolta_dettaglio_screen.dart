import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/avvistamento.dart';
import '../../../data/models/raccolta.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/nome_specie.dart';
import '../../../shared/widgets/avvistamento_foto.dart';
import '../../../shared/widgets/state_views.dart';
import '../application/raccolte_providers.dart';
import 'aggiungi_avvistamenti_raccolta_sheet.dart';
import 'raccolta_dialoghi.dart';

/// Contenuto di una raccolta. Azioni rinomina (matita) / elimina (cestino rosso)
/// in alto; card avvistamento grandi. "Togli dalla raccolta" NON è distruttivo
/// (l'avvistamento resta in collezione).
class RaccoltaDettaglioScreen extends ConsumerWidget {
  const RaccoltaDettaglioScreen({super.key, required this.raccoltaId});
  final String raccoltaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
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
      floatingActionButton: r == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  mostraAggiungiAvvistamentiARaccolta(context, raccoltaId),
              icon: const Icon(Icons.add),
              label: Text(l10n.addSightings),
            ),
      appBar: AppBar(
        title: Text(r?.nome ?? l10n.collections),
        actions: [
          if (r != null) ...[
            IconButton(
              tooltip: l10n.renameCollection,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => mostraRinominaRaccolta(context, ref, r!),
            ),
            IconButton(
              tooltip: l10n.deleteCollection,
              icon: Icon(Icons.delete_outline, color: scheme.error),
              onPressed: () async {
                final fatto = await mostraEliminaRaccolta(context, ref, r!);
                if (fatto && context.mounted) context.pop();
              },
            ),
          ],
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
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  l10n.sightingsCount(avvistamenti.length),
                  style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              for (final a in avvistamenti)
                _AvvistamentoCardRaccolta(
                  a: a,
                  onTogli: () => _confermaTogli(context, ref, raccoltaId, a),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Conferma prima di togliere un avvistamento dalla raccolta (azione reversibile
/// ma esplicita: l'avvistamento resta comunque nella collezione).
Future<void> _confermaTogli(
  BuildContext context,
  WidgetRef ref,
  String raccoltaId,
  AvvistamentoDettaglio a,
) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.removeFromCollection),
      content: Text(l10n.removeFromCollectionConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.removeFromCollection),
        ),
      ],
    ),
  );
  if (ok == true) {
    await ref
        .read(raccolteControllerProvider)
        .rimuovi(raccoltaId: raccoltaId, avvistamentoId: a.id);
  }
}

/// Card grande: foto in alto, nome comune serif, scientifico corsivo, data.
/// In alto a destra il pulsante "togli dalla raccolta" (non distruttivo).
class _AvvistamentoCardRaccolta extends StatelessWidget {
  const _AvvistamentoCardRaccolta({required this.a, required this.onTogli});
  final AvvistamentoDettaglio a;
  final VoidCallback onTogli;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              InkWell(
                onTap: () => context.push('/specie/${a.specieId}'),
                child: SizedBox(
                  height: 170,
                  child: AvvistamentoFoto(
                    fotoUrl: a.fotoUrl,
                    nomeScientifico: a.specieNomeScientifico,
                    size: null,
                    borderRadius: 0,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    tooltip: l10n.removeFromCollection,
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: onTogli,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.specieNomeDaMostrare, style: t.titleMedium),
                Text(
                  a.specieNomeScientifico,
                  style: t.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    Icon(Icons.event, size: 15, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(_formatData(a.avvistatoIl), style: t.labelMedium),
                  ],
                ),
              ],
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
