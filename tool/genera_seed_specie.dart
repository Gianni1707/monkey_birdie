// =====================================================================
//  genera_seed_specie.dart
//
//  Genera l'INSERT SQL del catalogo `specie` COMPLETO a partire dal file
//  di label di BirdNET (assets/labels/birdnet_labels.txt).
//
//  Formato atteso di ogni riga della label list di BirdNET:
//      Nome_scientifico_Nome comune
//  es. "Turdus merula_Eurasian Blackbird"
//
//  Uso:
//      dart run tool/genera_seed_specie.dart \
//          assets/labels/birdnet_labels.txt > supabase/seed/specie_full_seed.sql
//
//  Poi su Supabase: SQL Editor -> incolla specie_full_seed.sql -> Run.
//
//  Nota: rarita/livello_pericolo non sono nelle label BirdNET: vengono
//  messi ai default ('comune', 0) e si possono raffinare a mano dopo.
// =====================================================================

import 'dart:io';

String _esc(String s) => s.replaceAll("'", "''").trim();

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Uso: dart run tool/genera_seed_specie.dart <labels.txt>');
    exitCode = 64;
    return;
  }

  final file = File(args.first);
  if (!file.existsSync()) {
    stderr.writeln('File non trovato: ${args.first}');
    exitCode = 66;
    return;
  }

  final righe = file.readAsLinesSync();
  final values = <String>[];
  final visti = <String>{};

  for (final raw in righe) {
    final riga = raw.trim();
    if (riga.isEmpty) continue;

    // separatore tra nome scientifico e nome comune
    final i = riga.indexOf('_');
    if (i <= 0) continue;

    final nomeScientifico = _esc(riga.substring(0, i));
    final nomeComune = _esc(riga.substring(i + 1));
    if (nomeScientifico.isEmpty || nomeComune.isEmpty) continue;

    // salta etichette non-specie tipiche di BirdNET (rumore, umani, ...)
    final lower = nomeScientifico.toLowerCase();
    if (lower.startsWith('non-bird') ||
        lower.startsWith('human') ||
        lower.startsWith('noise') ||
        lower.startsWith('dog') ||
        lower.startsWith('engine')) {
      continue;
    }

    if (!visti.add(nomeScientifico)) continue; // dedup per nome scientifico

    final labelRaw = _esc(riga); // label completa "Sci_Common" per il mapping
    values.add(
      "  ('$nomeComune', '$nomeScientifico', 'comune', 0, '$labelRaw')",
    );
  }

  final out = StringBuffer()
    ..writeln('-- Seed catalogo specie generato da BirdNET labels')
    ..writeln('-- Specie totali: ${values.length}')
    ..writeln('insert into specie (nome_comune, nome_scientifico, rarita, livello_pericolo, birdnet_label) values')
    ..writeln(values.join(',\n'))
    ..writeln('on conflict (nome_scientifico) do nothing;');

  stdout.write(out.toString());
}
