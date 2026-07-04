# Spike — riconoscimento uccelli da FOTO (AIY Birds V1)

**Scopo (gate prima di cablare l'impl immagini):** verificare che un modello di
classificazione uccelli **da immagine** giri on-device con (1) **op supportate**,
(2) **#output == #label**, (3) **top-1 sensata** su foto note, (4) **latenza
accettabile** (anche su iPhone Safari). È il percorso **FOTO**, parallelo e
**indipendente** dall'audio (BirdNET): modello separato, runtime separato.

Standalone: non dipende dall'app Flutter, non tocca `lib/`, non tocca l'audio.

## Modello scelto — Google **AIY Vision Classifier Birds V1**
- **Architettura:** MobileNet · input **224×224×3 RGB uint8 [0,255]** (nessuna
  normalizzazione) · output **965** = **964 specie** + 1 `background`.
- **Licenza:** **Apache 2.0** (permissiva) — ok anche per uso non-commerciale.
- **Dimensione:** ~3.4 MB (`.tflite` quantizzato uint8) → ottimo on-device.
- **Dataset:** sottoinsieme iNaturalist. **Copre bene le specie comuni italiane**
  (verificate presenti: *Turdus merula, Erithacus rubecula, Parus major, Cyanistes
  caeruleus, Fringilla coelebs, Passer domesticus, Sylvia atricapilla, Columba
  palumbus, Hirundo rustica*, …).
- **Perché va bene per i due target:** op standard (conv/pooling) → nessun "muro di
  op" come nell'audio. Stesso `.tflite` per **Android** (tflite_flutter) e **Web**
  (tfjs-tflite, WASM). Changelog v3: *"Fixes out-of-order logit→labelmap mapping"* →
  usare la **v3** + labelmap esterna indicizzata per `id`.

### Da dove viene il `.tflite` (non versionato — vedi `.gitignore`)
Fonte: Kaggle Models `google/aiy` → *TfLite / vision-classifier-birds-v1 / v3*.
Download anonimo (tar.gz con dentro `3.tflite`):
```bash
curl -L -A Mozilla/5.0 \
  "https://www.kaggle.com/api/v1/models/google/aiy/TfLite/vision-classifier-birds-v1/3/download" \
  -o birds.tar.gz && tar -xzf birds.tar.gz && mv 3.tflite model/birds_V1.tflite
```
Labelmap (già versionata qui, `aiy_birds_labelmap.csv`, righe `id,name`):
`https://www.gstatic.com/aihub/tfhub/labelmaps/aiy_birds_V1_labelmap.csv`

## A) Spike nel browser (il target Web/PWA)
```bash
python3 serve.py 8080          # server statico, NIENTE COOP/COEP (single-thread WASM)
```
- **Laptop:** apri http://localhost:8080 → *1) Carica modello* → *Usa foto di esempio*
  o carica una tua foto.
- **Telefono (stessa Wi-Fi):** `http://IP-DEL-LAPTOP:8080` per misurare la latenza
  su mobile. Per la **fotocamera** su iPhone Safari serve **HTTPS**: usa un tunnel
  (`cloudflared tunnel --url http://localhost:8080`) e apri l'URL https.
- La pagina stampa: load, inferenza, **#classi vs #label** (⚠️ se non combaciano),
  e la **top-5** mappata sulle label. Un errore su op non supportate compare in rosso.

## B) Spike headless (Node) — già eseguito, esito sotto
Valida lo *stesso* `.tflite` via tfjs-tflite (WASM) senza browser. Vedi `headless/`.

## Esito (ottenuto — laptop, CPU WASM SIMD via Node)
```
op/runtime:      carica + invoca OK (XNNPACK CPU delegate) — nessun muro di op ✅
#output/#label:  965 / 965  ✅ combaciano
input:           module/hub_input/images_uint8  [1,224,224,3]  uint8
load:            ~60 ms      inferenza: ~14 ms/foto
top-1 (3/3 corrette, ~prob = score/255):
  robin      -> Erithacus rubecula  0.910   (2° Sialia sialis 0.004)
  greattit   -> Parus major         0.925   (2° Cyanistes caeruleus 0.020)  ← confusione plausibile (stessa famiglia)
  blackbird  -> Turdus merula       0.984
```
Da confermare a mano: **latenza su iPhone Safari** + **cattura da fotocamera** (spike A).

## Template risultati mobile (incollami questo compilato)
```
Telefono (____________, browser Safari/Chrome ______):
  load: ____ ms   inferenza: ____ ms
  top-1 sensata su foto reale? sì/no  (specie: __________)
  errori op non supportate? sì/no
  Giudizio latenza: accettabile / borderline / inutilizzabile
```
