-- 0015_app_versione.sql — "cartello" con l'ultima versione APK Android disponibile
-- (controllo aggiornamenti per il sideload). Additiva, idempotente, sola lettura.
create table if not exists public.app_versione (
  id             int primary key default 1,
  versione       text    not null,               -- es. "1.0.1" (semantica, mostrata)
  build          int     not null,               -- es. 2 (confronto robusto per numero)
  url_apk        text    not null,               -- link diretto al nuovo APK
  note           text,                            -- novità (opzionale, può essere null)
  obbligatorio   boolean not null default false,  -- per il futuro: update critico
  aggiornato_il  timestamptz not null default now(),
  constraint app_versione_singleton check (id = 1) -- una sola riga
);

alter table public.app_versione enable row level security;

-- Lettura per tutti (è solo un cartello pubblico). Nessuna policy di scrittura:
-- con RLS attiva e senza policy write, anon/authenticated NON possono scrivere;
-- aggiorni la riga solo tu dal dashboard (service_role).
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'app_versione'
      and policyname = 'app_versione_lettura_tutti'
  ) then
    create policy app_versione_lettura_tutti
      on public.app_versione for select using (true);
  end if;
end $$;
