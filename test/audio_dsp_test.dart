import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:monkey_bird/ml/audio/audio_dsp.dart';

void main() {
  group('AudioDsp.finestraPrincipale', () {
    test('audio corto: pad a windowSamples', () {
      final out = AudioDsp.finestraPrincipale(Float32List(1000));
      expect(out.length, AudioDsp.windowSamples);
    });

    test('audio lungo: ritorna esattamente una finestra', () {
      final out =
          AudioDsp.finestraPrincipale(Float32List(AudioDsp.windowSamples * 3));
      expect(out.length, AudioDsp.windowSamples);
    });

    test('seleziona la finestra a energia maggiore', () {
      final samples = Float32List(AudioDsp.windowSamples * 2);
      // metto un picco di energia nella seconda metà
      for (var i = AudioDsp.windowSamples; i < samples.length; i++) {
        samples[i] = 0.9;
      }
      final out = AudioDsp.finestraPrincipale(samples);
      final energia = out.fold<double>(0, (a, v) => a + v * v);
      expect(energia, greaterThan(0));
    });
  });

  group('AudioDsp.resampleLineare', () {
    test('raddoppia i campioni da 24k a 48k', () {
      final input = Float32List.fromList(List.filled(24000, 0.5));
      final out = AudioDsp.resampleLineare(input, 24000, 48000);
      expect(out.length, 48000);
      expect(out.first, closeTo(0.5, 1e-6));
    });

    test('stesso sample rate: ritorna l’input', () {
      final input = Float32List.fromList([0.1, 0.2, 0.3]);
      expect(AudioDsp.resampleLineare(input, 48000, 48000), same(input));
    });
  });
}
