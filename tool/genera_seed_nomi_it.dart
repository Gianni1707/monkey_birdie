// Generatore offline del seed dei NOMI COMUNI ITALIANI (0010) per il catalogo
// `specie`. Fonte: GBIF vernacularNames (language=ita), riusando il match sul
// nome scientifico. Regola:
//  (1) OVERRIDE curato a mano (comuni italiane/europee) con PRECEDENZA;
//  (2) altrimenti VOTO DI MAGGIORANZA tra i dataset GBIF; scarta solo il
//      pareggio vero al vertice (ambiguo/rischioso) -> null -> fallback inglese.
// I nomi scelti passano da una normalizzazione maiuscole "sicura".
//
// Uso (dalla root del progetto):
//   export PATH="/home/gianni/Progetti/flutter/bin:$PATH"
//   dart run tool/genera_seed_nomi_it.dart
//
// Legge : supabase/seed/specie_full_seed.sql  (lista nomi scientifici)
// Cache : build/nomi_it_cache.json  (dati GBIF grezzi; ri-run istantanei)
// Scrive: supabase/seed/specie_nome_comune_it_seed.sql  (UPDATE idempotente)
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _ua = 'MonkeyBird/1.0 (birdwatching; non-commercial)';
const _concorrenza = 8;
const _cachePath = 'build/nomi_it_cache.json';

