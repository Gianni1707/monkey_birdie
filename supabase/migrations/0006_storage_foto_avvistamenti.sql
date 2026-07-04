-- =====================================================================
--  0006_storage_foto_avvistamenti.sql  —  PATCH ADDITIVA (idempotente)
--
--  Bucket Storage PRIVATO per le foto degli avvistamenti + policy su
--  storage.objects speculari alla RLS della tabella `avvistamenti`
--  (schema.sql: "lettura propri o condivisi da amici"). L'audio NON si
--  salva: questo riguarda solo le foto.
--
--  Convenzione path:  {utente_id}/{uuid}.jpg
--    -> il proprietario e' il primo segmento della cartella, cosi' le policy
--       lo ricavano con (storage.foldername(name))[1].
--  `avvistamenti.foto_url` memorizza il PATH dell'oggetto (non un URL): il
--  client firma al volo in lettura (createSignedUrl, soggetto a questa RLS) e
--  la policy "amici" fa match av.foto_url = storage.objects.name.
--
--  Bucket privato di proposito: la lettura passa dalla RLS (un bucket pubblico
--  la aggirerebbe). Nessuna modifica a tabelle/RPC: foto_url e p_foto_url
--  esistono gia' nella baseline. Ri-eseguibile.
--  Eseguire DOPO schema.sql (usa la funzione sono_amici).
-- =====================================================================

-- ---------------------------------------------------------------------
-- A. Bucket privato, limite 512KB, solo JPEG (la foto e' compressa a poche
--    decine di KB lato client prima dell'upload).
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('avvistamenti', 'avvistamenti', false, 524288, array['image/jpeg'])
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- B. INSERT: ognuno carica SOLO nella propria cartella {uid}/...
-- ---------------------------------------------------------------------
drop policy if exists "avvist foto: carica le proprie" on storage.objects;
create policy "avvist foto: carica le proprie" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'avvistamenti'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- ---------------------------------------------------------------------
-- C. SELECT: le proprie foto, OPPURE la foto di un avvistamento condiviso
--    da un amico accettato (stessa regola di avvistamenti). UT08 popolera'
--    `condiviso`; oggi resta sempre false -> di fatto solo le proprie.
-- ---------------------------------------------------------------------
drop policy if exists "avvist foto: leggi proprie o condivise" on storage.objects;
create policy "avvist foto: leggi proprie o condivise" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'avvistamenti'
    and (
      (storage.foldername(name))[1] = (select auth.uid())::text
      or exists (
        select 1 from public.avvistamenti av
        where av.foto_url = storage.objects.name
          and av.condiviso
          and sono_amici((select auth.uid()), av.utente_id)
      )
    )
  );

-- ---------------------------------------------------------------------
-- D. UPDATE / DELETE: solo le proprie (sostituzione / pulizia).
-- ---------------------------------------------------------------------
drop policy if exists "avvist foto: aggiorna le proprie" on storage.objects;
create policy "avvist foto: aggiorna le proprie" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'avvistamenti'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'avvistamenti'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "avvist foto: elimina le proprie" on storage.objects;
create policy "avvist foto: elimina le proprie" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'avvistamenti'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
