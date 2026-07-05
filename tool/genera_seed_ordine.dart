// Genera il seed degli ORDINI tassonomici (UT04) da GBIF (species/match).
// Per ogni specie del catalogo interroga
//   https://api.gbif.org/v1/species/match?name=<nome_scientifico>
// e legge il campo "order" (latino, es. "Passeriformes"). Riempie `specie.ordine`
// SOLO dove è NULL (il seed ha `and ordine is null`). L'italianizzazione è a
// display (lib/shared/ordine_tassonomico.dart): qui salviamo il latino grezzo.
//
// In cache si memorizzano SOLO gli esiti definitivi: ordine trovato oppure
// non-trovato reale (match senza order / matchType NONE, `nf:true`). I fallimenti
// transitori (timeout/errore rete) NON si cachano -> ritentati al run successivo.
//
// Uso (dalla root):
//   export PATH="/home/gianni/Progetti/flutter/bin:$PATH"
//   dart run tool/genera_seed_ordine.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _ua = 'MonkeyBird/1.0 (birdwatching app, non-commercial; '
    'contact: aletheia.di@uniba.it)';
const _concorrenza = 6; // GBIF regge bene i burst; niente 429 osservati
const _cachePath = 'build/ordine_cache_v2.json'; // v2: guardia class==Aves
const _catalogo = 'supabase/seed/specie_full_seed.sql';
const _seed = 'supabase/seed/specie_ordine_seed.sql';

/// Esito definitivo per una specie. `nf` = non-trovato reale (cacheable).
typedef Ord = ({String? ordine, bool nf});

Future<void> main() async {
  final sci = (RegExp(r"\('[^']*', '([^']+)'")
      .allMatches(File(_catalogo).readAsStringSync())
      .map((m) => m.group(1)!)
      .toSet()
      .toList()
    ..sort());
  stdout.writeln('Catalogo: ${sci.length} specie');

  final dati = await _carica(sci);

  var con = 0, nf = 0, irrisolti = 0;
  final perOrdine = <String, int>{};
  for (final s in sci) {
    final d = dati[s];
    if (d == null || (d.ordine == null && !d.nf)) {
      irrisolti++;
    } else if (d.ordine == null) {
      nf++;
    } else {
      con++;
      perOrdine[d.ordine!] = (perOrdine[d.ordine!] ?? 0) + 1;
    }
  }

  String esc(String s) => s.replaceAll("'", "''");
  final buf = StringBuffer()
    ..writeln('-- Seed ordine tassonomico specie (GBIF species/match) offline.')
    ..writeln('-- Riempie `specie.ordine` SOLO dove è NULL (non sovrascrive).')
    ..writeln('-- Latino grezzo; italianizzazione a display. Copertura: $con/'
        '${sci.length}.');
  for (final s in sci) {
    final d = dati[s];
    if (d?.ordine == null) continue;
    buf.writeln(
      "update specie set ordine = '${esc(d!.ordine!)}' "
      "where nome_scientifico = '${esc(s)}' and ordine is null;",
    );
  }
  File(_seed).writeAsStringSync(buf.toString());

  // Report ordini distinti (utile per verificare la copertura della mappa IT).
  final ordini = perOrdine.keys.toList()..sort();
  stdout
    ..writeln('\n===== COPERTURA ORDINE =====')
    ..writeln('Con ordine: $con/${sci.length} '
        '(${(100 * con / sci.length).toStringAsFixed(1)}%)')
    ..writeln('  non-trovati reali: $nf')
    ..writeln('  IRRISOLTI (timeout/errore, ritentabili al prossimo run): '
        '$irrisolti')
    ..writeln('\nOrdini distinti trovati: ${ordini.length}');
  for (final o in ordini) {
    stdout.writeln('  $o: ${perOrdine[o]}');
  }
  if (irrisolti > 0) {
    stdout.writeln('\n-> Rilancia il generatore per completare gli irrisolti.');
  }
  stdout.writeln('\nSeed scritto in $_seed');
}

Future<Map<String, Ord>> _carica(List<String> sci) async {
  final cacheFile = File(_cachePath);
  final cache = <String, Ord>{};
  if (cacheFile.existsSync()) {
    final raw = jsonDecode(cacheFile.readAsStringSync()) as Map<String, dynamic>;
    raw.forEach((k, v) {
      final m = v as Map<String, dynamic>;
      final ordine = m['o'] as String?;
      final nf = m['nf'] == true;
      if (ordine != null || nf) cache[k] = (ordine: ordine, nf: nf);
    });
    stdout.writeln('Cache: ${cache.length} esiti definitivi');
  }

  final daFare = sci.where((s) => !cache.containsKey(s)).toList();
  if (daFare.isEmpty) return cache;
  stdout.writeln('Da (ri)scaricare: ${daFare.length} — pool $_concorrenza...');

  final client = http.Client();
  var fatti = 0, ko = 0;
  final coda = daFare.iterator;
  Future<void> worker() async {
    while (coda.moveNext()) {
      final s = coda.current;
      final d = await _match(client, s);
      if (d.ordine != null || d.nf) cache[s] = d;
      if (d.ordine == null && !d.nf) ko++;
      if (++fatti % 300 == 0) {
        stdout.writeln('  ...$fatti/${daFare.length} (falliti finora: $ko)');
        _salva(cacheFile, cache);
      }
    }
  }

  await Future.wait(List.generate(_concorrenza, (_) => worker()));
  client.close();
  _salva(cacheFile, cache);
  return cache;
}

void _salva(File f, Map<String, Ord> cache) {
  f.parent.createSync(recursive: true);
  final perCache = {
    for (final e in cache.entries)
      e.key: {'o': e.value.ordine, 'nf': e.value.nf},
  };
  f.writeAsStringSync(jsonEncode(perCache));
}

Future<Ord> _match(http.Client c, String nome) async {
  final uri = Uri.https('api.gbif.org', '/v1/species/match', {'name': nome});
  for (var t = 0; t < 5; t++) {
    try {
      final r = await c
          .get(uri, headers: const {'User-Agent': _ua})
          .timeout(const Duration(seconds: 15));
      if (r.statusCode == 200) {
        final d = jsonDecode(r.body) as Map<String, dynamic>;
        final classe = (d['class'] as String?)?.trim();
        final ordine = (d['order'] as String?)?.trim();
        // Solo uccelli: alcuni nomi scientifici del catalogo sono OMONIMI di
        // taxa non-aviari (rane, insetti, mammiferi) e GBIF li matcha lì. Se la
        // classe non è Aves, trattiamo come "senza ordine" (nf) -> niente badge.
        if (d['matchType'] == 'NONE' ||
            classe != 'Aves' ||
            ordine == null ||
            ordine.isEmpty) {
          return (ordine: null, nf: true); // non-trovato reale
        }
        return (ordine: ordine, nf: false);
      }
      if (r.statusCode == 429) {
        final ra = int.tryParse(r.headers['retry-after'] ?? '');
        await Future<void>.delayed(
          Duration(seconds: ra ?? (1 << t).clamp(1, 16)),
        );
        continue;
      }
    } catch (_) {
      // timeout/errore: ritenta
    }
    await Future<void>.delayed(Duration(milliseconds: 400 * (t + 1)));
  }
  return (ordine: null, nf: false); // fallito transitorio (non cachato)
}
