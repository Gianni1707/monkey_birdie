import 'package:flutter_test/flutter_test.dart';
import 'package:monkey_bird/ml/birdnet/birdnet_labels.dart';

void main() {
  group('BirdNetLabels.parse', () {
    test('estrae nome scientifico e comune dal formato "Sci_Common"', () {
      final labels = BirdNetLabels.parse('Turdus merula_Eurasian Blackbird\n');
      expect(labels, hasLength(1));
      expect(labels.first.sci, 'Turdus merula');
      expect(labels.first.common, 'Eurasian Blackbird');
    });

    test('ignora righe vuote', () {
      final labels = BirdNetLabels.parse('\n\nParus major_Great Tit\n\n');
      expect(labels, hasLength(1));
      expect(labels.first.sci, 'Parus major');
    });

    test('riga senza underscore: usa la riga come sci e common', () {
      final labels = BirdNetLabels.parse('Noise');
      expect(labels.first.sci, 'Noise');
      expect(labels.first.common, 'Noise');
    });
  });
}
