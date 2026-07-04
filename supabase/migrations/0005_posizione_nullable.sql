-- =====================================================================
--  0005_posizione_nullable.sql  —  PATCH ADDITIVA (idempotente)
--
--  Rende `avvistamenti.posizione` NULLABILE. Motivo: la posizione mancante e'
--  uno stato temporaneo, non un dato finto. Il client NON scrive piu' il
--  placeholder (0,0): se il GPS non e' affidabile l'utente mette il punto a
--  mano PRIMA di completare il salvataggio. A livello applicativo la posizione
--  resta OBBLIGATORIA (auto confermata o manuale); la colonna nullable e' la
--  rete di sicurezza e permette alla mappa di mostrare solo gli avvistamenti
--  con posizione (WHERE posizione IS NOT NULL).
--
--  Non modifica tabelle/RLS/trigger di schema.sql se non per rilassare questo
--  vincolo. Ri-eseguibile: DROP NOT NULL e' idempotente.
--  Eseguire DOPO schema.sql.
-- =====================================================================

alter table avvistamenti
  alter column posizione drop not null;

-- La RPC 0002 `inserisci_avvistamento` non cambia: st_makepoint(NULL,NULL)
-- propaga a posizione NULL, quindi passare lat/lng null e' gia' gestito. Il
-- client comunque salva sempre una posizione reale (obbligatoria in-app).
