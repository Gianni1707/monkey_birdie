import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../image/aiy_birds_labels.dart';
import '../image/image_dsp.dart';
import 'bird_image_recognizer.dart';

BirdImageRecognizer createImageRecognizer() => TfliteImageRecognizer();

/// Implementazione nativa (Android): AIY Birds V1 via tflite_flutter.
///
/// Contratto modello: input `[1,224,224,3]` **uint8** (RGB 0..255, nessuna
/// normalizzazione), output `[1,965]` **uint8** quantizzato (score 0..255,
/// score/255 ≈ probabilità). Il preprocessing è in [ImageDsp].
class TfliteImageRecognizer implements BirdImageRecognizer {
  static const _modelAsset = 'assets/models/birds_V1.tflite';
  static const _labelsAsset = 'assets/labels/aiy_birds_labels.csv';

  Interpreter? _interpreter;
  List<String> _labels = const [];

  @override
  Future<void> load() async {
    if (_interpreter != null) return;
    _interpreter = await Interpreter.fromAsset(_modelAsset);
    _labels = AiyBirdsLabels.parse(await rootBundle.loadString(_labelsAsset));
  }

  @override
  Future<List<BirdNetPrediction>> analyze(String imageUri, {int topK = 3}) async {
    final bytes = await File(imageUri).readAsBytes();
    return analyzeBytes(bytes, topK: topK);
  }

  @override
  Future<List<BirdNetPrediction>> analyzeBytes(
    Uint8List bytes, {
    int topK = 3,
  }) async {
    await load();
    final interpreter = _interpreter!;
    final rgb = ImageDsp.decodeAndPreprocess(bytes); // 224*224*3 uint8

    // input [1,224,224,3] uint8; output [1,965] uint8 quantizzato.
    final input = rgb.reshape([1, ImageDsp.inputSize, ImageDsp.inputSize, 3]);
    final n = _labels.length;
    final output = [List<int>.filled(n, 0)];
    interpreter.run(input, output);

    return mappaScoreTopK(output.first, _labels, topK);
  }

  @override
  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
  }
}
