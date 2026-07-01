-- =====================================================================
--  0003_specie_birdnet_label.sql  —  PATCH ADDITIVA (idempotente)
--
--  Aggiunge la colonna `birdnet_label` al catalogo `specie` per il mapping
--  ESATTO tra l'output di BirdNET (label "Nome_scientifico_Nome comune") e
--  la specie. Il client cerca prima per birdnet_label, poi (fallback) per
--  nome_scientifico.
--
--  Non modifica tabelle/RLS esistenti. Eseguire dopo schema.sql.
-- =====================================================================

alter table specie
  add column if not exists birdnet_label text;

-- unique tollerante ai NULL (Postgres ammette piu' NULL in un indice unique)
create unique index if not exists idx_specie_birdnet_label
  on specie (birdnet_label);

comment on column specie.birdnet_label is
  'Label BirdNET completa "Nome_scientifico_Nome comune" per il mapping del riconoscimento.';
