import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../application/dintorni_providers.dart';
import 'dintorni_screen.dart' show DintorniPermessoNegato, riprovaDintorni;
import 'dintorni_widgets.dart';

/// Sezione Home "Specie presenti in questa zona": anteprima di poche specie
/// (community in cima) + "Vedi tutte". Additiva, in fondo alla Home.
class DintorniHomeSection extends ConsumerWidget {
  const DintorniHomeSection({super.key});

  static const int _anteprima = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final async = ref.watch(uccelliVicinoProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.nearbyTitle, style: theme.textTheme.titleMedium),
            ),
            async.maybeWhen(
              data: (l) => l.length > _anteprima
                  ? TextButton(
                      onPressed: () => context.push('/dintorni'),
                      child: Text(l10n.seeAll),
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 4),
        async.when(
          loading: () => const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => DintorniPermessoNegato(
            onRiprova: () => riprovaDintorni(ref),
          ),
          data: (lista) {
            if (lista.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.nearbyNoData,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            final anteprima = lista.take(_anteprima).toList();
            return SizedBox(
              height: 172,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: anteprima.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _CardSpecie(anteprima[i]),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CardSpecie extends StatelessWidget {
  const _CardSpecie(this.specie);
  final SpecieVicina specie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 132,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/specie/${specie.specieId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 104,
              width: double.infinity,
              child: SpecieVicinaThumb(specie.nomeScientifico),
            ),
            const SizedBox(height: 6),
            Text(
              specie.nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: BadgeDintorni(community: specie.community),
            ),
          ],
        ),
      ),
    );
  }
}
