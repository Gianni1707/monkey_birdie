-- =====================================================================
--  0002_geo_helpers.sql  —  PATCH ADDITIVA (Fase 1)
--
--  Non modifica le tabelle né la RLS gia' presenti in schema.sql.
--  Aggiunge SOLO gli oggetti che servono al client Flutter per leggere
--  e scrivere la colonna PostGIS `avvistamenti.posizione`, che PostgREST
--  non serializza in lat/lng.
--
--  Eseguire DOPO schema.sql:
--    Dashboard -> SQL Editor -> incolla -> Run.
-- =====================================================================

-- ---------------------------------------------------------------------
-- A. View di LETTURA degli avvistamenti con lat/lng + dati di specie.
--    security_invoker = on  => applica la RLS della tabella sottostante
--    (Postgres 15 / Supabase). Cosi' la view non "buca" i permessi.
-- ---------------------------------------------------------------------
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
  s.descrizione      as specie_descrizione
from avvistamenti a
join specie s on s.id = a.specie_id;

-- ---------------------------------------------------------------------
-- B. RPC di SCRITTURA: costruisce il geography point da lng/lat.
--    security invoker => l'INSERT passa dalla RLS "inserisci propri"
--    (auth.uid() = utente_id), quindi nessun bypass dei permessi.
-- ---------------------------------------------------------------------
create or replace function inserisci_avvistamento(
  p_specie_id  uuid,
  p_lat        double precision,
  p_lng        double precision,
  p_confidenza real    default null,
  p_foto_url   text    default null,
  p_audio_url  text    default null,
  p_condiviso  boolean default false
) returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_id uuid;
begin
  insert into avvistamenti
    (utente_id, specie_id, posizione, confidenza, foto_url, audio_url, condiviso)
  values
    (auth.uid(),
     p_specie_id,
     st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
     p_confidenza,
     p_foto_url,
     p_audio_url,
     p_condiviso)
  returning id into v_id;
  return v_id;
end;
$$;

-- ---------------------------------------------------------------------
-- C. Grant per il ruolo applicativo di Supabase.
-- ---------------------------------------------------------------------
grant select   on avvistamenti_dettaglio              to authenticated;
grant execute  on function inserisci_avvistamento     to authenticated;
