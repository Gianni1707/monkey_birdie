-- =====================================================================
--  0008_preferiti_amici.sql  —  PATCH ADDITIVA (idempotente)
--
--  Consente di LEGGERE i preferiti di un amico accettato, per mostrarli nel suo
--  profilo pubblico (UT08). NON tocca la policy esistente "preferiti: gestisci
--  i propri" (`for all`): questa e' una policy SELECT AGGIUNTIVA, permissiva
--  (OR), gated da `sono_amici`. Scrittura resta solo sui propri.
--  Ri-eseguibile. Eseguire DOPO schema.sql.
-- =====================================================================

drop policy if exists "preferiti: leggibili dagli amici" on preferiti;
create policy "preferiti: leggibili dagli amici" on preferiti
  for select to authenticated
  using (sono_amici((select auth.uid()), utente_id));
