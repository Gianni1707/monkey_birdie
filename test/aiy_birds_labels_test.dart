import 'package:flutter_test/flutter_test.dart';
import 'package:monkey_bird/ml/image/aiy_birds_labels.dart';
import 'package:monkey_bird/ml/recognizer/bird_image_recognizer.dart';

void main() {
  group('AiyBirdsLabels.parse', () {
    test('indicizza per id (non per ordine di riga) e salta l\'header', () {
      // background (964) è la PRIMA riga, poi 0,1: l'indice deve seguire l'id.
      const csv = 'id,name\n964,background\n0,Turdus merula\n1,Parus major\n';
      final labels = AiyBirdsLabels.parse(csv);
      expect(labels.length, 965);
      expect(labels[0], 'Turdus merula');
      expect(labels[1], 'Parus major');
      expect(labels[AiyBirdsLabels.backgroundIndex], 'background');
    });
  });

  group('mappaScoreTopK', () {
    test('scarta background, ordina per score, confidenza = score/255', () {
      final labels = List<String>.generate(965, (i) => 'sp$i');
      final scores = List<num>.filled(965, 0);
      scores[10] = 200; // top-1
      scores[20] = 100; // top-2
      scores[AiyBirdsLabels.backgroundIndex] = 255; // background più alto: da scartare

      final preds = mappaScoreTopK(scores, labels, 3);

      expect(preds.length, 3);
      expect(preds[0].label, 'sp10');
      expect(preds[0].nomeScientifico, 'sp10');
      expect(preds[0].confidenza, closeTo(200 / 255, 1e-9));
      expect(preds[1].label, 'sp20');
      // la classe background non deve mai comparire tra i candidati
      expect(preds.every((p) => p.label != 'sp964'), isTrue);
    });
  });
}
