import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/piattaforma_info.dart';
import '../../../core/versione_locale.dart';
import '../../../data/repositories/feedback_repository.dart';

/// Tipi di feedback ammessi (allineati al check della tabella `feedback`).
enum TipoFeedback { consiglio, bug, altro }

/// Orchestratore invio feedback. Allega SEMPRE versione app + piattaforma
/// (utile per i bug, innocuo per gli altri); l'utente non deve inserirle.
class FeedbackController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> invia({
    required TipoFeedback tipo,
    required String messaggio,
  }) async {
    state = const AsyncLoading();
    final res = await AsyncValue.guard(() async {
      await ref.read(feedbackRepositoryProvider).invia(
            tipo: tipo.name,
            messaggio: messaggio.trim(),
            versioneApp: '$kVersioneApp+$kBuildApp',
            piattaforma: piattaformaCorrente(),
          );
    });
    state = res;
    return !res.hasError;
  }
}

final feedbackControllerProvider =
    AutoDisposeAsyncNotifierProvider<FeedbackController, void>(
  FeedbackController.new,
);
