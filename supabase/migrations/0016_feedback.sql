-- 0016_feedback.sql — box feedback interno (consigli / bug / altro). Additiva,
-- idempotente. Solo INSERT del proprio feedback; nessuna lettura da client
-- (i feedback si leggono dal dashboard). La notifica email parte da un Database
-- Webhook su INSERT → Worker Cloudflare → Resend.
create table if not exists public.feedback (
  id            uuid primary key default gen_random_uuid(),
  utente_id     uuid references public.profili(id) on delete set null,
  tipo          text not null default 'altro',
  messaggio     text not null,
  versione_app  text,
  piattaforma   text,
  creato_il     timestamptz not null default now(),
  constraint feedback_tipo_valido check (tipo in ('consiglio', 'bug', 'altro'))
);

alter table public.feedback enable row level security;

-- Un utente autenticato può inserire SOLO il proprio feedback (utente_id = auth.uid()).
-- Nessuna policy SELECT/UPDATE/DELETE → invisibile ai client, lo leggi dal dashboard.
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'feedback'
      and policyname = 'feedback_insert_proprio'
  ) then
    create policy feedback_insert_proprio
      on public.feedback for insert to authenticated
      with check (utente_id = auth.uid());
  end if;
end $$;
