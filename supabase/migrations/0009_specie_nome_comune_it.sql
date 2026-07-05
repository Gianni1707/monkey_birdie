-- =====================================================================
--  0009_specie_nome_comune_it.sql  —  PATCH ADDITIVA (idempotente)
--
--  Nome comune ITALIANO nel catalogo specie + esposizione nella view di
--  lettura degli avvistamenti. NON modifica tabelle/colonne/RLS/migrazioni
--  esistenti. La UI mostra nome_comune_it se presente, altrimenti il nome
--  inglese gia' esistente (nome_comune).
--
--  Eseguire DOPO 0008. Poi il seed: seed/specie_nome_comune_it_seed.sql.
-- =====================================================================

-- A. Colonna aggiuntiva (nullable): il nome comune in italiano.
alter table specie add column if not exists nome_comune_it text;

-- B. View di lettura ricreata (create or replace = additivo, mantiene i
--    grant e la security_invoker). NB: create or replace view consente SOLO di
--    AGGIUNGERE colonne IN FONDO (non riordinare/rinominare) -> quindi
--    specie_nome_comune_it e' l'ULTIMA colonna, dopo specie_descrizione.
--    Il client PostgREST legge per NOME, quindi la posizione e' ininfluente.
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
  s.nome_comune      as specie_nome_comune,
  s.nome_scientifico as specie_nome_scientifico,
  s.rarita           as specie_rarita,
  s.livello_pericolo as specie_livello_pericolo,
  s.descrizione      as specie_descrizione,
  s.nome_comune_it   as specie_nome_comune_it   -- aggiunta IN FONDO (0009)
from avvistamenti a
join specie s on s.id = a.specie_id;
