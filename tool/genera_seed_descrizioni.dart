// Genera il seed delle DESCRIZIONI specie da Wikipedia (summary REST API).
// Per ogni specie del catalogo: riassunto in ITALIANO
//   https://it.wikipedia.org/api/rest_v1/page/summary/<nome_scientifico>?redirect=true
// leggendo "extract" + link (content_urls.desktop.page); fallback a en.wikipedia.
// Riempie `descrizione` SOLO dove è NULL (il seed ha `and descrizione is null`),
// + `descrizione_fonte` ("Wikipedia (it|en)") e `descrizione_url`.
//
// Rate-limit gentile: pool basso + gestione 429 (Retry-After/backoff). In cache
// si memorizzano SOLO gli esiti definitivi: trovato (extract) o non-trovato reale
// (404/disambigua in entrambe le lingue, `nf:true`). I fallimenti transitori
// (429/timeout) NON si cachano -> vengono ritentati al run successivo.
//
// Uso (dalla root):
//   export PATH="/home/gianni/Progetti/flutter/bin:$PATH"
//   dart run tool/genera_seed_descrizioni.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _ua =
    'MonkeyBird/1.0 (birdwatching app, non-commercial; contact: aletheia.di@uniba.it)';
const _concorrenza = 2; // gentile: Wikipedia throttla i burst
const _cachePath = 'build/descr_cache.json';
const _catalogo = 'supabase/seed/specie_full_seed.sql';
const _seed = 'supabase/seed/specie_descrizione_seed.sql';

/// Esito definitivo per una specie. `nf` = non-trovato reale (cacheable).
typedef Descr = ({String? extract, String? fonte, String? url, bool nf});

/// Esito di una singola chiamata summary.
enum _Esito { trovato, nonTrovato, fallito }

Future<void> main() async {
  final sci = (RegExp(r"\('[^']*', '([^']+)'")
      .allMatches(File(_catalogo).readAsStringSync())
      .map((m) => m.group(1)!)
      .toSet()
      .toList()
    ..sort());
  stdout.writeln('Catalogo: ${sci.length} specie');

  final dati = await _carica(sci);

  var it = 0, en = 0, nf = 0, irrisolti = 0;
  for (final s in sci) {
    final d = dati[s];
    if (d == null || (d.extract == null && !d.nf)) {
      irrisolti++;
    } else if (d.extract == null) {
      nf++;
    } else if (d.fonte == 'it') {
      it++;
    } else {
      en++;
    }
  }
  final cop = it + en;

  String esc(String s) => s.replaceAll("'", "''");
  final buf = StringBuffer()
    ..writeln('-- Seed descrizioni specie (Wikipedia) generato offline.')
    ..writeln('-- Riempie `descrizione` SOLO dove è NULL (non sovrascrive).')
    ..writeln('-- Copertura: $cop/${sci.length} (IT=$it, EN=$en).');
  for (final s in sci) {
    final d = dati[s];
    if (d?.extract == null) continue;
    final fonte = d!.fonte == 'it' ? 'Wikipedia (it)' : 'Wikipedia (en)';
    final url = d.url;
    buf.writeln(
      "update specie set descrizione = '${esc(d.extract!)}', "
      "descrizione_fonte = '$fonte', "
      "descrizione_url = ${url == null ? 'NULL' : "'${esc(url)}'"} "
      "where nome_scientifico = '${esc(s)}' and descrizione is null;",
    );
  }
  File(_seed).writeAsStringSync(buf.toString());

  stdout
    ..writeln('\n===== COPERTURA DESCRIZIONI =====')
    ..writeln('Con descrizione: $cop/${sci.length} '
        '(${(100 * cop / sci.length).toStringAsFixed(1)}%)')
    ..writeln('  IT: $it   EN (fallback): $en   non-trovate reali: $nf')
    ..writeln('  IRRISOLTE (throttle/timeout, ritentabili al prossimo run): '
        '$irrisolti');
  if (irrisolti > 0) {
    stdout.writeln('  -> Rilancia il generatore per completarle.');
  }
  stdout.writeln('\nSeed scritto in $_seed');
}

