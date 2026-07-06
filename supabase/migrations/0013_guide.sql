-- =====================================================================
--  0013_guide.sql  —  PATCH ADDITIVA (idempotente)
--
--  Guide & consigli di birdwatching (contenuto curato, sola lettura per gli
--  utenti). Alimenta la sezione "News e guide" della Home (consiglio del
--  giorno) e l'elenco completo "Tutti". Riempimento: seed/guide_seed.sql.
-- =====================================================================

create table if not exists guide (
  id        uuid primary key default gen_random_uuid(),
  categoria text not null,
  titolo    text not null,
  corpo     text not null,
  ordine    int  not null default 0   -- ordine di visualizzazione nell'elenco
);

alter table guide enable row level security;

-- Lettura pubblica; nessuna scrittura via client (contenuto curato, inserito
-- dal seed che gira come owner → bypassa la RLS).
do $$ begin
  create policy "guide: lettura per tutti" on guide for select using (true);
exception when duplicate_object then null; end $$;
