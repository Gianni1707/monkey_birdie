import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bird_image_recognizer.dart';
// Selezione dell'implementazione a compile-time (come per l'audio):
//  - default: stub (piattaforma non supportata)
//  - dart:io          -> nativo Android (tflite_flutter)
//  - dart:js_interop  -> web/PWA (tfjs-tflite)
import 'bird_image_recognizer_stub.dart'
    if (dart.library.io) 'bird_image_recognizer_io.dart'
    if (dart.library.js_interop) 'bird_image_recognizer_web.dart';

export 'bird_image_recognizer.dart' show BirdImageRecognizer;

/// Recognizer immagini condiviso dell'app. Il web non importa tflite_flutter e
/// Android non tira il JS interop, grazie al conditional import qui sopra.
final birdImageRecognizerProvider = Provider<BirdImageRecognizer>((ref) {
  final recognizer = createImageRecognizer();
  ref.onDispose(recognizer.dispose);
  return recognizer;
});
