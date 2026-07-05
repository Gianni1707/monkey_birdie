-- =====================================================================
--  0010_specie_descrizione.sql  —  PATCH ADDITIVA (idempotente)
--
--  Attribuzione della descrizione specie (arricchimento da Wikipedia).
--  La colonna `descrizione` esiste già (schema.sql): qui aggiungo solo la
--  FONTE e il LINK. Il riempimento è nel seed: seed/specie_descrizione_seed.sql
--  (che tocca `descrizione` solo dove è NULL, senza sovrascrivere).
--
--  Eseguire DOPO 0009.
-- =====================================================================

alter table specie add column if not exists descrizione_fonte text;
alter table specie add column if not exists descrizione_url text;

-- View di lettura ricreata: colonne nuove IN FONDO (dopo specie_nome_comune_it),
-- coerente con la regola di 0009 (create or replace consente solo append).
create or replace view avvistamenti_dettaglio
with (security_invoker = on) as
select
  a.id,
  a.utente_id,
  a.specie_id,
  a.foto_url,
  a.audio_url,
  st_y(a.posizione::geometry) as lat,
  st_x(a.posizione::geometry) as lng,
  a.confidenza,
  a.condiviso,
  a.avvistato_il,
  s.nome_comune       as specie_nome_comune,
  s.nome_scientifico  as specie_nome_scientifico,
  s.rarita            as specie_rarita,
  s.livello_pericolo  as specie_livello_pericolo,
  s.descrizione       as specie_descrizione,
  s.nome_comune_it    as specie_nome_comune_it,
  s.descrizione_fonte as specie_descrizione_fonte,
  s.descrizione_url   as specie_descrizione_url
from avvistamenti a
join specie s on s.id = a.specie_id;
