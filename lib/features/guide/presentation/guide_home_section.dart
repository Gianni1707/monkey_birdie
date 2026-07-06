import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/guida.dart';
import '../../../data/models/nota_stagionale.dart';
import '../../../data/repositories/specie_immagine_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/nome_specie.dart';
import '../application/guide_providers.dart';
import 'guida_detail_screen.dart';
import 'guide_list_screen.dart';

/// Sezione "News e guide" della Home: un riquadro grande "featured" (consiglio
/// del giorno) + due piccoli sotto (in questo periodo · uccello del giorno).
/// Tutti toccabili. Selezioni deterministiche per data.
class GuideHomeSection extends ConsumerWidget {
  const GuideHomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final consiglio = ref.watch(consiglioDelGiornoProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.newsAndGuides, style: t.titleMedium),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const GuideListScreen(),
                ),
              ),
              child: Text(l10n.seeAll),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (consiglio != null) _Featured(consiglio),
        const SizedBox(height: 12),
        const SizedBox(
          height: 232,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _NotaCard()),
              SizedBox(width: 12),
              Expanded(child: _UccelloCard()),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pill (emoji/testo) per le etichette dei riquadri.
class _Chip extends StatelessWidget {
  const _Chip(this.testo, {this.icona});
  final String testo;
  final IconData? icona;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icona != null) ...[
            Icon(icona, size: 14, color: scheme.onPrimaryContainer),
            const SizedBox(width: 5),
          ],
          Text(
            testo,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Riquadro grande: consiglio del giorno.
class _Featured extends StatelessWidget {
  const _Featured(this.guida);
  final Guida guida;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Riquadro(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => GuidaDetailScreen(guida: guida)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Chip(
            AppLocalizations.of(context).tipOfTheDay,
            icona: Icons.tips_and_updates_outlined,
          ),
          const SizedBox(height: 10),
          Text(guida.titolo, style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            guida.corpo,
            maxLines: 3,
            overflow: TextOverflow.fade,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Etichetta a riga (icona + testo con ellissi) per i riquadri piccoli, dove un
/// pill intero sforerebbe la larghezza.
class _Etichetta extends StatelessWidget {
  const _Etichetta(this.testo, this.icona);
  final String testo;
  final IconData icona;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icona, size: 15, color: scheme.primary),
        const SizedBox(width: 6),
        Expanded(
          // Etichetta INTERA (va a capo su 2 righe): niente puntini di troncamento.
          child: Text(
            testo,
            maxLines: 2,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
          ),
        ),
      ],
    );
  }
}

/// Riquadro piccolo: nota stagionale del mese (tap → testo per esteso).
class _NotaCard extends ConsumerWidget {
  const _NotaCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final nota = ref.watch(notaStagionaleProvider).valueOrNull;
    return _Riquadro(
      onTap: nota == null ? null : () => _mostra(context, nota),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Etichetta(l10n.inThisPeriod, Icons.calendar_month_outlined),
          const SizedBox(height: 8),
          if (nota != null) ...[
            Text(
              nota.titolo,
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            // Testo che SFUMA in fondo (niente puntini); il tap apre l'intero.
            Expanded(
              child: Text(
                nota.testo,
                overflow: TextOverflow.fade,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _mostra(BuildContext context, NotaStagionale nota) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(nota.titolo),
        content: SingleChildScrollView(child: Text(nota.testo)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          ),
        ],
      ),
    );
  }
}

/// Riquadro piccolo: uccello del giorno (tap → scheda specie).
class _UccelloCard extends ConsumerWidget {
  const _UccelloCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final specie = ref.watch(uccelloDelGiornoProvider).valueOrNull;
    return _Riquadro(
      onTap: specie == null ? null : () => context.push('/specie/${specie.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Etichetta(l10n.birdOfTheDay, Icons.auto_awesome_outlined),
          const SizedBox(height: 10),
          if (specie != null) ...[
            // Foto GRANDE (riempie la larghezza) sotto la scritta.
            Expanded(child: _FotoUccello(specie.nomeScientifico)),
            const SizedBox(height: 8),
            Text(
              specie.nomeDaMostrare,
              maxLines: 2,
              overflow: TextOverflow.fade,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
          ],
        ],
      ),
    );
  }
}

/// Foto specie GRANDE (riempie lo spazio del riquadro), thumbnail iNaturalist;
/// placeholder curato (uccellino) se assente/in caricamento.
class _FotoUccello extends ConsumerWidget {
  const _FotoUccello(this.nomeScientifico);
  final String nomeScientifico;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final url = ref.watch(specieThumbnailProvider(nomeScientifico)).valueOrNull;
    final placeholder = Container(
      width: double.infinity,
      color: scheme.primaryContainer,
      alignment: Alignment.center,
      child: Icon(Icons.flutter_dash, size: 40, color: scheme.onPrimaryContainer),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: url == null
          ? placeholder
          : Image.network(
              url,
              width: double.infinity,
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
              errorBuilder: (_, __, ___) => placeholder,
              loadingBuilder: (_, child, p) => p == null ? child : placeholder,
            ),
    );
  }
}

/// Contenitore-riquadro con angoli morbidi, bordo e ripple.
class _Riquadro extends StatelessWidget {
  const _Riquadro({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: child,
        ),
      ),
    );
  }
}