/// OVERRIDE curato a mano: SOLO specie comuni in Italia/Europa che GBIF lascia
/// ambigue (pareggio) o rende con nome incerto. Ha PRECEDENZA sul voto GBIF.
/// NON contiene esotici (quelli ambigui restano in inglese). Nomi verificati.
const _override = <String, String>{
  // Il caso capostipite: GBIF dà "Cinciarella" e "Cinciallegra" 1-1 (uno errato).
  'Cyanistes caeruleus': 'Cinciarella',
  'Falco peregrinus': 'Falco pellegrino',
  // Cince e affini
  'Parus major': 'Cinciallegra',
  'Periparus ater': 'Cincia mora',
  'Poecile palustris': 'Cincia bigia',
  'Poecile montanus': 'Cincia alpestre',
  'Lophophanes cristatus': 'Cincia dal ciuffo',
  'Aegithalos caudatus': 'Codibugnolo',
  // Turdidi e affini
  'Turdus merula': 'Merlo',
  'Turdus philomelos': 'Tordo bottaccio',
  'Turdus viscivorus': 'Tordela',
  'Turdus pilaris': 'Cesena',
  'Turdus iliacus': 'Tordo sassello',
  'Erithacus rubecula': 'Pettirosso',
  'Luscinia megarhynchos': 'Usignolo',
  'Phoenicurus phoenicurus': 'Codirosso comune',
  'Phoenicurus ochruros': 'Codirosso spazzacamino',
  'Saxicola rubicola': 'Saltimpalo',
  'Troglodytes troglodytes': 'Scricciolo',
  'Prunella modularis': 'Passera scopaiola',
  // Silvidi / luì / regoli
  'Sylvia atricapilla': 'Capinera',
  'Curruca communis': 'Sterpazzola',
  'Sylvia communis': 'Sterpazzola',
  'Curruca melanocephala': 'Occhiocotto',
  'Sylvia melanocephala': 'Occhiocotto',
  'Phylloscopus collybita': 'Luì piccolo',
  'Phylloscopus trochilus': 'Luì grosso',
  'Phylloscopus sibilatrix': 'Luì verde',
  'Regulus regulus': 'Regolo',
  'Regulus ignicapilla': 'Fiorrancino',
  'Cisticola juncidis': 'Beccamoschino',
  'Cettia cetti': 'Usignolo di fiume',
  'Muscicapa striata': 'Pigliamosche',
  'Ficedula hypoleuca': 'Balia nera',
  // Rampichini / picchio muratore
  'Sitta europaea': 'Picchio muratore',
  'Certhia brachydactyla': 'Rampichino comune',
  'Certhia familiaris': 'Rampichino alpestre',
  // Corvidi / averle / rigogolo
  'Oriolus oriolus': 'Rigogolo',
  'Lanius collurio': 'Averla piccola',
  'Lanius senator': 'Averla capirossa',
  'Garrulus glandarius': 'Ghiandaia',
  'Pica pica': 'Gazza',
  'Corvus corone': 'Cornacchia nera',
  'Corvus cornix': 'Cornacchia grigia',
  'Corvus monedula': 'Taccola',
  'Coloeus monedula': 'Taccola',
  'Corvus frugilegus': 'Corvo comune',
  'Corvus corax': 'Corvo imperiale',
  'Pyrrhocorax pyrrhocorax': 'Gracchio corallino',
  // Storni / passeri / fringillidi
  'Sturnus vulgaris': 'Storno',
  'Sturnus unicolor': 'Storno nero',
  'Passer domesticus': 'Passera europea',
  'Passer italiae': "Passera d'Italia",
  'Passer montanus': 'Passera mattugia',
  'Fringilla coelebs': 'Fringuello',
  'Fringilla montifringilla': 'Peppola',
  'Chloris chloris': 'Verdone',
  'Carduelis carduelis': 'Cardellino',
  'Spinus spinus': 'Lucherino',
  'Linaria cannabina': 'Fanello',
  'Serinus serinus': 'Verzellino',
  'Coccothraustes coccothraustes': 'Frosone',
  'Pyrrhula pyrrhula': 'Ciuffolotto',
  // Zigoli
  'Emberiza citrinella': 'Zigolo giallo',
  'Emberiza cirlus': 'Zigolo nero',
  'Emberiza hortulana': 'Ortolano',
  'Emberiza calandra': 'Strillozzo',
  'Miliaria calandra': 'Strillozzo',
  // Ballerine / pispole / allodole
  'Motacilla alba': 'Ballerina bianca',
  'Motacilla cinerea': 'Ballerina gialla',
  'Motacilla flava': 'Cutrettola',
  'Anthus pratensis': 'Pispola',
  'Anthus trivialis': 'Prispolone',
  'Anthus spinoletta': 'Spioncello',
  'Alauda arvensis': 'Allodola',
  'Galerida cristata': 'Cappellaccia',
  'Lullula arborea': 'Tottavilla',
  // Rondini / rondoni
  'Hirundo rustica': 'Rondine',
  'Delichon urbicum': 'Balestruccio',
  'Riparia riparia': 'Topino',
  'Ptyonoprogne rupestris': 'Rondine montana',
  'Apus apus': 'Rondone comune',
  'Apus pallidus': 'Rondone pallido',
  'Tachymarptis melba': 'Rondone maggiore',
  // Altri non-passeriformi comuni
  'Upupa epops': 'Upupa',
  'Merops apiaster': 'Gruccione',
  'Coracias garrulus': 'Ghiandaia marina',
  'Alcedo atthis': 'Martin pescatore',
  'Cuculus canorus': 'Cuculo',
  'Jynx torquilla': 'Torcicollo',
  'Picus viridis': 'Picchio verde',
  'Dryocopus martius': 'Picchio nero',
  'Dendrocopos major': 'Picchio rosso maggiore',
  'Dryobates minor': 'Picchio rosso minore',
  'Dendrocopos minor': 'Picchio rosso minore',
  'Columba palumbus': 'Colombaccio',
  'Columba livia': 'Piccione selvatico',
  'Columba oenas': 'Colombella',
  'Streptopelia decaocto': 'Tortora dal collare',
  'Streptopelia turtur': 'Tortora selvatica',
  // Rapaci comuni
  'Buteo buteo': 'Poiana',
  'Accipiter nisus': 'Sparviere',
  'Accipiter gentilis': 'Astore',
  'Milvus milvus': 'Nibbio reale',
  'Milvus migrans': 'Nibbio bruno',
  'Circus aeruginosus': 'Falco di palude',
  'Falco tinnunculus': 'Gheppio',
  'Falco subbuteo': 'Lodolaio',
  'Pernis apivorus': 'Falco pecchiaiolo',
  // Acquatici / aironi comuni
  'Ardea cinerea': 'Airone cenerino',
  'Ardea alba': 'Airone bianco maggiore',
  'Egretta garzetta': 'Garzetta',
  'Nycticorax nycticorax': 'Nitticora',
  'Ardeola ralloides': 'Sgarza ciuffetto',
  'Ciconia ciconia': 'Cicogna bianca',
  'Ciconia nigra': 'Cicogna nera',
  'Anas platyrhynchos': 'Germano reale',
  'Anas crecca': 'Alzavola',
  'Mareca penelope': 'Fischione',
  'Spatula querquedula': 'Marzaiola',
  'Aythya ferina': 'Moriglione',
  'Aythya fuligula': 'Moretta',
  'Fulica atra': 'Folaga',
  'Gallinula chloropus': "Gallinella d'acqua",
  'Rallus aquaticus': 'Porciglione',
  'Podiceps cristatus': 'Svasso maggiore',
  'Tachybaptus ruficollis': 'Tuffetto',
  'Phalacrocorax carbo': 'Cormorano',
  'Larus michahellis': 'Gabbiano reale',
  'Chroicocephalus ridibundus': 'Gabbiano comune',
  'Vanellus vanellus': 'Pavoncella',
  'Himantopus himantopus': "Cavaliere d'Italia",
  'Recurvirostra avosetta': 'Avocetta',
  'Gallinago gallinago': 'Beccaccino',
  'Scolopax rusticola': 'Beccaccia',
  'Actitis hypoleucos': 'Piro piro piccolo',
  'Tringa totanus': 'Pettegola',
  'Numenius arquata': 'Chiurlo maggiore',
};

