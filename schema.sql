-- =====================================================================
--  Bird Watching App — Schema database
--  Target: PostgreSQL 15+ / Supabase  (con PostGIS e Row Level Security)
--
--  Come usarlo su Supabase:
--    Dashboard -> SQL Editor -> incolla questo file -> Run.
--  Le tabelle "profili" estendono auth.users (gestione utenti di Supabase).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Estensioni
-- ---------------------------------------------------------------------
create extension if not exists postgis;          -- tipi geografici per mappa/habitat
-- gen_random_uuid() e' nativo in Postgres 13+, nessuna estensione necessaria.

-- ---------------------------------------------------------------------
-- 2. Tipi enumerati
-- ---------------------------------------------------------------------
create type rarita_specie  as enum ('comune', 'poco_comune', 'rara', 'molto_rara');
create type stato_amicizia as enum ('in_attesa', 'accettata', 'rifiutata');

-- ---------------------------------------------------------------------
-- 3. PROFILI  — estende auth.users                     (UT01, UT09)
-- ---------------------------------------------------------------------
create table profili (
  id              uuid primary key references auth.users(id) on delete cascade,
  username        text unique not null,
  bio             text,
  dati_personali  jsonb not null default '{}'::jsonb,   -- campi liberi del profilo
  creato_il       timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 4. SPECIE  — catalogo di riferimento           (UT04, UT05, UT07)
--    Popolato da te (admin). I "report" di difficolta'/pericolo della
--    lista desideri derivano da questi campi + dagli avvistamenti pubblici.
-- ---------------------------------------------------------------------
create table specie (
  id                  uuid primary key default gen_random_uuid(),
  nome_comune         text not null,
  nome_scientifico    text unique not null,
  descrizione         text,
  livello_pericolo    smallint not null default 0 check (livello_pericolo between 0 and 3),
  rarita              rarita_specie not null default 'comune',
  habitat_descrizione text,
  habitat_geo         geography(multipolygon, 4326)      -- area di habitat (UT05)
);

-- ---------------------------------------------------------------------
-- 5. AVVISTAMENTI                                      (UT02, UT03)
-- ---------------------------------------------------------------------
create table avvistamenti (
  id            uuid primary key default gen_random_uuid(),
  utente_id     uuid not null references profili(id) on delete cascade,
  specie_id     uuid not null references specie(id),
  foto_url      text,
  audio_url     text,
  posizione     geography(point, 4326) not null,         -- dove l'hai visto (UT03)
  confidenza    real check (confidenza between 0 and 1),  -- output del riconoscimento
  condiviso     boolean not null default false,          -- visibile agli amici? (UT08)
  avvistato_il  timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 6. RACCOLTE  — gruppi custom dell'utente                   (UT06)
-- ---------------------------------------------------------------------
create table raccolte (
  id           uuid primary key default gen_random_uuid(),
  utente_id    uuid not null references profili(id) on delete cascade,
  nome         text not null,
  descrizione  text,
  creata_il    timestamptz not null default now()
);

-- 6b. Ponte N-N tra raccolte e avvistamenti
create table raccolte_avvistamenti (
  raccolta_id      uuid not null references raccolte(id) on delete cascade,
  avvistamento_id  uuid not null references avvistamenti(id) on delete cascade,
  primary key (raccolta_id, avvistamento_id)
);

-- ---------------------------------------------------------------------
-- 7. LISTA DESIDERI                                          (UT07)
-- ---------------------------------------------------------------------
create table lista_desideri (
  id          uuid primary key default gen_random_uuid(),
  utente_id   uuid not null references profili(id) on delete cascade,
  specie_id   uuid not null references specie(id),
  note        text,
  aggiunto_il timestamptz not null default now(),
  unique (utente_id, specie_id)
);

-- ---------------------------------------------------------------------
-- 8. PREFERITI  — specie preferite nel profilo              (UT09)
-- ---------------------------------------------------------------------
create table preferiti (
  utente_id  uuid not null references profili(id) on delete cascade,
  specie_id  uuid not null references specie(id)  on delete cascade,
  primary key (utente_id, specie_id)
);

-- ---------------------------------------------------------------------
-- 9. AMICIZIE                                                (UT08)
-- ---------------------------------------------------------------------
create table amicizie (
  richiedente_id  uuid not null references profili(id) on delete cascade,
  destinatario_id uuid not null references profili(id) on delete cascade,
  stato           stato_amicizia not null default 'in_attesa',
  creata_il       timestamptz not null default now(),
  primary key (richiedente_id, destinatario_id),
  check (richiedente_id <> destinatario_id)
);

-- ---------------------------------------------------------------------
-- 10. Indici  (gli indici spaziali GIST sono essenziali per la mappa)
-- ---------------------------------------------------------------------
create index idx_avvistamenti_utente    on avvistamenti (utente_id);
create index idx_avvistamenti_specie    on avvistamenti (specie_id);
create index idx_avvistamenti_posizione on avvistamenti using gist (posizione);
create index idx_specie_habitat         on specie       using gist (habitat_geo);
create index idx_lista_desideri_utente  on lista_desideri (utente_id);
create index idx_raccolte_utente        on raccolte (utente_id);

-- ---------------------------------------------------------------------
-- 11. Funzione di supporto: due utenti sono amici (amicizia accettata)?
-- ---------------------------------------------------------------------
create or replace function sono_amici(a uuid, b uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from amicizie
    where stato = 'accettata'
      and ( (richiedente_id = a and destinatario_id = b)
         or (richiedente_id = b and destinatario_id = a) )
  );
$$;

-- ---------------------------------------------------------------------
-- 12. Trigger: alla registrazione crea automaticamente il profilo
-- ---------------------------------------------------------------------
create or replace function gestisci_nuovo_utente()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profili (id, username)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1))
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function gestisci_nuovo_utente();

