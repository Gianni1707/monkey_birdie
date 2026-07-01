import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/error/failure.dart';
import '../../../core/location/location_service.dart';
import '../../../core/permissions/permission_service.dart';
import '../../../data/repositories/avvistamenti_repository.dart';
import '../../../data/repositories/specie_repository.dart';
import '../../../ml/recognizer/bird_recognizer_factory.dart';
import 'recognition_state.dart';

/// Orchestratore del flusso: registra -> analizza -> mappa su catalogo ->
/// prende GPS -> salva avvistamento.
class RecognitionController extends AutoDisposeNotifier<RecognitionState> {
  final AudioRecorder _recorder = AudioRecorder();

  /// Posizione richiesta all'atto del tocco (vedi avviaRegistrazione).
  Future<LatLng>? _posizioneFuture;

  @override
  RecognitionState build() {
    ref.onDispose(_recorder.dispose);
    return const RecognitionIdle();
  }

  Future<void> avviaRegistrazione() async {
    // iOS Safari nega il GPS se la richiesta non parte da un tocco utente:
    // la avviamo QUI, come primissima cosa nel gesto, e la useremo al
    // salvataggio. (Su nativo e' equivalente.)
    final posFuture = ref.read(locationServiceProvider).posizioneCorrente();
    _posizioneFuture = posFuture;
    posFuture.ignore(); // niente warning se non si arriva a fermaEAnalizza

    try {
      final ok = await ref.read(permissionServiceProvider).richiediMicrofono();
      if (!ok) {
        state = const RecognitionError('Permesso microfono negato.');
        return;
      }
      // Sul web non esiste una cartella temporanea: `record` produce un blob
      // e ignora il path. Su nativo usiamo la temp dir come prima.
      final path = kIsWeb
          ? 'recording.wav'
          : '${(await getTemporaryDirectory()).path}'
              '/rec_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 48000,
          numChannels: 1,
        ),
        path: path,
      );
      state = const RecognitionRecording();
    } catch (e) {
      state = RecognitionError(_msg(e));
    }
  }

  Future<void> fermaEAnalizza() async {
    try {
      final path = await _recorder.stop();
      if (path == null) {
        state = const RecognitionIdle();
        return;
      }
      state = const RecognitionAnalyzing();

      final preds =
          await ref.read(birdRecognizerProvider).analyze(path, topK: 3);

      // Il GPS non deve bloccare il flusso: su iOS Safari puo' non essere
      // disponibile. Se manca, si salva comunque (posizione = null).
      LatLng? posizione;
      try {
        posizione = await (_posizioneFuture ??
            ref.read(locationServiceProvider).posizioneCorrente());
      } catch (_) {
        posizione = null;
      } finally {
        _posizioneFuture = null;
      }

      final specieRepo = ref.read(specieRepositoryProvider);
      final candidati = <CandidatoSpecie>[];
      for (final p in preds) {
        final specie = await specieRepo.perPredizione(
          label: p.label,
          nomeScientifico: p.nomeScientifico,
        );
        candidati.add(CandidatoSpecie(predizione: p, specie: specie));
      }

      state = RecognitionResult(candidati: candidati, posizione: posizione);
    } catch (e) {
      state = RecognitionError(_msg(e));
    }
  }

  /// Salva l'avvistamento per il candidato scelto (deve avere specie in catalogo).
  Future<void> salva(CandidatoSpecie candidato) async {
    final corrente = state;
    if (corrente is! RecognitionResult) return;

    final specie = candidato.specie;
    if (specie == null) {
      state = const RecognitionError(
        'Specie non presente in catalogo: impossibile salvare.',
      );
      return;
    }

    state = const RecognitionSaving();
    try {
      // MVP: audio NON caricato su Storage (free tier 1GB) -> audioUrl omesso.
      final id = await ref.read(avvistamentiRepositoryProvider).inserisci(
            specieId: specie.id,
            lat: corrente.posizione?.lat ?? 0.0,
            lng: corrente.posizione?.lng ?? 0.0,
            confidenza: candidato.predizione.confidenza,
            condiviso: false,
          );
      state = RecognitionSaved(id);
    } catch (e) {
      state = RecognitionError(_msg(e));
    }
  }

  void reset() => state = const RecognitionIdle();

  String _msg(Object e) => e is Failure ? e.message : e.toString();
}

final recognitionControllerProvider =
    AutoDisposeNotifierProvider<RecognitionController, RecognitionState>(
  RecognitionController.new,
);
