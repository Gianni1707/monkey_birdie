-- Seed iniziale del cartello versione: versione ATTUALE (1.0.0 / build 1).
-- url_apk è un PLACEHOLDER: sostituiscilo col link diretto al nuovo APK (es. una
-- GitHub Release). Per far scattare l'avviso in-app, alza `build` (es. 2) e `versione`.
insert into public.app_versione (id, versione, build, url_apk, note, obbligatorio)
values (1, '1.0.0', 1, 'https://ESEMPIO/app-release.apk', null, false)
on conflict (id) do update set
  versione     = excluded.versione,
  build        = excluded.build,
  url_apk      = excluded.url_apk,
  note         = excluded.note,
  obbligatorio = excluded.obbligatorio,
  aggiornato_il = now();
