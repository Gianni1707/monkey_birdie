import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../audio/audio_dsp.dart';
import '../birdnet/birdnet_labels.dart';
import 'bird_recognizer.dart';

BirdRecognizer createRecognizer() => TfliteBirdRecognizer();

/// Implementazione nativa (Android): inferenza con tflite_flutter.
///
/// Contratto modello: input `[1, AudioDsp.windowSamples]` float32 (48kHz grezzo),
/// output `[1, N]` logit con N = numero di label. Sigmoid sui logit.
class TfliteBirdRecognizer implements BirdRecognizer {
  static const _modelAsset = 'assets/models/birdnet.tflite';
  static const _labelsAsset = 'assets/labels/birdnet_labels.txt';

  Interpreter? _interpreter;
  List<BirdNetLabel> _labels = const [];

  @override
  Future<void> load() async {
    if (_interpreter != null) return;
    _interpreter = await Interpreter.fromAsset(_modelAsset);
    _labels = BirdNetLabels.parse(await rootBundle.loadString(_labelsAsset));
  }

  @override
  Future<List<BirdNetPrediction>> analyze(
    String recordedUri, {
    int topK = 3,
  }) async {
    final bytes = await File(recordedUri).readAsBytes();
    final samples = AudioDsp.decodeWavPcm16(bytes);
    return analyzeSamples(samples, topK: topK);
  }

  @override
  Future<List<BirdNetPrediction>> analyzeSamples(
    Float32List samples48kMono, {
    int topK = 3,
  }) async {
    await load();
    final interpreter = _interpreter!;
    final finestra = AudioDsp.finestraPrincipale(samples48kMono);

    final n = _labels.length;
    final input = [finestra]; // [1, windowSamples]
    final output = [List<double>.filled(n, 0)]; // [1, n]
    interpreter.run(input, output);

    final logits = output.first;
    final preds = <BirdNetPrediction>[];
    for (var i = 0; i < n && i < logits.length; i++) {
      preds.add(
        BirdNetPrediction(
          nomeScientifico: _labels[i].sci,
          nomeComune: _labels[i].common,
          confidenza: _sigmoid(logits[i]),
          label: _labels[i].raw,
        ),
      );
    }
    preds.sort((a, b) => b.confidenza.compareTo(a.confidenza));
    return preds.take(topK).toList();
  }

  double _sigmoid(double x) => 1 / (1 + math.exp(-x));

  @override
  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
  }
}
