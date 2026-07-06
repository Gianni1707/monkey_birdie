import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/specie_immagine_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../application/dintorni_providers.dart';

/// Miniatura specie (thumbnail iNaturalist per nome scientifico), con
/// placeholder in caricamento/assenza. Angoli arrotondati, riempie il genitore.
class SpecieVicinaThumb extends ConsumerWidget {
  const SpecieVicinaThumb(this.nomeScientifico, {super.key, this.raggio = 12});
  final String nomeScientifico;
  final double raggio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(specieThumbnailProvider(nomeScientifico));
    return ClipRRect(
      borderRadius: BorderRadius.circular(raggio),
      child: async.maybeWhen(
        data: (url) => url == null
            ? const _Placeholder()
            : Image.network(
                url,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                errorBuilder: (_, __, ___) => const _Placeholder(),
              ),
        orElse: () => const _Placeholder(),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.flutter_dash, color: scheme.onSurfaceVariant),
    );
  }
}

/// Chip che distingue il dato community (reale) da quello GBIF (storico).
class BadgeDintorni extends StatelessWidget {
  const BadgeDintorni({super.key, required this.community});
  final bool community;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final bg = community ? scheme.secondaryContainer : scheme.surfaceContainerHighest;
    final fg = community ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;
    final testo =
        community ? l10n.nearbySeenRecently : l10n.nearbyPresentInArea;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            community ? Icons.groups_outlined : Icons.public,
            size: 13,
            color: fg,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              testo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: fg, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Riga della lista completa: miniatura + nome + badge, tap → scheda specie.
class SpecieVicinaTile extends StatelessWidget {
  const SpecieVicinaTile(this.specie, {super.key});
  final SpecieVicina specie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: SizedBox(
        width: 56,
        height: 56,
        child: SpecieVicinaThumb(specie.nomeScientifico, raggio: 10),
      ),
      title: Text(specie.nome, style: theme.textTheme.titleMedium),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [BadgeDintorni(community: specie.community)],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/specie/${specie.specieId}'),
    );
  }
}
