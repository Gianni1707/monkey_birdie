-- =====================================================================
--  0004_specie_image_label.sql  —  PATCH ADDITIVA (idempotente)
--
--  Aggiunge la colonna `image_label` al catalogo `specie` per il mapping del
--  riconoscimento da FOTO (modello AIY Vision Classifier Birds V1). Le label del
--  modello immagine SONO nomi scientifici, quindi image_label = nome_scientifico
--  per le specie riconoscibili. Il client cerca prima per image_label, poi
--  (fallback) per nome_scientifico. Analoga a birdnet_label (0003), indipendente.
--
--  Non modifica tabelle/RLS esistenti. Eseguire dopo schema.sql (e 0003).
--  Popolamento: seed/specie_image_label_seed.sql.
-- =====================================================================

alter table specie
  add column if not exists image_label text;

-- unique tollerante ai NULL (Postgres ammette piu' NULL in un indice unique)
create unique index if not exists idx_specie_image_label
  on specie (image_label);

comment on column specie.image_label is
  'Nome scientifico usato come label del modello immagine (AIY Birds V1) per il mapping del riconoscimento da foto.';
