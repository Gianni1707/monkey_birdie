import 'dart:typed_data';

/// DSP audio **puro** (nessuna dipendenza da piattaforma): decodifica WAV PCM16,
/// resampling lineare e selezione della finestra a energia massima.
/// Condiviso tra l'impl nativa (tflite) e quella web (tfjs-tflite).
class AudioDsp {
  AudioDsp._();

  static const int sampleRate = 48000;
  static const int windowSamples = 144000; // 3 secondi @ 48kHz

  /// Decodifica un WAV PCM16 (mono/stereo) in campioni float [-1,1] mono a 48kHz.
  /// Opera su byte grezzi: nessun accesso al filesystem (riusabile ovunque).
  static Float32List decodeWavPcm16(Uint8List bytes) {
    if (bytes.length < 44 ||
        String.fromCharCodes(bytes.sublist(0, 4)) != 'RIFF' ||
        String.fromCharCodes(bytes.sublist(8, 12)) != 'WAVE') {
      throw const FormatException('File WAV non valido.');
    }
    final bd = ByteData.sublistView(bytes);

    var channels = 1;
    var rate = sampleRate;
    var bits = 16;
    var dataOffset = -1;
    var dataLen = 0;

    var p = 12;
    while (p + 8 <= bytes.length) {
      final id = String.fromCharCodes(bytes.sublist(p, p + 4));
      final size = bd.getUint32(p + 4, Endian.little);
      final body = p + 8;
      if (id == 'fmt ') {
        channels = bd.getUint16(body + 2, Endian.little);
        rate = bd.getUint32(body + 4, Endian.little);
        bits = bd.getUint16(body + 14, Endian.little);
      } else if (id == 'data') {
        dataOffset = body;
        dataLen = size;
      }
      p = body + size + (size.isOdd ? 1 : 0);
    }

    if (dataOffset < 0) throw const FormatException('Chunk "data" assente.');
    if (bits != 16) throw const FormatException('Supportato solo PCM 16-bit.');

    final frames = dataLen ~/ (2 * channels);
    final mono = Float32List(frames);
    var s = dataOffset;
    for (var i = 0; i < frames; i++) {
      var acc = 0.0;
      for (var c = 0; c < channels; c++) {
        acc += bd.getInt16(s, Endian.little) / 32768.0;
        s += 2;
      }
      mono[i] = acc / channels;
    }

    return rate == sampleRate ? mono : resampleLineare(mono, rate, sampleRate);
  }

  /// Resampling lineare a [to] Hz.
  static Float32List resampleLineare(Float32List input, int from, int to) {
    if (from == to || input.isEmpty) return input;
    final ratio = to / from;
    final outLen = (input.length * ratio).round();
    final out = Float32List(outLen);
    final maxIdx = input.length - 1;
    for (var i = 0; i < outLen; i++) {
      final srcPos = i / ratio;
      final i0 = srcPos.floor();
      final i1 = (i0 + 1) > maxIdx ? maxIdx : i0 + 1;
      final frac = srcPos - i0;
      out[i] = input[i0] * (1 - frac) + input[i1] * frac;
    }
    return out;
  }

  /// Estrae la finestra da [windowSamples] (3s) con energia massima.
  /// Se l'audio e' piu' corto, fa padding con zeri.
  static Float32List finestraPrincipale(Float32List samples) {
    if (samples.length <= windowSamples) {
      final out = Float32List(windowSamples);
      out.setRange(0, samples.length, samples);
      return out;
    }
    var bestStart = 0;
    var bestEnergy = -1.0;
    const hop = windowSamples ~/ 2; // salto di 1.5s
    for (var start = 0; start + windowSamples <= samples.length; start += hop) {
      var e = 0.0;
      for (var i = start; i < start + windowSamples; i += 16) {
        final v = samples[i];
        e += v * v;
      }
      if (e > bestEnergy) {
        bestEnergy = e;
        bestStart = start;
      }
    }
    return Float32List.sublistView(samples, bestStart, bestStart + windowSamples);
  }
}
