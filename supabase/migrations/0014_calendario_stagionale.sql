-- =====================================================================
--  0014_calendario_stagionale.sql  —  PATCH ADDITIVA (idempotente)
--
--  Calendario stagionale: 12 note (una per mese) su cosa fanno gli uccelli
--  nel periodo. Alimenta il riquadro "In questo periodo" della Home (mostra
--  il mese corrente). Riempimento: seed/calendario_stagionale_seed.sql.
-- =====================================================================

create table if not exists calendario_stagionale (
  mese   smallint primary key check (mese between 1 and 12),
  titolo text not null,
  testo  text not null
);

alter table calendario_stagionale enable row level security;

do $$ begin
  create policy "calendario: lettura per tutti"
    on calendario_stagionale for select using (true);
exception when duplicate_object then null; end $$;
