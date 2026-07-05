-- =====================================================================
--  0011_specie_morfologia.sql  —  PATCH ADDITIVA (idempotente)
--
--  Tratti morfologici da BIRDBASE (Figshare). Solo i tratti puliti forniti
--  dal file. Riempimento nel seed: seed/specie_morfologia_seed.sql.
--  Dove un tratto manca -> NULL -> la UI mostra "n/d".
--  Attribuzione UI: "Dati morfologici: BIRDBASE".
--
--  - peso_min_g / peso_max_g: range di massa (g). Se il range manca o è
--    degenere, entrambi = massa media (valore singolo). NULL se assente.
--  - uova_min / uova_max: dimensione della covata (Clutch_Min/Max).
--  - nido: tipo di nido (Nest_Type decodificato in italiano).
--
--  Eseguire DOPO 0010.
-- =====================================================================

alter table specie add column if not exists peso_min_g integer;
alter table specie add column if not exists peso_max_g integer;
alter table specie add column if not exists uova_min   smallint;
alter table specie add column if not exists uova_max   smallint;
alter table specie add column if not exists nido       text;