-- =====================================================================
--  13. ROW LEVEL SECURITY
--  Regola d'oro: ognuno vede e modifica solo i propri dati;
--  le specie sono pubbliche; gli avvistamenti "condiviso=true" sono
--  visibili agli amici accettati.
-- =====================================================================
alter table profili               enable row level security;
alter table specie                enable row level security;
alter table avvistamenti          enable row level security;
alter table raccolte              enable row level security;
alter table raccolte_avvistamenti enable row level security;
alter table lista_desideri        enable row level security;
alter table preferiti             enable row level security;
alter table amicizie              enable row level security;

-- PROFILI: profili leggibili da tutti gli utenti autenticati (per il social);
--          ognuno modifica solo il proprio.
create policy "profili: lettura pubblica" on profili
  for select using (true);
create policy "profili: aggiorna il proprio" on profili
  for update using ((select auth.uid()) = id);
create policy "profili: inserisci il proprio" on profili
  for insert with check ((select auth.uid()) = id);

-- SPECIE: catalogo in sola lettura per gli utenti.
create policy "specie: lettura pubblica" on specie
  for select using (true);

-- AVVISTAMENTI: propri sempre; altrui solo se condivisi e l'autore e' amico.
create policy "avvistamenti: lettura propri o condivisi da amici" on avvistamenti
  for select using (
        (select auth.uid()) = utente_id
     or (condiviso and sono_amici((select auth.uid()), utente_id))
  );
create policy "avvistamenti: inserisci propri" on avvistamenti
  for insert with check ((select auth.uid()) = utente_id);
create policy "avvistamenti: modifica propri" on avvistamenti
  for update using ((select auth.uid()) = utente_id);
create policy "avvistamenti: elimina propri" on avvistamenti
  for delete using ((select auth.uid()) = utente_id);

-- RACCOLTE: solo il proprietario.
create policy "raccolte: gestisci le proprie" on raccolte
  for all using ((select auth.uid()) = utente_id)
  with check ((select auth.uid()) = utente_id);

-- RACCOLTE_AVVISTAMENTI: gestibile se la raccolta e' tua.
create policy "raccolte_avvistamenti: gestisci contenuto proprie raccolte"
  on raccolte_avvistamenti
  for all using (
    exists (select 1 from raccolte r
            where r.id = raccolta_id and r.utente_id = (select auth.uid()))
  )
  with check (
    exists (select 1 from raccolte r
            where r.id = raccolta_id and r.utente_id = (select auth.uid()))
  );

-- LISTA DESIDERI: solo il proprietario.
create policy "lista_desideri: gestisci la propria" on lista_desideri
  for all using ((select auth.uid()) = utente_id)
  with check ((select auth.uid()) = utente_id);

-- PREFERITI: solo il proprietario.
create policy "preferiti: gestisci i propri" on preferiti
  for all using ((select auth.uid()) = utente_id)
  with check ((select auth.uid()) = utente_id);

-- AMICIZIE: vede chi e' coinvolto; invia solo come richiedente;
--           accetta/rifiuta/elimina chi e' coinvolto.
create policy "amicizie: vedi le proprie" on amicizie
  for select using (
    (select auth.uid()) in (richiedente_id, destinatario_id)
  );
create policy "amicizie: invia richiesta" on amicizie
  for insert with check ((select auth.uid()) = richiedente_id);
create policy "amicizie: rispondi" on amicizie
  for update using (
    (select auth.uid()) in (richiedente_id, destinatario_id)
  );
create policy "amicizie: elimina" on amicizie
  for delete using (
    (select auth.uid()) in (richiedente_id, destinatario_id)
  );
