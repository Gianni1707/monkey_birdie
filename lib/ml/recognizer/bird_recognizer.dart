import 'dart:typed_data';

import '../birdnet/birdnet_labels.dart';

export '../birdnet/birdnet_labels.dart' show BirdNetPrediction;

/// Interfaccia unica del riconoscimento uccelli. Due implementazioni scelte a
/// compile-time (conditional import in `bird_recognizer_factory.dart`):
///  - nativo Android: tflite_flutter
///  - web/PWA: tfjs-tflite (WASM) — cablato dopo lo spike di validazione
///
/// Tenere il resto dell'app dietro questa interfaccia: cambiare runtime web
/// non deve toccare controller/UI/dati.
abstract interface class BirdRecognizer {
  /// Carica modello + label (idempotente).
  Future<void> load();

  /// Analizza un audio registrato e ritorna le top-[topK] predizioni.
  /// [recordedUri] = path di file (nativo) o blob/object URL (web).
  Future<List<BirdNetPrediction>> analyze(String recordedUri, {int topK = 3});

  /// Analizza direttamente campioni float mono a 48kHz (usato da test/spike).
  Future<List<BirdNetPrediction>> analyzeSamples(
    Float32List samples48kMono, {
    int topK = 3,
  });

  Future<void> dispose();
}
