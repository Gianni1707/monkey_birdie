import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/specie_immagine_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../collection/application/collection_controller.dart';
import '../application/recognition_controller.dart';
import '../application/recognition_state.dart';
import 'conferma_posizione_view.dart';

/// UT02 — cattura audio, riconoscimento on-device, conferma e salvataggio.
class RecognitionScreen extends ConsumerWidget {
  const RecognitionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(recognitionControllerProvider, (_, next) {
      if (next is RecognitionSaved) {
        ref.invalidate(collezioneProvider); // aggiorna la collezione
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).sightingSaved)),
        );
      }
    });

    final state = ref.watch(recognitionControllerProvider);
    // Conferma posizione: mappa a schermo pieno (non centrata nel padding).
    if (state is RecognitionConfermaPosizione) {
      return ConfermaPosizioneView(stato: state);
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(child: _body(context, ref, state)),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, RecognitionState state) {
    final ctrl = ref.read(recognitionControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return switch (state) {
      RecognitionIdle() => _IdleView(
          onCanto: ctrl.avviaRegistrazione,
          onScatta: ctrl.scattaFoto,
          onCarica: ctrl.caricaFoto,
        ),
      RecognitionRecording() => _MicButton(
          label: l10n.recordingTapToStop,
          icon: Icons.stop,
          pulsing: true,
          onTap: ctrl.fermaEAnalizza,
        ),
      RecognitionAnalyzing(:final messaggio) =>
        _Busy(label: messaggio ?? l10n.analyzingSong),
      RecognitionSaving() => _Busy(label: l10n.saving),
      RecognitionResult(:final candidati, :final incerto) => _Risultati(
          candidati: candidati,
          incerto: incerto,
          onScegli: ctrl.salva,
        ),
      // Gestito a schermo pieno in build(): qui non raggiungibile.
      RecognitionConfermaPosizione() => const SizedBox.shrink(),
      RecognitionSaved() => _Esito(
          icon: Icons.check_circle,
          message: l10n.addedToCollection,
          onAgain: ctrl.reset,
        ),
      RecognitionError(:final message) => _Esito(
          icon: Icons.error_outline,
          message: message,
          onAgain: ctrl.reset,
        ),
    };
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.pulsing = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool pulsing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 72,
            backgroundColor: pulsing ? scheme.error : scheme.primary,
            child: Icon(icon, size: 64, color: scheme.onPrimary),
          ),
        ),
        const SizedBox(height: 24),
        Text(label, textAlign: TextAlign.center),
      ],
    );
  }
}

/// Stato iniziale: pulsante canto (mic) + pulsanti foto (scatta/carica).
class _IdleView extends StatelessWidget {
  const _IdleView({
    required this.onCanto,
    required this.onScatta,
    required this.onCarica,
  });
  final VoidCallback onCanto;
  final VoidCallback onScatta;
  final VoidCallback onCarica;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MicButton(
          label: l10n.tapToRecord,
          icon: Icons.mic_none,
          onTap: onCanto,
        ),
        const SizedBox(height: 28),
        Text(
          l10n.orFromPhoto,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: onScatta,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(l10n.takePhoto),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onCarica,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.uploadPhoto),
            ),
          ],
        ),
      ],
    );
  }
}

class _Busy extends StatelessWidget {
  const _Busy({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(label),
      ],
    );
  }
}

class _Risultati extends StatelessWidget {
  const _Risultati({
    required this.candidati,
    required this.onScegli,
    this.incerto = false,
  });
  final List<CandidatoSpecie> candidati;
  final void Function(CandidatoSpecie) onScegli;
  final bool incerto; // confidenza sotto soglia (foto): "non sono sicuro"

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (candidati.isEmpty) {
      return Text(l10n.noSpecies);
    }
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.results, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(l10n.chooseSpecies),
        if (incerto) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: scheme.onTertiaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.uncertainPhoto,
                    style: TextStyle(color: scheme.onTertiaryContainer),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        ...candidati.map((c) {
          final perc = (c.predizione.confidenza * 100).toStringAsFixed(0);
          return Card(
            child: ListTile(
              leading: _SpecieThumb(c.predizione.nomeScientifico),
              title: Text(c.specie?.nomeComune ?? c.predizione.nomeComune),
              subtitle: Text(
                '${c.predizione.nomeScientifico} · $perc%'
                '${c.salvabile ? '' : ' · ${l10n.notInCatalog}'}',
              ),
              trailing: c.salvabile
                  ? const Icon(Icons.add_circle_outline)
                  : const Icon(Icons.block),
              enabled: c.salvabile,
              onTap: c.salvabile ? () => onScegli(c) : null,
            ),
          );
        }),
      ],
    );
  }
}

class _Esito extends StatelessWidget {
  const _Esito({
    required this.icon,
    required this.message,
    required this.onAgain,
  });
  final IconData icon;
  final String message;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        FilledButton.tonal(
          onPressed: onAgain,
          child: Text(AppLocalizations.of(context).restart),
        ),
      ],
    );
  }
}

/// Miniatura della specie candidata (foto da iNaturalist per nome scientifico),
/// per aiutare a riconoscere l'uccello. Placeholder mentre carica / se assente.
class _SpecieThumb extends ConsumerWidget {
  const _SpecieThumb(this.nomeScientifico);
  final String nomeScientifico;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(specieThumbnailProvider(nomeScientifico));
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 52,
        height: 52,
        child: async.maybeWhen(
          data: (url) => url == null
              ? const _ThumbPlaceholder()
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _ThumbPlaceholder(),
                  loadingBuilder: (_, child, progress) =>
                      progress == null ? child : const _ThumbPlaceholder(),
                ),
          orElse: () => const _ThumbPlaceholder(),
        ),
      ),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
