import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../collection/application/collection_controller.dart';
import '../application/recognition_controller.dart';
import '../application/recognition_state.dart';

/// UT02 — cattura audio, riconoscimento on-device, conferma e salvataggio.
class RecognitionScreen extends ConsumerWidget {
  const RecognitionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(recognitionControllerProvider, (_, next) {
      if (next is RecognitionSaved) {
        ref.invalidate(collezioneProvider); // aggiorna la collezione
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avvistamento salvato!')),
        );
      }
    });

    final state = ref.watch(recognitionControllerProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(child: _body(context, ref, state)),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, RecognitionState state) {
    final ctrl = ref.read(recognitionControllerProvider.notifier);

    return switch (state) {
      RecognitionIdle() => _MicButton(
          label: 'Tocca per registrare un canto',
          icon: Icons.mic_none,
          onTap: ctrl.avviaRegistrazione,
        ),
      RecognitionRecording() => _MicButton(
          label: 'Registrazione… tocca per fermare e analizzare',
          icon: Icons.stop,
          pulsing: true,
          onTap: ctrl.fermaEAnalizza,
        ),
      RecognitionAnalyzing() => const _Busy(label: 'Analisi del canto…'),
      RecognitionSaving() => const _Busy(label: 'Salvataggio…'),
      RecognitionResult(:final candidati, :final posizione) => _Risultati(
          candidati: candidati,
          posizioneMancante: posizione == null,
          onScegli: ctrl.salva,
        ),
      RecognitionSaved() => _Esito(
          icon: Icons.check_circle,
          message: 'Avvistamento aggiunto alla collezione.',
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
    this.posizioneMancante = false,
  });
  final List<CandidatoSpecie> candidati;
  final void Function(CandidatoSpecie) onScegli;
  final bool posizioneMancante;

  @override
  Widget build(BuildContext context) {
    if (candidati.isEmpty) {
      return const Text('Nessuna specie riconosciuta. Riprova.');
    }
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Risultati', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        const Text('Scegli la specie corretta per salvare l’avvistamento:'),
        if (posizioneMancante) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.location_off, color: scheme.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Posizione non rilevata: verrà salvato senza posizione precisa.',
                    style: TextStyle(color: scheme.onErrorContainer),
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
              title: Text(c.specie?.nomeComune ?? c.predizione.nomeComune),
              subtitle: Text(
                '${c.predizione.nomeScientifico} · $perc%'
                '${c.salvabile ? '' : ' · non in catalogo'}',
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
          child: const Text('Nuova registrazione'),
        ),
      ],
    );
  }
}
