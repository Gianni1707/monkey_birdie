import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/state_views.dart';
import '../application/guide_providers.dart';
import 'guida_detail_screen.dart';

/// Elenco completo delle guide, raggruppate per categoria. Aperto da "Tutti"
/// nella sezione "News e guide" della Home.
class GuideListScreen extends ConsumerWidget {
  const GuideListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final async = ref.watch(guideProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.guidesTitle)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: '$e',
          onRetry: () => ref.invalidate(guideProvider),
        ),
        data: (guide) {
          if (guide.isEmpty) {
            return EmptyState(
              icon: Icons.menu_book_outlined,
              title: l10n.guidesTitle,
              subtitle: '—',
            );
          }
          // guide già ordinate per `ordine` → le categorie sono contigue:
          // inserisco un'intestazione quando cambia la categoria.
          final items = <Widget>[];
          String? catCorrente;
          for (final g in guide) {
            if (g.categoria != catCorrente) {
              catCorrente = g.categoria;
              items.add(
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 18, 4, 6),
                  child: Text(
                    g.categoria.toUpperCase(),
                    style: t.labelLarge?.copyWith(
                      color: scheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              );
            }
            items.add(
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(g.titolo, style: t.titleMedium),
                  subtitle: Text(
                    g.corpo,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => GuidaDetailScreen(guida: g),
                    ),
                  ),
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: items,
          );
        },
      ),
    );
  }
}
