import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/specie.dart';
import '../../../data/repositories/specie_immagine_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/nome_specie.dart';
import '../../../shared/ordine_tassonomico.dart';
import '../../../shared/widgets/state_views.dart';
import '../../desideri/application/desideri_providers.dart';
import '../../map/presentation/habitat_mappa.dart';
import '../../profilo/presentation/preferito_button.dart';
import '../application/collection_controller.dart';

/// UT04 — scheda informativa sulla specie (+ UT05 habitat, morfologia BIRDBASE,
/// ordine tassonomico). Il cuore preferito è sulla hero; il desiderio e la
/// condivisione sono nella barra azioni in basso.
class SpecieDetailScreen extends ConsumerWidget {
  const SpecieDetailScreen({super.key, required this.specieId});
  final String specieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSpecie = ref.watch(specieProvider(specieId));

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).speciesCard)),
      body: asyncSpecie.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: '$e',
          onRetry: () => ref.invalidate(specieProvider(specieId)),
        ),
        data: (specie) => _Dettaglio(specie),
      ),
    );
  }
}

class _Dettaglio extends ConsumerWidget {
  const _Dettaglio(this.specie);
  final Specie specie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final ordineIt = ordineInItaliano(specie.ordine);

    // Contenuto scorrevole + barra azioni pinnata in basso.
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _Hero(specieId: specie.id, nomeScientifico: specie.nomeScientifico),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      specie.nomeDaMostrare,
                      style: theme.textTheme.headlineMedium,
                    ),
                    Text(
                      specie.nomeScientifico,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge SCORREVOLI orizzontalmente (rarità, pericolo, ordine).
              _BadgeScorrevoli(
                children: [
                  _Badge(
                    icona: Icons.verified_outlined,
                    testo: _rarita(l10n, specie.rarita),
                  ),
                  _Badge(
                    icona: Icons.eco_outlined,
                    testo: _pericolo(l10n, specie.livelloPericolo),
                  ),
                  if (ordineIt != null)
                    _Badge(icona: Icons.account_tree_outlined, testo: ordineIt),
                ],
              ),
              if (specie.descrizione != null)
                _SezioneCard(
                  icona: Icons.description_outlined,
                  titolo: l10n.description,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        specie.descrizione!,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                      ),
                      if (specie.descrizioneFonte != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          l10n.descriptionSource(specie.descrizioneFonte!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              _Morfologia(specie),
              _SezioneCard(
                icona: Icons.public,
                titolo: l10n.whereItLives,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (specie.habitatDescrizione != null) ...[
                      Text(
                        specie.habitatDescrizione!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    HabitatMiniMappa(
                      specieId: specie.id,
                      nomeScientifico: specie.nomeScientifico,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _BarraAzioni(specie),
      ],
    );
  }

  String _rarita(AppLocalizations l10n, String r) => switch (r) {
        'comune' => l10n.rarityCommon,
        'poco_comune' => l10n.rarityUncommon,
        'rara' => l10n.rarityRare,
        'molto_rara' => l10n.rarityVeryRare,
        _ => r,
      };

  String _pericolo(AppLocalizations l10n, int p) => switch (p) {
        0 => l10n.dangerNotReported,
        1 => l10n.dangerLow,
        2 => l10n.dangerMedium,
        _ => l10n.dangerHigh,
      };
}

/// Riga di badge scorrevoli orizzontalmente (non vanno a capo, si scorrono).
class _BadgeScorrevoli extends StatelessWidget {
  const _BadgeScorrevoli({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icona, required this.testo});
  final IconData icona;
  final String testo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icona, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text(testo, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

/// Card di sezione (icona + titolo serif + contenuto) su sfondo chiaro.
class _SezioneCard extends StatelessWidget {
  const _SezioneCard({
    required this.icona,
    required this.titolo,
    required this.child,
  });
  final IconData icona;
  final String titolo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icona, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(titolo, style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Griglia 2×2 dei tratti morfologici (BIRDBASE). Card fisse: dove il dato manca
/// -> "n/d" (la LUNGHEZZA corporea non è nel dataset, quindi resta sempre n/d).
class _Morfologia extends StatelessWidget {
  const _Morfologia(this.specie);
  final Specie specie;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final na = l10n.notAvailable;

    final celle = <Widget>[
      _MorfoCard(
        icona: Icons.straighten,
        etichetta: l10n.lengthLabel,
        valore: na, // lunghezza assente in BIRDBASE
      ),
      _MorfoCard(
        icona: Icons.monitor_weight_outlined,
        etichetta: l10n.weightLabel,
        valore: _range(specie.pesoMinG, specie.pesoMaxG, suffisso: ' g') ?? na,
      ),
      _MorfoCard(
        icona: Icons.egg_outlined,
        etichetta: l10n.eggsLabel,
        valore: _range(specie.uovaMin, specie.uovaMax) ?? na,
      ),
      _MorfoCard(
        icona: Icons.house_outlined,
        etichetta: l10n.nestLabel,
        valore: _capitalizza(specie.nido) ?? na,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.straighten,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(l10n.morphology, style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: celle[0]),
              const SizedBox(width: 12),
              Expanded(child: celle[1]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: celle[2]),
              const SizedBox(width: 12),
              Expanded(child: celle[3]),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.morphologySource,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  /// "min-max" (o "min" se uguali/uno solo), con suffisso opzionale. Null se
  /// entrambi assenti.
  static String? _range(int? min, int? max, {String suffisso = ''}) {
    if (min == null && max == null) return null;
    final a = min ?? max!;
    final b = max ?? min!;
    return a == b ? '$a$suffisso' : '$a-$b$suffisso';
  }

  static String? _capitalizza(String? s) {
    final t = s?.trim();
    if (t == null || t.isEmpty) return null;
    return t[0].toUpperCase() + t.substring(1);
  }
}

class _MorfoCard extends StatelessWidget {
  const _MorfoCard({
    required this.icona,
    required this.etichetta,
    required this.valore,
  });
  final IconData icona;
  final String etichetta;
  final String valore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icona, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            etichetta.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 0.6,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valore,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra azioni pinnata: "Voglio avvistarlo" (toggle desiderio) + Condividi.
class _BarraAzioni extends ConsumerWidget {
  const _BarraAzioni(this.specie);
  final Specie specie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final desiderato = ref.watch(desideriIdsProvider).contains(specie.id);

    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _toggleDesiderio(context, ref, desiderato),
                  icon: Icon(desiderato ? Icons.flag : Icons.flag_outlined),
                  label: Text(
                    desiderato ? l10n.removeFromWishlist : l10n.addToWishlist,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: l10n.share,
                onPressed: () => _condividi(context),
                icon: const Icon(Icons.ios_share),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleDesiderio(
    BuildContext context,
    WidgetRef ref,
    bool desiderato,
  ) async {
    try {
      await ref
          .read(desideriControllerProvider)
          .toggle(specie.id, attuale: desiderato);
    } catch (e) {
      if (!context.mounted) return;
      final msg = e is Failure ? e.message : e.toString();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _condividi(BuildContext context) async {
    final testo = StringBuffer()
      ..write('${specie.nomeDaMostrare} (${specie.nomeScientifico})');
    if (specie.descrizioneUrl != null) {
      testo.write('\n${specie.descrizioneUrl}');
    }
    try {
      await Share.share(testo.toString());
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}

/// Immagine "hero" della specie (thumbnail iNaturalist, best-effort) col cuore
/// preferito in alto a destra. In mancanza di foto, fascia decorativa.
class _Hero extends ConsumerWidget {
  const _Hero({required this.specieId, required this.nomeScientifico});
  final String specieId;
  final String nomeScientifico;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(specieThumbnailProvider(nomeScientifico));
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          async.maybeWhen(
            data: (url) => url == null
                ? const _HeroPlaceholder()
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                    errorBuilder: (_, __, ___) => const _HeroPlaceholder(),
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : const _HeroPlaceholder(),
                  ),
            orElse: () => const _HeroPlaceholder(),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: PreferitoIconButton(specieId: specieId),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.primaryContainer,
      alignment: Alignment.center,
      child: Icon(
        Icons.photo_camera_back_outlined,
        size: 44,
        color: scheme.onPrimaryContainer,
      ),
    );
  }
}
