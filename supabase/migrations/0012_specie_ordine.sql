-- =====================================================================
--  0012_specie_ordine.sql  —  PATCH ADDITIVA (idempotente)
--
--  UT04 — ordine tassonomico (Aves) nel catalogo, per il badge "ORDINE"
--  sulla scheda specie. Dato salvato in LATINO grezzo com'è restituito da
--  GBIF (/v1/species/match -> campo `order`, es. `Passeriformes`): neutro e
--  riusabile. L'italianizzazione è solo a display (lib/shared/ordine_tassonomico.dart).
--  Riempimento nel seed: seed/specie_ordine_seed.sql (tocca `ordine` solo dove
--  è NULL). Dove manca -> NULL -> la UI non mostra il badge.
--
--  Eseguire DOPO 0011.
-- =====================================================================

alter table specie add column if not exists ordine text;

-- View di lettura ricreata: colonna nuova IN FONDO (dopo specie_descrizione_url),
-- coerente con la regola di 0009/0010 (create or replace consente solo append).
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
  s.descrizione_url   as specie_descrizione_url,
  s.ordine            as specie_ordine
from avvistamenti a
join specie s on s.id = a.specie_id;
