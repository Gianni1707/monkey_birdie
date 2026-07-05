import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/specie_immagine_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/nome_specie.dart';
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
    // I risultati scorrono; gli altri stati sono centrati con respiro.
    final centrato = state is! RecognitionResult;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: centrato
            ? Center(child: _body(context, ref, state))
            : _body(context, ref, state),
      ),
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
          onAnnulla: ctrl.reset,
        ),
      // Gestito a schermo pieno in build(): qui non raggiungibile.
      RecognitionConfermaPosizione() => const SizedBox.shrink(),
      RecognitionSaved() => _Esito(
          icon: Icons.check_circle,
          ok: true,
          message: l10n.addedToCollection,
          onAgain: ctrl.reset,
        ),
      RecognitionError(:final message) => _Esito(
          icon: Icons.error_outline,
          ok: false,
          message: message,
          onAgain: ctrl.reset,
        ),
    };
  }
}

/// Grande pulsante di cattura del canto (hero): cerchio verde (o mattone mentre
/// registra), ombra tenue, etichetta serif sotto.
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
    final bg = pulsing ? scheme.error : scheme.primary;
    final fg = pulsing ? scheme.onError : scheme.onPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: bg.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: bg,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: 164,
                height: 164,
                child: Icon(icon, size: 68, color: fg),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

/// Stato iniziale: pulsante canto (mic) + due comandi foto ampi (scatta/carica).
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
        const SizedBox(height: 36),
        _DivisoreOppure(testo: l10n.orFromPhoto),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ComandoFoto(
                icon: Icons.photo_camera_outlined,
                label: l10n.takePhoto,
                onTap: onScatta,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ComandoFoto(
                icon: Icons.photo_library_outlined,
                label: l10n.uploadPhoto,
                onTap: onCarica,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Comando foto ampio (icona sopra, etichetta sotto), tinta "mattone" tenue.
class _ComandoFoto extends StatelessWidget {
  const _ComandoFoto({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.secondaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: scheme.onSecondaryContainer),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Divisore "oppure da foto" con linee ai lati.
class _DivisoreOppure extends StatelessWidget {
  const _DivisoreOppure({required this.testo});
  final String testo;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            testo,
            style:
                Theme.of(context).textTheme.labelMedium?.copyWith(color: muted),
          ),
        ),
        const Expanded(child: Divider()),
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
        const SizedBox(height: 20),
        Text(label, textAlign: TextAlign.center),
      ],
    );
  }
}

/// Risultati del riconoscimento: card HERO del candidato selezionato (default =
/// migliore) + "Altre possibilità" (toccabili per selezionarle) + barra "Non
/// sono sicuro" / "Conferma e salva". Il salvataggio (posizione + foto utente)
/// resta invariato: "Conferma e salva" chiama [onScegli] sul selezionato.
class _Risultati extends StatefulWidget {
  const _Risultati({
    required this.candidati,
    required this.onScegli,
    required this.onAnnulla,
    this.incerto = false,
  });
  final List<CandidatoSpecie> candidati;
  final void Function(CandidatoSpecie) onScegli;
  final VoidCallback onAnnulla;
  final bool incerto; // confidenza sotto soglia (foto): "non sono sicuro"

  @override
  State<_Risultati> createState() => _RisultatiState();
}

class _RisultatiState extends State<_Risultati> {
  late int _sel = _primoSalvabile();

