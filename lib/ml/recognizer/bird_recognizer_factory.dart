import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bird_recognizer.dart';
// Selezione dell'implementazione a compile-time:
//  - default: stub (piattaforma non supportata)
//  - dart:io          -> nativo Android (tflite_flutter)
//  - dart:js_interop  -> web/PWA (tfjs-tflite, stub durante lo spike)
import 'bird_recognizer_stub.dart'
    if (dart.library.io) 'bird_recognizer_io.dart'
    if (dart.library.js_interop) 'bird_recognizer_web.dart';

export 'bird_recognizer.dart' show BirdRecognizer;

/// Recognizer condiviso dell'app. Il web non importa tflite_flutter e Android
/// non tira il JS interop, grazie al conditional import qui sopra.
final birdRecognizerProvider = Provider<BirdRecognizer>((ref) {
  final recognizer = createRecognizer();
  ref.onDispose(recognizer.dispose);
  return recognizer;
});