Future<Map<String, Descr>> _carica(List<String> sci) async {
  final cacheFile = File(_cachePath);
  final cache = <String, Descr>{};
  if (cacheFile.existsSync()) {
    final raw = jsonDecode(cacheFile.readAsStringSync()) as Map<String, dynamic>;
    raw.forEach((k, v) {
      final m = v as Map<String, dynamic>;
      final extract = m['e'] as String?;
      final nf = m['nf'] == true;
      // Tiene solo gli esiti DEFINITIVI (trovato o non-trovato reale). I vecchi
      // null senza `nf` (fallimenti transitori) vengono scartati e ritentati.
      if (extract != null || nf) {
        cache[k] = (
          extract: extract,
          fonte: m['f'] as String?,
          url: m['u'] as String?,
          nf: nf,
        );
      }
    });
    stdout.writeln('Cache: ${cache.length} esiti definitivi');
  }

  final daFare = sci.where((s) => !cache.containsKey(s)).toList();
  if (daFare.isEmpty) return cache;
  stdout.writeln('Da (ri)scaricare: ${daFare.length} — pool $_concorrenza, gentile...');

  final client = http.Client();
  var fatti = 0, ko = 0;
  final coda = daFare.iterator;
  Future<void> worker() async {
    while (coda.moveNext()) {
      final s = coda.current;
      final d = await _wiki(client, s);
      // Cacha solo esiti definitivi; i falliti restano fuori (ritentabili).
      if (d.extract != null || d.nf) cache[s] = d;
      if (d.extract == null && !d.nf) ko++;
      if (++fatti % 200 == 0) {
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

void _salva(File f, Map<String, Descr> cache) {
  f.parent.createSync(recursive: true);
  final perCache = {
    for (final e in cache.entries)
      e.key: {
        'e': e.value.extract,
        'f': e.value.fonte,
        'u': e.value.url,
        'nf': e.value.nf,
      },
  };
  f.writeAsStringSync(jsonEncode(perCache));
}

/// IT -> fallback EN. `nf:true` solo se ENTRAMBE dicono "non trovato" (definitivo).
Future<Descr> _wiki(http.Client c, String nome) async {
  var fallito = false;
  var nonTrovato = 0;
  for (final lang in const ['it', 'en']) {
    final (esito, extract, url) = await _summary(c, lang, nome);
    if (esito == _Esito.trovato) {
      return (extract: extract, fonte: lang, url: url, nf: false);
    }
    if (esito == _Esito.nonTrovato) {
      nonTrovato++;
    } else {
      fallito = true;
    }
  }
  // Non trovato definitivo solo se nessuna lingua ha fallito (throttle/timeout).
  final nf = !fallito && nonTrovato == 2;
  return (extract: null, fonte: null, url: null, nf: nf);
}

Future<(_Esito, String?, String?)> _summary(
  http.Client c,
  String lang,
  String nome,
) async {
  final uri = Uri.https(
    '$lang.wikipedia.org',
    '/api/rest_v1/page/summary/$nome',
    {'redirect': 'true'},
  );
  for (var t = 0; t < 6; t++) {
    try {
      final r = await c
          .get(uri, headers: const {'User-Agent': _ua})
          .timeout(const Duration(seconds: 15));
      if (r.statusCode == 404) return (_Esito.nonTrovato, null, null);
      if (r.statusCode == 200) {
        final d = jsonDecode(r.body) as Map<String, dynamic>;
        if (d['type'] == 'disambiguation') return (_Esito.nonTrovato, null, null);
        final extract = (d['extract'] as String?)?.trim();
        if (extract == null || extract.isEmpty) {
          return (_Esito.nonTrovato, null, null);
        }
        final url = ((d['content_urls'] as Map?)?['desktop']
            as Map?)?['page'] as String?;
        return (_Esito.trovato, extract, url);
      }
      if (r.statusCode == 429) {
        final ra = int.tryParse(r.headers['retry-after'] ?? '');
        final sec = ra ?? (1 << t).clamp(1, 16);
        await Future<void>.delayed(Duration(seconds: sec));
        continue;
      }
      // altri codici: piccola attesa e ritenta
    } catch (_) {
      // timeout/errore: ritenta
    }
    await Future<void>.delayed(Duration(milliseconds: 400 * (t + 1)));
  }
  return (_Esito.fallito, null, null);
}
