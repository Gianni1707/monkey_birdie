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
  const RecognitionAnalyzing();
}

class RecognitionResult extends RecognitionState {
  const RecognitionResult({required this.candidati, this.posizione});
  final List<CandidatoSpecie> candidati;
  final LatLng? posizione; // null = GPS non disponibile (si salva comunque)
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