Future<void> main() async {
  final input = File('supabase/seed/specie_full_seed.sql');
  if (!input.existsSync()) {
    stderr.writeln('Manca ${input.path} (esegui dalla root del progetto).');
    exit(1);
  }

  // Estrae i binomi (Genere specie): primo match "Xxx yyy" per riga. I nomi
  // comuni inglesi sono Title Case (2a parola maiuscola) -> non collidono.
  final re = RegExp(r'([A-Z][a-z]+ [a-z]{2,}(?: [a-z]{2,})?)');
  final sci = <String>{};
  for (final l in input.readAsLinesSync()) {
    if (!l.trimLeft().startsWith("('")) continue;
    final m = re.firstMatch(l);
    if (m != null) sci.add(m.group(1)!);
  }
  final specie = sci.toList()..sort();
  final inCatalogo = specie.toSet();
  stdout.writeln('Nomi scientifici trovati: ${specie.length}');

  // Dati GBIF grezzi (sci -> lista di (nome, preferred)), da cache o da rete.
  final grezzi = await _caricaGrezzi(specie);

  // Decisione GBIF (voto di maggioranza) per ogni specie.
  final gbif = <String, String>{};
  for (final s in specie) {
    final scelto = _scegli(grezzi[s] ?? const []);
    if (scelto != null) gbif[s] = scelto;
  }

  // Applica OVERRIDE con precedenza; normalizza tutto.
  final finale = <String, String>{};
  for (final s in specie) {
    final grezzo = _override[s] ?? gbif[s];
    if (grezzo != null) finale[s] = _normalizza(grezzo);
  }

  // Statistiche override.
  var ovInCat = 0, ovRecuperi = 0, ovSovrascritture = 0;
  final ovNonTrovati = <String>[];
  for (final e in _override.entries) {
    if (!inCatalogo.contains(e.key)) {
      ovNonTrovati.add(e.key);
      continue;
    }
    ovInCat++;
    final g = gbif[e.key];
    if (g == null) {
      ovRecuperi++;
    } else if (g.toLowerCase() != e.value.toLowerCase()) {
      ovSovrascritture++;
    }
  }

  // Scrive il seed (0010): UPDATE ... FROM (VALUES ...), idempotente.
  final chiavi = finale.keys.toList()..sort();
  final buf = StringBuffer()
    ..writeln('-- Seed nomi comuni italiani (UT nomi-IT).')
    ..writeln('-- GBIF (voto di maggioranza) + override curato comuni IT/EU.')
    ..writeln('-- Specie con nome IT: ${chiavi.length} su ${specie.length}.')
    ..writeln('-- Rieseguibile: aggiorna solo per nome_scientifico.')
    ..writeln('update specie as s set nome_comune_it = v.it')
    ..writeln('from (values');
  for (var i = 0; i < chiavi.length; i++) {
    final s = chiavi[i];
    final virgola = i == chiavi.length - 1 ? '' : ',';
    buf.writeln("  ('${_esc(s)}', '${_esc(finale[s]!)}')$virgola");
  }
  buf
    ..writeln(') as v(sci, it)')
    ..writeln('where s.nome_scientifico = v.sci;');
  File('supabase/seed/specie_nome_comune_it_seed.sql')
      .writeAsStringSync(buf.toString());

  // Report.
  final pct = (100 * finale.length / specie.length).toStringAsFixed(1);
  stdout
    ..writeln('\n===== COPERTURA FINALE =====')
    ..writeln('Totale specie:        ${specie.length}')
    ..writeln('Con nome IT:          ${finale.length}  ($pct%)')
    ..writeln('  di cui da GBIF:     ${gbif.length}')
    ..writeln('\n===== OVERRIDE CURATO =====')
    ..writeln('Voci override:        ${_override.length}')
    ..writeln('  presenti a catalogo:$ovInCat')
    ..writeln('  RECUPERI (GBIF era vuoto/ambiguo): $ovRecuperi')
    ..writeln('  sovrascritture GBIF:$ovSovrascritture')
    ..writeln('  non trovate a catalogo (ignorate): ${ovNonTrovati.length}');
  if (ovNonTrovati.isNotEmpty) {
    stdout.writeln('    ${ovNonTrovati.join(', ')}');
  }
  stdout.writeln('\n===== CAMPIONE COMUNI EUROPEE =====');
  const campione = [
    'Parus major',
    'Cyanistes caeruleus',
    'Erithacus rubecula',
    'Turdus merula',
    'Passer domesticus',
    'Falco peregrinus',
    'Sitta europaea',
    'Hirundo rustica',
    'Sturnus vulgaris',
    'Buteo buteo',
    'Apus apus',
    'Carduelis carduelis',
  ];
  for (final s in campione) {
    stdout.writeln('  ${s.padRight(24)} -> ${finale[s] ?? '— (inglese)'}');
  }

  stdout.writeln(
    '\nSeed scritto in supabase/seed/specie_nome_comune_it_seed.sql',
  );
}

