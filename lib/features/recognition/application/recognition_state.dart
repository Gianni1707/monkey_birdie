import '../../../core/location/location_service.dart';
import '../../../data/models/specie.dart';
import '../../../ml/birdnet/birdnet_labels.dart';

/// Una predizione BirdNET abbinata alla specie di catalogo (null se assente).
class CandidatoSpecie {
  const CandidatoSpecie({required this.predizione, required this.specie});

  final BirdNetPrediction predizione;
  final Specie? specie; // null => non in catalogo => non salvabile

  bool get salvabile => specie != null;
}

/// Macchina a stati del flusso di riconoscimento.
sealed class RecognitionState {
  const RecognitionState();
}

class RecognitionIdle extends RecognitionState {
  const RecognitionIdle();
}

class RecognitionRecording extends RecognitionState {
  const RecognitionRecording();
}

class RecognitionAnalyzing extends RecognitionState {
  const RecognitionAnalyzing({this.messaggio});

  /// Messaggio mostrato durante l'analisi (null = default "Analisi del canto…").
  final String? messaggio;
}

class RecognitionResult extends RecognitionState {
  const RecognitionResult({
    required this.candidati,
    this.posizione,
    this.incerto = false,
  });
  final List<CandidatoSpecie> candidati;
  final LatLng? posizione; // null = GPS non disponibile (si salva comunque)
  final bool incerto; // true = confidenza sotto soglia (foto): "non sono sicuro"
}

class RecognitionSaving extends RecognitionState {
  const RecognitionSaving();
}

class RecognitionSaved extends RecognitionState {
  const RecognitionSaved(this.avvistamentoId);
  final String avvistamentoId;
}

class RecognitionError extends RecognitionState {
  const RecognitionError(this.message);
  final String message;
}