  int _primoSalvabile() {
    final i = widget.candidati.indexWhere((c) => c.salvabile);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final candidati = widget.candidati;
    if (candidati.isEmpty) {
      return Center(child: Text(l10n.noSpecies));
    }
    final selezionato = candidati[_sel];
    final altri = [
      for (var i = 0; i < candidati.length; i++)
        if (i != _sel) i,
    ];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Text(
                l10n.resultsIntro,
                style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              if (widget.incerto) ...[
                const SizedBox(height: 14),
                _BannerIncerto(testo: l10n.uncertainPhoto),
              ],
              const SizedBox(height: 16),
              _HeroCandidato(candidato: selezionato, migliore: _sel == 0),
              if (altri.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(l10n.otherPossibilities, style: t.titleLarge),
                const SizedBox(height: 12),
                for (final i in altri)
                  _RigaPossibilita(
                    candidato: candidati[i],
                    onTap: () => setState(() => _sel = i),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        _BarraRisultati(
          onAnnulla: widget.onAnnulla,
          onConferma: selezionato.salvabile
              ? () => widget.onScegli(selezionato)
              : null,
        ),
      ],
    );
  }
}

/// Card grande del candidato selezionato: foto di riferimento + chip "Migliore
/// corrispondenza" (solo se è il top) + % + nome + scientifico + descrizione.
class _HeroCandidato extends StatelessWidget {
  const _HeroCandidato({required this.candidato, required this.migliore});
  final CandidatoSpecie candidato;
  final bool migliore;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final c = candidato;
    final l10n = AppLocalizations.of(context);
    final perc = (c.predizione.confidenza * 100).toStringAsFixed(0);
    final nome = c.specie?.nomeDaMostrare ?? c.predizione.nomeComune;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: _HeroImmagine(c.predizione.nomeScientifico),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (migliore)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.stars,
                              size: 16,
                              color: scheme.onPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.bestMatch,
                              style: t.labelMedium?.copyWith(
                                color: scheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    Text('$perc%', style: t.titleMedium),
                  ],
                ),
                const SizedBox(height: 10),
                Text(nome, style: t.headlineSmall),
                Text(
                  c.predizione.nomeScientifico,
                  style: t.titleSmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (c.specie?.descrizione != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    c.specie!.descrizione!,
                    style: t.bodyMedium?.copyWith(height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (!c.salvabile) ...[
                  const SizedBox(height: 10),
                  Text(
                    l10n.notInCatalog,
                    style: t.bodySmall?.copyWith(color: scheme.error),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Riga di una possibilità alternativa: miniatura + nome + scientifico + %.
/// Tap → diventa il candidato selezionato (hero).
class _RigaPossibilita extends StatelessWidget {
  const _RigaPossibilita({required this.candidato, required this.onTap});
  final CandidatoSpecie candidato;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final c = candidato;
    final perc = (c.predizione.confidenza * 100).toStringAsFixed(0);
    final nome = c.specie?.nomeDaMostrare ?? c.predizione.nomeComune;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              _SpecieThumb(c.predizione.nomeScientifico),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nome,
                      style: t.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      c.predizione.nomeScientifico,
                      style: t.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('$perc%', style: t.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra azioni dei risultati: "Non sono sicuro" (annulla) + "Conferma e salva".
class _BarraRisultati extends StatelessWidget {
  const _BarraRisultati({required this.onAnnulla, required this.onConferma});
  final VoidCallback onAnnulla;
  final VoidCallback? onConferma;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Etichette su UNA riga: FittedBox rimpicciolisce se lo spazio è poco
    // (niente più "Non sono sicuro" a capo su 3 righe).
    Widget unaRiga(String testo) => FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(testo, maxLines: 1, softWrap: false),
        );
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onAnnulla,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: unaRiga(l10n.notSure),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: onConferma,
            icon: const Icon(Icons.check_circle_outline),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            label: unaRiga(l10n.confirmAndSave),
          ),
        ),
      ],
    );
  }
}

/// Immagine hero grande della specie (thumbnail iNaturalist). Placeholder mentre
/// carica / se assente.
class _HeroImmagine extends ConsumerWidget {
  const _HeroImmagine(this.nomeScientifico);
  final String nomeScientifico;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(specieThumbnailProvider(nomeScientifico));
    return async.maybeWhen(
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
        size: 40,
        color: scheme.onPrimaryContainer,
      ),
    );
  }
}

/// Banner "non sono sicuro" (foto sotto soglia), tono terziario tenue.
class _BannerIncerto extends StatelessWidget {
  const _BannerIncerto({required this.testo});
  final String testo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.help_outline, color: scheme.onTertiaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              testo,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onTertiaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Esito (salvato / errore): icona in cerchio colorato + messaggio + riprova.
class _Esito extends StatelessWidget {
  const _Esito({
    required this.icon,
    required this.message,
    required this.onAgain,
    required this.ok,
  });
  final IconData icon;
  final String message;
  final VoidCallback onAgain;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = ok ? scheme.primaryContainer : scheme.errorContainer;
    final fg = ok ? scheme.onPrimaryContainer : scheme.onErrorContainer;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: bg,
          child: Icon(icon, size: 44, color: fg),
        ),
        const SizedBox(height: 20),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        FilledButton(
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
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 60,
        height: 60,
        child: async.maybeWhen(
          data: (url) => url == null
              ? const _ThumbPlaceholder()
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
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