/// Carica i dati grezzi GBIF da cache; se assente, li scarica e li salva.
Future<Map<String, List<({String nome, bool preferred})>>> _caricaGrezzi(
  List<String> specie,
) async {
  final cache = File(_cachePath);
  if (cache.existsSync()) {
    stdout.writeln('Uso cache GBIF: $_cachePath');
    final raw = jsonDecode(cache.readAsStringSync()) as Map<String, dynamic>;
    final out = <String, List<({String nome, bool preferred})>>{};
    raw.forEach((k, v) {
      out[k] = [
        for (final e in (v as List))
          (nome: e['n'] as String, preferred: e['p'] as bool),
      ];
    });
    return out;
  }

  stdout.writeln('Nessuna cache: scarico da GBIF (~qualche minuto)...');
  final client = http.Client();
  final out = <String, List<({String nome, bool preferred})>>{};
  var fatti = 0;
  final coda = specie.iterator;
  Future<void> worker() async {
    while (coda.moveNext()) {
      final s = coda.current;
      try {
        final key = await _taxonKey(client, s);
        out[s] = key == null ? const [] : await _vernacoliIta(client, key);
      } catch (_) {
        out[s] = const [];
      }
      if (++fatti % 250 == 0) {
        stdout.writeln('  ...$fatti/${specie.length}');
      }
    }
  }

  await Future.wait(List.generate(_concorrenza, (_) => worker()));
  client.close();

  cache.parent.createSync(recursive: true);
  final perCache = {
    for (final e in out.entries)
      e.key: [
        for (final v in e.value) {'n': v.nome, 'p': v.preferred},
      ],
  };
  cache.writeAsStringSync(jsonEncode(perCache));
  return out;
}

