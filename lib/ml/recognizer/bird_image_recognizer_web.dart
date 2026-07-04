import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import '../image/aiy_birds_labels.dart';
import 'bird_image_recognizer.dart';

// Funzioni globali esposte dallo shim web/birds_image/birds_image_tflite.js
@JS('birdImageLoad')
external JSPromise<JSAny?> _jsBirdImageLoad();

@JS('birdImageAnalyzeUrl')
external JSPromise<JSFloat32Array> _jsBirdImageAnalyzeUrl(JSString url);

BirdImageRecognizer createImageRecognizer() => TfjsImageRecognizer();

/// Implementazione web/PWA: AIY Birds V1 eseguito con **tfjs-tflite** (WASM).
/// Il preprocessing immagine (resize a 224 con downscale progressivo anti-alias)
/// è fatto in JS dallo shim; qui invochiamo lo shim e mappiamo gli score.
class TfjsImageRecognizer implements BirdImageRecognizer {
  static const _labelsAsset = 'assets/labels/aiy_birds_labels.csv';

  List<String> _labels = const [];
  bool _loaded = false;

  @override
  Future<void> load() async {
    if (_loaded) return;
    await _jsBirdImageLoad().toDart;
    _labels = AiyBirdsLabels.parse(await rootBundle.loadString(_labelsAsset));
    _loaded = true;
  }

  @override
  Future<List<BirdNetPrediction>> analyze(String imageUri, {int topK = 3}) async {
    await load();
    final scores = (await _jsBirdImageAnalyzeUrl(imageUri.toJS).toDart).toDart;
    return mappaScoreTopK(scores, _labels, topK);
  }

  @override
  Future<List<BirdNetPrediction>> analyzeBytes(Uint8List bytes, {int topK = 3}) {
    // Sul web il preprocessing è gestito in JS (canvas): usa analyze(url).
    throw UnimplementedError(
      'analyzeBytes non disponibile sul web; usa analyze(url).',
    );
  }

  @override
  Future<void> dispose() async {}
}
