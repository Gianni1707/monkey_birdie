import 'dart:convert';

/// Label del modello immagine **AIY Vision Classifier Birds V1**.
/// La labelmap CSV (`assets/labels/aiy_birds_labels.csv`) ha righe `id,name`:
/// l'`id` È l'indice del logit, `name` è un **nome scientifico** (usato come
/// `image_label` nel catalogo). L'indice [backgroundIndex] è la classe "background".
class AiyBirdsLabels {
  AiyBirdsLabels._();

  /// Indice della classe "background" (non è una specie): va scartata dai risultati.
  static const int backgroundIndex = 964;

  /// Parsa la labelmap CSV in una lista di nomi indicizzata per `id` del logit.
  static List<String> parse(String csv) {
    final byId = <int, String>{};
    var maxId = -1;
    for (final raw in const LineSplitter().convert(csv)) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('id,')) continue;
      final i = line.indexOf(',');
      if (i <= 0) continue;
      final id = int.tryParse(line.substring(0, i));
      if (id == null) continue;
      byId[id] = line.substring(i + 1).trim();
      if (id > maxId) maxId = id;
    }
    return List<String>.generate(maxId + 1, (i) => byId[i] ?? '');
  }
}
