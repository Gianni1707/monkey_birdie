// Genera `supabase/seed/specie_image_label_seed.sql` dalla labelmap del modello
// immagine AIY Birds V1 (`assets/labels/aiy_birds_labels.csv`, righe "id,name").
// Le label AIY sono nomi scientifici -> image_label = nome_scientifico.
// Analogo a genera_seed_specie.dart. Uso:
//   dart run tool/genera_seed_image_label.dart
import 'dart:convert';
import 'dart:io';

void main() {
  final csv = File('assets/labels/aiy_birds_labels.csv').readAsStringSync();
  final nomi = <String>[];
  for (final riga in const LineSplitter().convert(csv)) {
    final l = riga.trim();
    if (l.isEmpty || l.startsWith('id,')) continue;
    final i = l.indexOf(',');
    if (i <= 0) continue;
    final nome = l.substring(i + 1).trim();
    if (nome.isEmpty || nome == 'background') continue; // salta la classe background
    nomi.add(nome.replaceAll("'", "''"));
  }

  final valori = nomi.map((n) => "  ('$n')").join(',\n');
  final sql = '''
-- =====================================================================
--  specie_image_label_seed.sql  —  SEED ADDITIVO (idempotente)
--
--  Popola `specie.image_label` (aggiunta da 0004) con il nome scientifico per le
--  ${nomi.length} specie riconoscibili dal modello immagine AIY Birds V1. Generato da
--  assets/labels/aiy_birds_labels.csv (tool/genera_seed_image_label.dart).
--  Eseguire dopo 0004_specie_image_label.sql.
-- =====================================================================

update specie s set image_label = v.sci
from (values
$valori
) as v(sci)
where s.nome_scientifico = v.sci
  and (s.image_label is null or s.image_label <> v.sci);
''';

  File('supabase/seed/specie_image_label_seed.sql').writeAsStringSync(sql);
  stdout.writeln('Seed image_label generato: ${nomi.length} specie.');
}
