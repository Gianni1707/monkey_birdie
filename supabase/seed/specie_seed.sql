-- =====================================================================
--  specie_seed.sql  —  Seed STARTER del catalogo specie (Fase 1)
--
--  Perche' serve: avvistamenti.specie_id e' NOT NULL con FK su specie,
--  e gli utenti NON possono inserire specie (nessuna policy di insert).
--  Quindi una specie riconosciuta da BirdNET e' salvabile solo se esiste
--  qui. Il mapping avviene per `nome_scientifico` (chiave usata anche
--  nelle label di BirdNET, formato "Nome_scientifico_Nome comune").
--
--  Questo file copre ~40 specie comuni in Italia per avere subito un
--  flusso end-to-end. Per il catalogo COMPLETO allineato a BirdNET usa
--  tool/genera_seed_specie.dart (vedi README) che genera l'INSERT da
--  assets/labels/birdnet_labels.txt.
--
--  Idempotente: on conflict (nome_scientifico) do nothing.
-- =====================================================================

insert into specie (nome_comune, nome_scientifico, rarita, livello_pericolo, descrizione) values
  ('Merlo',                  'Turdus merula',          'comune',      0, 'Passeriforme nero col becco arancione, canto melodioso.'),
  ('Pettirosso',             'Erithacus rubecula',     'comune',      0, 'Piccolo, petto arancione, molto confidente.'),
  ('Cinciallegra',           'Parus major',            'comune',      0, 'Cincia col ventre giallo e cravatta nera.'),
  ('Cinciarella',            'Cyanistes caeruleus',    'comune',      0, 'Cincia con calotta blu e guance bianche.'),
  ('Passera europea',        'Passer domesticus',      'comune',      0, 'Passero urbano molto diffuso.'),
  ('Passera mattugia',       'Passer montanus',        'comune',      0, 'Simile alla domestica, con macchia nera sulla guancia.'),
  ('Fringuello',             'Fringilla coelebs',      'comune',      0, 'Fringillide dal canto ritmico e ripetitivo.'),
  ('Verdone',                'Chloris chloris',        'comune',      0, 'Fringillide verde-oliva, becco robusto.'),
  ('Cardellino',             'Carduelis carduelis',    'comune',      0, 'Faccia rossa e ali con barra gialla.'),
  ('Verzellino',             'Serinus serinus',        'comune',      0, 'Piccolo fringillide giallastro, canto tintinnante.'),
  ('Capinera',               'Sylvia atricapilla',     'comune',      0, 'Calotta nera (maschio) o castana (femmina).'),
  ('Usignolo',               'Luscinia megarhynchos',  'poco_comune', 0, 'Canoro notturno, bruno-rossiccio.'),
  ('Codirosso comune',       'Phoenicurus phoenicurus','poco_comune', 0, 'Coda rossa vibrante, migratore.'),
  ('Codirosso spazzacamino', 'Phoenicurus ochruros',   'comune',      0, 'Scuro, coda rossa, tipico dei centri abitati.'),
  ('Storno',                 'Sturnus vulgaris',       'comune',      0, 'Gregario, piumaggio iridescente macchiettato.'),
  ('Ballerina bianca',       'Motacilla alba',         'comune',      0, 'Coda lunga in continuo movimento, bianco-nera.'),
  ('Rondine',                'Hirundo rustica',        'comune',      0, 'Coda forcuta, gola rossa, migratrice.'),
  ('Balestruccio',           'Delichon urbicum',       'comune',      0, 'Groppone bianco, nidifica sotto i cornicioni.'),
  ('Rondone comune',         'Apus apus',              'comune',      0, 'Ali a falce, quasi sempre in volo.'),
  ('Colombaccio',            'Columba palumbus',       'comune',      0, 'Grosso colombo selvatico con macchie bianche sul collo.'),
  ('Tortora dal collare',    'Streptopelia decaocto',  'comune',      0, 'Collare nero sulla nuca, verso cadenzato.'),
  ('Cornacchia grigia',      'Corvus cornix',          'comune',      0, 'Corvide bicolore grigio e nero.'),
  ('Gazza',                  'Pica pica',              'comune',      0, 'Bianca e nera con coda lunga iridescente.'),
  ('Ghiandaia',              'Garrulus glandarius',    'comune',      0, 'Corvide colorato con specchio alare blu.'),
  ('Taccola',                'Coloeus monedula',       'comune',      0, 'Piccolo corvide con nuca grigia e occhio chiaro.'),
  ('Upupa',                  'Upupa epops',            'poco_comune', 0, 'Cresta erettile, volo a farfalla.'),
  ('Picchio rosso maggiore', 'Dendrocopos major',      'comune',      0, 'Bianco-nero con sottocoda rosso, tambureggia.'),
  ('Picchio verde',          'Picus viridis',          'poco_comune', 0, 'Verde con calotta rossa, risata sonora.'),
  ('Gheppio',                'Falco tinnunculus',      'comune',      1, 'Piccolo falco che fa lo "spirito santo" in volo.'),
  ('Poiana',                 'Buteo buteo',            'comune',      1, 'Rapace medio, volteggia in cerchio miagolando.'),
  ('Civetta',                'Athene noctua',          'poco_comune', 1, 'Piccolo rapace notturno diurno, sguardo fisso.'),
  ('Allocco',                'Strix aluco',            'poco_comune', 1, 'Rapace notturno, verso "hu-huuu".'),
  ('Barbagianni',            'Tyto alba',              'poco_comune', 1, 'Facciale a cuore, notturno, color crema.'),
  ('Gabbiano reale',         'Larus michahellis',      'comune',      1, 'Grande gabbiano a zampe gialle.'),
  ('Germano reale',          'Anas platyrhynchos',     'comune',      0, 'Anatra di superficie, maschio dalla testa verde.'),
  ('Airone cenerino',        'Ardea cinerea',          'comune',      0, 'Grande trampoliere grigio, collo a S.'),
  ('Folaga',                 'Fulica atra',            'comune',      0, 'Nera con scudo frontale bianco, acquatica.'),
  ('Martin pescatore',       'Alcedo atthis',          'poco_comune', 0, 'Azzurro-arancio, si tuffa per i pesci.'),
  ('Cigno reale',            'Cygnus olor',            'poco_comune', 1, 'Grande, bianco, becco arancione col tubercolo nero.'),
  ('Fagiano comune',         'Phasianus colchicus',    'comune',      0, 'Galliforme, maschio appariscente con coda lunga.')
on conflict (nome_scientifico) do nothing;
