import 'dart:typed_data';

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
    this.centroHint,
    this.posizioneAffidabile = false,
    this.fotoBytes,
    this.incerto = false,
  });
  final List<CandidatoSpecie> candidati;

  /// GPS letto all'analisi (null = non disponibile). Anche se presente, non e'
  /// "affidabile" per la galleria (foto scattata altrove): vedi
  /// [posizioneAffidabile].
  final LatLng? posizione;

  /// Dove centrare la mappa in modalita' manuale: posizione fresca se c'e',
  /// altrimenti l'ULTIMA posizione rilevata dell'utente (null solo se non se
  /// n'e' mai avuta una).
  final LatLng? centroHint;

  /// true = usare la posizione automatica come default (pin pre-posizionato,
  /// correggibile). false = ricaduta manuale obbligata (permesso negato, GPS in
  /// errore/timeout, oppure foto dalla galleria).
  final bool posizioneAffidabile;

  /// Byte della foto (percorso foto) da caricare su Storage al salvataggio.
  /// null per il percorso audio (nessuna foto da salvare).
  final Uint8List? fotoBytes;

  final bool incerto; // true = confidenza sotto soglia (foto): "non sono sicuro"
}

/// Passo di CONFERMA POSIZIONE prima dell'inserimento: la posizione e'
/// obbligatoria (niente placeholder). Se [affidabile] il pin parte gia' sulla
/// posizione automatica (correggibile), altrimenti l'utente deve posizionarlo.
class RecognitionConfermaPosizione extends RecognitionState {
  const RecognitionConfermaPosizione({
    required this.origine,
    required this.candidato,
  });

  /// Stato risultati da cui si proviene (per tornare indietro senza perdere il
  /// riconoscimento) e da cui si derivano foto/posizione/affidabilita'.
  final RecognitionResult origine;
  final CandidatoSpecie candidato;

  Uint8List? get fotoBytes => origine.fotoBytes;
  bool get affidabile => origine.posizioneAffidabile;

  /// Pin pre-posizionato: solo se la posizione automatica e' affidabile.
  LatLng? get pinIniziale => affidabile ? origine.posizione : null;

  /// Dove centrare la mappa (posizione fresca o ultima nota, anche in manuale).
  LatLng? get centroHint => origine.centroHint;
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
