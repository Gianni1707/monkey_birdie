import 'dart:typed_data';

import '../birdnet/birdnet_labels.dart';
import '../image/aiy_birds_labels.dart';

export '../birdnet/birdnet_labels.dart' show BirdNetPrediction;

/// Soglia di confidenza (0..1) sotto la quale il riconoscimento da FOTO è
/// considerato **incerto** ("non sono sicuro"): foto sfocate/lontane sbagliano
/// di più. Sintonizzabile.
const double sogliaConfidenzaFoto = 0.30;

/// Interfaccia unica del riconoscimento uccelli **da foto**. Parallela e
/// indipendente da `BirdRecognizer` (canto): modello separato, runtime separato.
/// Impl scelte a compile-time (conditional import in
/// `bird_image_recognizer_factory.dart`):
///  - nativo Android: tflite_flutter
///  - web/PWA: tfjs-tflite (WASM)
///
/// Produce lo **stesso tipo di output** dell'audio ([BirdNetPrediction]) così da
/// confluire nel flusso condiviso candidati -> scelta -> salva. Per le foto:
/// `label` = `nomeScientifico` = nome scientifico AIY (chiave su `image_label`),
/// `confidenza` = score/255, `nomeComune` = fallback (il catalogo dà quello vero).
abstract interface class BirdImageRecognizer {
  /// Carica modello + label (idempotente).
  Future<void> load();

  /// Analizza una foto e ritorna le top-[topK] predizioni.
  /// [imageUri] = path di file (nativo) o blob/object URL (web).
  Future<List<BirdNetPrediction>> analyze(String imageUri, {int topK = 3});

  /// Analizza direttamente i byte di un'immagine (nativo/test; non usato sul web).
  Future<List<BirdNetPrediction>> analyzeBytes(Uint8List bytes, {int topK = 3});

  Future<void> dispose();
}

/// Mappa gli score grezzi (0..255) del modello sulle top-[k] predizioni,
/// scartando la classe "background". Condiviso tra impl nativa e web.
List<BirdNetPrediction> mappaScoreTopK(
  List<num> scores,
  List<String> labels,
  int k,
) {
  final idx = List<int>.generate(scores.length, (i) => i)
    ..sort((a, b) => scores[b].compareTo(scores[a]));
  final out = <BirdNetPrediction>[];
  for (final i in idx) {
    if (i == AiyBirdsLabels.backgroundIndex) continue; // non è una specie
    final sci = i < labels.length ? labels[i] : '';
    out.add(
      BirdNetPrediction(
        nomeScientifico: sci,
        nomeComune: sci,
        confidenza: scores[i] / 255.0,
        label: sci,
      ),
    );
    if (out.length >= k) break;
  }
  return out;
}
