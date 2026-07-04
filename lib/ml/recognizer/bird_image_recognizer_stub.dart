import 'bird_image_recognizer.dart';

/// Fallback per piattaforme non supportate (né dart:io né js_interop).
BirdImageRecognizer createImageRecognizer() => throw UnsupportedError(
      'Nessun BirdImageRecognizer disponibile per questa piattaforma.',
    );
