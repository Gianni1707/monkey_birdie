import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/avvistamento_tile.dart';
import '../../../shared/widgets/contenuto_centrato.dart';
import '../../collection/application/collection_controller.dart';
import '../../guide/presentation/guide_home_section.dart';
import '../../profilo/application/profilo_providers.dart';
import '../../recognition/application/recognition_controller.dart';
import '../../recognition/application/recognition_state.dart';
import '../../recognition/presentation/cattura_screen.dart';

/// UT — Home (prima tab). Saluto personalizzato, comandi di cattura (Audio/Foto)
/// che avviano il flusso di riconoscimento ESISTENTE, e gli ultimi avvistamenti
/// dell'utente. Solo aspetto + cablaggio di dati già esistenti.
///
/// L'ascolto del canto parte IN-PLACE (la card Audio diventa "in ascolto"); solo
/// quando inizia l'ANALISI si apre la schermata dell'esito (candidati → scelta →
/// conferma → salvataggio), riusando `RecognitionScreen`.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.onVediCollezione});

  /// Passa alla tab Collezione (per "Vedi tutti").
  final VoidCallback onVediCollezione;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final nome = ref.watch(mioProfiloProvider).valueOrNull?.username ?? '';

    // Quando (dopo ascolto o scatto) parte l'analisi, apri la schermata esito.
    ref.listen(recognitionControllerProvider, (prev, next) {
      if (next is RecognitionAnalyzing && prev is! RecognitionAnalyzing) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const CatturaScreen()),
        );
      }
    });

    return ContenutoCentrato(
      child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Text(
          l10n.homeWelcome(nome).trim().toUpperCase(),
          style: t.labelLarge?.copyWith(
            color: scheme.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(l10n.homeSubtitle, style: t.headlineSmall),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: _AudioCard()),
            const SizedBox(width: 14),
            Expanded(
              child: _CapturaCard(
                color: scheme.secondary,
                onColor: scheme.onSecondary,
                icon: Icons.photo_camera_outlined,
                titolo: l10n.homePhotoTitle,
                sottotitolo: l10n.homePhotoHint,
                onTap: () => _scegliFoto(context, ref),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const GuideHomeSection(),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.homeLatestSightings, style: t.titleMedium),
            TextButton(onPressed: onVediCollezione, child: Text(l10n.seeAll)),
          ],
        ),
        const SizedBox(height: 4),
        const _UltimiAvvistamenti(),
      ],
      ),
    );
  }

  /// Foto: chooser scatta/carica (entrambi i flussi esistenti). L'analisi che ne
  /// segue apre la schermata esito (via il listener sopra).
  void _scegliFoto(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(recognitionControllerProvider.notifier);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.pop(sheetCtx);
                notifier.scattaFoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.uploadPhoto),
              onTap: () {
                Navigator.pop(sheetCtx);
                notifier.caricaFoto();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Card Audio "in-place": idle → tocca per ascoltare; recording → rossa, tocca
/// per fermare; analyzing → non tappabile (sta per aprirsi l'esito).
class _AudioCard extends ConsumerWidget {
  const _AudioCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(recognitionControllerProvider);
    final notifier = ref.read(recognitionControllerProvider.notifier);

    final registrando = state is RecognitionRecording;
    final analizzando = state is RecognitionAnalyzing;

    return _CapturaCard(
      color: registrando ? scheme.error : scheme.primary,
      onColor: registrando ? scheme.onError : scheme.onPrimary,
      icon: registrando ? Icons.stop : Icons.mic_none,
      titolo: l10n.homeAudioTitle,
      sottotitolo: registrando
          ? l10n.recordingTapToStop
          : (analizzando ? l10n.analyzingSong : l10n.homeAudioHint),
      onTap: analizzando
          ? null
          : (registrando
              ? notifier.fermaEAnalizza
              : notifier.avviaRegistrazione),
    );
  }
}

/// Card di cattura ampia (Audio/Foto), stile mockup: icona + titolo + hint.
class _CapturaCard extends StatelessWidget {
  const _CapturaCard({
    required this.color,
    required this.onColor,
    required this.icon,
    required this.titolo,
    required this.sottotitolo,
    required this.onTap,
  });
  final Color color;
  final Color onColor;
  final IconData icon;
  final String titolo;
  final String sottotitolo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 34, color: onColor),
              const SizedBox(height: 12),
              Text(
                titolo,
                style: t.titleMedium?.copyWith(color: onColor),
              ),
              const SizedBox(height: 2),
              Text(
                sottotitolo.toUpperCase(),
                textAlign: TextAlign.center,
                style: t.labelSmall?.copyWith(
                  color: onColor.withValues(alpha: 0.85),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ultimi avvistamenti dell'utente (dato esistente da collezioneProvider).
class _UltimiAvvistamenti extends ConsumerWidget {
  const _UltimiAvvistamenti();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(collezioneProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text('$e', style: Theme.of(context).textTheme.bodySmall),
      ),
      data: (avvistamenti) {
        if (avvistamenti.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              l10n.emptyCollectionSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          );
        }
        final ultimi = avvistamenti.take(3).toList(growable: false);
        return Column(
          children: [for (final a in ultimi) AvvistamentoTile(a)],
        );
      },
    );
  }
}
