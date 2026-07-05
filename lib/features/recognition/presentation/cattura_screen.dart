import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/recognition_controller.dart';
import '../application/recognition_state.dart';
import 'recognition_screen.dart';

/// Schermata di cattura pushata dalla Home (pulsanti Audio/Foto). Riusa
/// integralmente [RecognitionScreen] (che reagisce a `recognitionController`):
/// registrazione, analisi, candidati, conferma posizione, salvataggio.
/// Torna alla Home quando il flusso si conclude (reset a Idle dopo "Ancora").
class CatturaScreen extends ConsumerWidget {
  const CatturaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(recognitionControllerProvider, (prev, next) {
      // Concluso (l'utente ha toccato "Ancora" o è stato resettato) -> Home.
      if (prev is! RecognitionIdle &&
          next is RecognitionIdle &&
          Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });

    final l10n = AppLocalizations.of(context);
    final stato = ref.watch(recognitionControllerProvider);
    final titolo =
        stato is RecognitionResult ? l10n.results : l10n.tabRecognize;
    return Scaffold(
      appBar: AppBar(title: Text(titolo)),
      body: const RecognitionScreen(),
    );
  }
}
