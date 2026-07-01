import 'bird_recognizer.dart';

/// Fallback per piattaforme non supportate (né dart:io né js_interop).
BirdRecognizer createRecognizer() => throw UnsupportedError(
      'Nessun BirdRecognizer disponibile per questa piattaforma.',
    );
