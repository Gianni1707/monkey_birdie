import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Pre-elaborazione immagine **pura** (nessuna dipendenza da piattaforma):
/// decodifica (JPEG/PNG/…), ridimensiona a 224x224 e produce RGB uint8 [224*224*3].
/// È l'equivalente di `AudioDsp` per le foto: condivisa dall'impl nativa (tflite)
/// e dai test. Sul web il preprocessing è fatto in JS (canvas nello shim).
///
/// Il modello AIY Birds V1 vuole input **uint8 [0,255]** 224x224x3, senza
/// normalizzazione. Il resize usa l'interpolazione ad **AREA** (media dei pixel):
/// evita l'aliasing sui downscale forti (foto da fotocamera), analogo al downscale
/// progressivo del percorso web.
class ImageDsp {
  ImageDsp._();

  static const int inputSize = 224;

  static Uint8List decodeAndPreprocess(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('Immagine non decodificabile.');
    }
    final resized = img.copyResize(
      decoded,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.average,
    );
    return pixelsToRgbBytes(resized);
  }

  /// Estrae i canali RGB (scarta l'alpha) in un buffer uint8 HWC [224*224*3].
  static Uint8List pixelsToRgbBytes(img.Image image) {
    final out = Uint8List(inputSize * inputSize * 3);
    var j = 0;
    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final p = image.getPixel(x, y);
        out[j++] = p.r.toInt();
        out[j++] = p.g.toInt();
        out[j++] = p.b.toInt();
      }
    }
    return out;
  }
}
