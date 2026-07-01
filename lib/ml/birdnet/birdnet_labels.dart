import 'dart:convert';

/// Una predizione di BirdNET mappata su nome scientifico + comune + label grezza.
class BirdNetPrediction {
  const BirdNetPrediction({
    required this.nomeScientifico,
    required this.nomeComune,
    required this.confidenza,
    required this.label,
  });

  final String nomeScientifico;
  final String nomeComune;
  final double confidenza; // 0..1
  final String label; // label BirdNET completa "Sci_Common" (mapping su catalogo)
}

/// Una label del modello: ('Turdus merula', 'Eurasian Blackbird', raw).
typedef BirdNetLabel = ({String sci, String common, String raw});

/// Parser della label list di BirdNET. Formato per riga:
///   Nome_scientifico_Nome comune
/// L'ORDINE delle righe deve combaciare con l'ordine di output del modello.
class BirdNetLabels {
  static List<BirdNetLabel> parse(String content) {
    final out = <BirdNetLabel>[];
    for (final raw in const LineSplitter().convert(content)) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      final i = line.indexOf('_');
      if (i <= 0) {
        out.add((sci: line, common: line, raw: line));
      } else {
        out.add((
          sci: line.substring(0, i).trim(),
          common: line.substring(i + 1).trim(),
          raw: line,
        ),);
      }
    }
    return out;
  }
}
