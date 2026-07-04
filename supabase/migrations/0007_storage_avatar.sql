-- =====================================================================
--  0007_storage_avatar.sql  —  PATCH ADDITIVA (idempotente)
--
--  Bucket PUBBLICO `avatar` per le foto profilo (UT09). I profili sono in
--  lettura pubblica (schema.sql: "profili: lettura pubblica"), quindi un avatar
--  pubblico e' coerente (e servira' agli amici, UT08). La lettura passa dal
--  public URL; la SCRITTURA e' limitata alla propria cartella {uid}/...
--
--  Il path dell'avatar si salva in `profili.dati_personali` (jsonb) -> nessuna
--  colonna nuova, nessuna tabella toccata. Ri-eseguibile.
--  Eseguire DOPO schema.sql.
-- =====================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('avatar', 'avatar', true, 262144, array['image/jpeg'])
on conflict (id) do nothing;

-- INSERT / UPDATE / DELETE: solo nella propria cartella {uid}/...
drop policy if exists "avatar: carica il proprio" on storage.objects;
create policy "avatar: carica il proprio" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'avatar'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "avatar: aggiorna il proprio" on storage.objects;
create policy "avatar: aggiorna il proprio" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'avatar'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'avatar'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "avatar: elimina il proprio" on storage.objects;
create policy "avatar: elimina il proprio" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'avatar'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