/// Sceglie il nome italiano "sicuro" (voto di maggioranza) o null. Un solo
/// `preferred` -> quello; altrimenti il più attestato; pareggio in cima -> null.
String? _scegli(List<({String nome, bool preferred})> ita) {
  if (ita.isEmpty) return null;
  String norm(String x) => x.trim().replaceAll(RegExp(r'\s+'), ' ');
  final conteggi = <String, int>{};
  final originale = <String, String>{};
  final preferiti = <String>{};
  for (final e in ita) {
    final n = norm(e.nome);
    if (n.isEmpty) continue;
    final k = n.toLowerCase();
    conteggi[k] = (conteggi[k] ?? 0) + 1;
    originale.putIfAbsent(k, () => n);
    if (e.preferred) preferiti.add(k);
  }
  if (conteggi.isEmpty) return null;
  if (preferiti.length == 1) return originale[preferiti.first];
  final ordinati = conteggi.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  if (ordinati.length == 1) return originale[ordinati.first.key];
  if (ordinati[0].value > ordinati[1].value) {
    return originale[ordinati.first.key];
  }
  return null; // pareggio vero -> ambiguo
}

/// Normalizzazione maiuscole "sicura": prima lettera del nome maiuscola, resto
/// minuscolo, MA preserva i nomi propri che seguono una preposizione
/// (es. "Hocco di Salvin", "Bulbul dell'Himalaya", "Cavaliere d'Italia").
String _normalizza(String nome) {
  const conn = {
    'di',
    'del',
    'dello',
    'della',
    'dei',
    'degli',
    'delle',
    'da',
    'de',
    'of',
    'van',
    'von',
    'la',
    'le',
    'lo',
    'al',
    'e',
  };
  bool attaccato(String w) {
    final l = w.toLowerCase();
    return l.startsWith("dell'") ||
        l.startsWith("all'") ||
        l.startsWith("d'") ||
        l.startsWith("de'") ||
        l.startsWith("l'");
  }

  final parti = nome.trim().split(RegExp(r'\s+'));
  final out = <String>[];
  for (var i = 0; i < parti.length; i++) {
    final w = parti[i];
    if (w.isEmpty) continue;
    if (i == 0) {
      out.add(w[0].toUpperCase() + w.substring(1).toLowerCase());
      continue;
    }
    final prev = parti[i - 1].toLowerCase();
    final proprio = attaccato(w) || conn.contains(prev) || attaccato(prev);
    out.add(proprio ? w : w.toLowerCase());
  }
  return out.join(' ');
}

Future<int?> _taxonKey(http.Client c, String nome) async {
  final uri = Uri.https('api.gbif.org', '/v1/species/match', {'name': nome});
  final r = await _get(c, uri);
  if (r == null) return null;
  final d = jsonDecode(r) as Map<String, dynamic>;
  if (d['matchType'] == 'NONE') return null;
  final k = d['usageKey'];
  return k is int ? k : null;
}

Future<List<({String nome, bool preferred})>> _vernacoliIta(
  http.Client c,
  int key,
) async {
  final uri = Uri.https(
    'api.gbif.org',
    '/v1/species/$key/vernacularNames',
    {'limit': '300'},
  );
  final r = await _get(c, uri);
  if (r == null) return const [];
  final d = jsonDecode(r) as Map<String, dynamic>;
  final res = (d['results'] as List?) ?? const [];
  return [
    for (final e in res)
      if ((e as Map)['language'] == 'ita' && e['vernacularName'] != null)
        (
          nome: e['vernacularName'] as String,
          preferred: e['preferred'] == true,
        ),
  ];
}

/// GET con retry (3 tentativi). Ritorna il body o null.
Future<String?> _get(http.Client c, Uri uri) async {
  for (var t = 0; t < 3; t++) {
    try {
      final richiesta = c.get(uri, headers: const {'User-Agent': _ua});
      final r = await richiesta.timeout(const Duration(seconds: 12));
      if (r.statusCode == 200) return r.body;
      if (r.statusCode == 404) return null;
    } catch (_) {
      // ritenta
    }
    await Future<void>.delayed(Duration(milliseconds: 200 * (t + 1)));
  }
  return null;
}

String _esc(String s) => s.replaceAll("'", "''");
