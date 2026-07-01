import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import '../birdnet/birdnet_labels.dart';
import 'bird_recognizer.dart';

// Funzioni globali esposte dallo shim web/birdnet/birdnet_tfjs.js
@JS('birdnetLoad')
external JSPromise<JSAny?> _jsBirdnetLoad();

@JS('birdnetAnalyzeUrl')
external JSPromise<JSFloat32Array> _jsBirdnetAnalyzeUrl(JSString url);

BirdRecognizer createRecognizer() => TfjsBirdRecognizer();

/// Implementazione web/PWA: BirdNET LayersModel eseguito con TF.js.
/// Il mel-spectrogram (FFT) è calcolato in JS dal custom layer; qui ci limitiamo
/// a invocare lo shim e a mappare gli score sulle label.
class TfjsBirdRecognizer implements BirdRecognizer {
  static const _labelsAsset = 'assets/labels/birdnet_labels.txt';

  List<BirdNetLabel> _labels = const [];
  bool _loaded = false;

  @override
  Future<void> load() async {
    if (_loaded) return;
    await _jsBirdnetLoad().toDart;
    _labels = BirdNetLabels.parse(await rootBundle.loadString(_labelsAsset));
    _loaded = true;
  }

  @override
  Future<List<BirdNetPrediction>> analyze(
    String recordedUri, {
    int topK = 3,
  }) async {
    await load();
    final scores = (await _jsBirdnetAnalyzeUrl(recordedUri.toJS).toDart).toDart;
    return _mapTopK(scores, topK);
  }

  @override
  Future<List<BirdNetPrediction>> analyzeSamples(
    Float32List samples48kMono, {
    int topK = 3,
  }) {
    // Sul web il preprocessing audio è gestito in JS (Web Audio): usa analyze(url).
    throw UnimplementedError(
      'analyzeSamples non disponibile sul web; usa analyze(url).',
    );
  }

  List<BirdNetPrediction> _mapTopK(Float32List scores, int k) {
    final idx = List<int>.generate(scores.length, (i) => i)
      ..sort((a, b) => scores[b].compareTo(scores[a]));
    final out = <BirdNetPrediction>[];
    for (final i in idx.take(k)) {
      final lab = i < _labels.length
          ? _labels[i]
          : (sci: '', common: '(fuori label)', raw: '');
      out.add(
        BirdNetPrediction(
          nomeScientifico: lab.sci,
          nomeComune: lab.common,
          confidenza: scores[i],
          label: lab.raw,
        ),
      );
    }
    return out;
  }

  @override
  Future<void> dispose() async {}
}
